#!/usr/bin/env ruby
require 'fast_mcp'

class GetCurrentTimeTool < FastMcp::Tool
  description 'Returns current time'

  def call
    Time.now.strftime('%Y-%m-%d %H:%M:%S')
  end
end

class CalculateTool < FastMcp::Tool
  description 'Performs mathematical calculations'

  arguments do
    required(:expression).filled(:string).description('Mathematical expression')
  end

  def call(expression:)
    # Don't use eval in production!
    result = eval(expression)
    "Result: #{result}"
  end
end

server = FastMcp::Server.new(name: 'simple-fast-mcp', version: '1.0.0')

# Register tools
server.register_tool(GetCurrentTimeTool)
server.register_tool(CalculateTool)

# Run the server
server.start if __FILE__ == $0
