#!/usr/bin/env ruby

require 'json'

TOOLS = {}

TOOLS['get_current_time'] = {
  metadata: {
    name: 'get_current_time',
    description: 'Returns current time',
    inputSchema: {},
  },
  handler: lambda { |params|
    Time.now.strftime('%Y-%m-%d %H:%M:%S')
  }
}

TOOLS['calculate'] = {
  metadata: {
    name: 'calculate',
    description: 'Performs mathematical calculations',
    inputSchema: {
      type: 'object',
      properties: {
        expression: {
          type: 'string',
          description: 'Mathematical expression'
        }
      },
      required: ['expression']
    }
  },
  handler: lambda { |params|
    # Don't use eval in production!
    result = eval(params['expression'])
    "Result: #{result}"
  }
}

class SimpleMCPServer
  def initialize
    @tools = TOOLS
  end

  def handle_request(request)
    method = request['method']

    case method
    when 'initialize'
      {
        protocolVersion: '2024-11-05',
        serverInfo: {
          name: 'simple-mcp-server',
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
    STDERR.puts "MCP Server started"

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

if __FILE__ == $0
  SimpleMCPServer.new.run
end
