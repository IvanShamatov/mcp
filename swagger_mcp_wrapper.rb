#!/usr/bin/env ruby
# swagger_mcp_wrapper.rb

require 'json'
require 'net/http'
require 'uri'
require 'yaml'

class SwaggerMCPWrapper
  def initialize(swagger_path, api_base_url)
    @api_base_url = api_base_url
    @swagger = load_swagger(swagger_path)
    @tools = {}
    parse_swagger_to_tools
  end

  def load_swagger(path)
    if path.start_with?('http')
      # Load from URL
      uri = URI.parse(path)
      response = Net::HTTP.get_response(uri)
      JSON.parse(response.body)
    elsif path.end_with?('.json')
      JSON.parse(File.read(path))
    elsif path.end_with?('.yml', '.yaml')
      YAML.load_file(path)
    end
  rescue => e
    STDERR.puts "❌ Error loading Swagger: #{e.message}"
    { 'paths' => {} }
  end

  def parse_swagger_to_tools
    paths = @swagger['paths'] || {}

    paths.each do |path, methods|
      methods.each do |http_method, spec|
        next unless ['get', 'post', 'put', 'delete', 'patch'].include?(http_method)

        # Create tool name from path and method
        tool_name = generate_tool_name(http_method, path, spec)

        # Create description
        description = spec['summary'] || spec['description'] || "#{http_method.upcase} #{path}"

        # Parse parameters
        parameters = parse_parameters(spec['parameters'] || [])

        # Register tool
        register_tool(
          name: tool_name,
          description: description,
          parameters: parameters,
          http_method: http_method,
          path: path,
          spec: spec
        )
      end
    end

    STDERR.puts "✓ Created #{@tools.length} MCP tools from Swagger specification"
  end

  def generate_tool_name(http_method, path, spec)
    # Try to use operationId from Swagger
    return spec['operationId'] if spec['operationId']

    # Otherwise generate from path
    clean_path = path.gsub(/^\/api\/v\d+\//, '')
                     .gsub(/[{}]/, '')
                     .gsub('/', '_')
                     .gsub(/\W/, '_')

    "#{http_method}_#{clean_path}"
  end

  def parse_parameters(params)
    properties = {}
    required = []

    params.each do |param|
      param_name = param['name']
      param_schema = {
        type: param['type'] || 'string',
        description: param['description'] || ''
      }

      param_schema[:enum] = param['enum'] if param['enum']

      properties[param_name] = param_schema
      required << param_name if param['required']
    end

    # Handle body parameters
    body_param = params.find { |p| p['in'] == 'body' }
    if body_param && body_param['schema']
      schema = body_param['schema']
      if schema['properties']
        properties.merge!(convert_swagger_schema(schema['properties']))
        required += (schema['required'] || [])
      end
    end

    {
      type: 'object',
      properties: properties,
      required: required
    }
  end

  def convert_swagger_schema(properties)
    result = {}
    properties.each do |name, schema|
      result[name] = {
        type: schema['type'] || 'string',
        description: schema['description'] || ''
      }
    end
    result
  end

  def register_tool(name:, description:, parameters:, http_method:, path:, spec:)
    @tools[name] = {
      metadata: {
        name: name,
        description: description,
        inputSchema: parameters
      },
      handler: lambda { |params|
        execute_api_call(http_method, path, params, spec)
      }
    }
  end

  def execute_api_call(http_method, path, params, spec)
    # Substitute path parameters
    final_path = path.dup
    path_params = {}

    params.each do |key, value|
      if final_path.include?("{#{key}}")
        final_path.gsub!("{#{key}}", value.to_s)
        path_params[key] = value
      end
    end

    # Separate query and body parameters
    query_params = {}
    body_params = {}

    spec_params = spec['parameters'] || []

    params.each do |key, value|
      next if path_params[key]

      param_spec = spec_params.find { |p| p['name'] == key }

      if param_spec && param_spec['in'] == 'query'
        query_params[key] = value
      else
        body_params[key] = value
      end
    end

    # Build URL
    base_url = @api_base_url.end_with?('/') ? @api_base_url[0..-2] : @api_base_url
    path = final_path.start_with?('/') ? final_path : "/#{final_path}"
    url = "#{base_url}#{path}"
    url += "?" + URI.encode_www_form(query_params) unless query_params.empty?

    # Make request
    begin
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == 'https')

      request = case http_method
      when 'get'
        Net::HTTP::Get.new(uri.request_uri)
      when 'post'
        req = Net::HTTP::Post.new(uri.request_uri)
        req.body = body_params.to_json unless body_params.empty?
        req
      when 'put'
        req = Net::HTTP::Put.new(uri.request_uri)
        req.body = body_params.to_json unless body_params.empty?
        req
      when 'delete'
        Net::HTTP::Delete.new(uri.request_uri)
      when 'patch'
        req = Net::HTTP::Patch.new(uri.request_uri)
        req.body = body_params.to_json unless body_params.empty?
        req
      end

      request['Content-Type'] = 'application/json'
      response = http.request(request)

      format_response(response)
    rescue => e
      "❌ Error calling API: #{e.message}"
    end
  end

  def format_response(response)
    status = response.code.to_i
    body = begin
      JSON.parse(response.body)
    rescue
      response.body
    end

    if status >= 200 && status < 300
      if body.is_a?(Hash)
        "✓ Success:\n#{JSON.pretty_generate(body)}"
      elsif body.is_a?(Array)
        "✓ Retrieved records: #{body.length}\n#{JSON.pretty_generate(body)}"
      else
        "✓ Result: #{body}"
      end
    else
      "❌ Error #{status}: #{body}"
    end
  end

  def handle_request(request)
    method = request['method']

    case method
    when 'initialize'
      {
        protocolVersion: '2024-11-05',
        serverInfo: {
          name: 'swagger-mcp-wrapper',
          version: '1.0.0'
        },
        capabilities: {
          tools: {}
        }
      }

    when 'tools/list'
      {
        tools: @tools.map { |name, tool| tool[:metadata] }
      }

    when 'tools/call'
      tool_name = request['params']['name']
      tool_params = request['params']['arguments'] || {}

      if @tools[tool_name]
        result = @tools[tool_name][:handler].call(tool_params)
        {
          content: [
            {
              type: 'text',
              text: result
            }
          ]
        }
      else
        { error: "Tool not found: #{tool_name}" }
      end

    else
      { error: "Unknown method: #{method}" }
    end
  end

  def run
    STDERR.puts "Swagger MCP Wrapper started"
    STDERR.puts "API Base URL: #{@api_base_url}"

    loop do
      line = STDIN.gets
      break if line.nil?

      begin
        request = JSON.parse(line)
        STDERR.puts "Received: #{request['method']}"

        response = handle_request(request)

        output = {
          jsonrpc: '2.0',
          id: request['id'],
          result: response
        }

        STDOUT.puts output.to_json
        STDOUT.flush
      rescue => e
        STDERR.puts "Error: #{e.message}"
        STDERR.puts e.backtrace
      end
    end
  end
end

# Usage:
# ruby swagger_mcp_wrapper.rb <swagger_url_or_path> <api_base_url>

if __FILE__ == $0
  if ARGV.length < 2
    STDERR.puts "Usage: ruby swagger_mcp_wrapper.rb <swagger_path> <api_base_url>"
    STDERR.puts "Example: ruby swagger_mcp_wrapper.rb ./swagger.json http://localhost:3000"
    exit 1
  end

  swagger_path = ARGV[0]
  api_base_url = ARGV[1]

  SwaggerMCPWrapper.new(swagger_path, api_base_url).run
end
