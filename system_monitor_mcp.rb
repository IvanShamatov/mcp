#!/usr/bin/env ruby

require 'fast_mcp'

class CheckDiskSpaceTool < FastMcp::Tool
  description 'Checks available disk space'

  arguments do
    optional(:path).filled(:string).description('Path to check (default /)')
  end

  def call(path: '/')
    if RUBY_PLATFORM =~ /darwin|linux/
      output = `df -h #{path}`.split("\n")
      if output.length >= 2
        headers = output[0].split
        values = output[1].split

        result = ["💾 Disk: #{path}"]
        result << "Total: #{values[1]}"
        result << "Used: #{values[2]}"
        result << "Available: #{values[3]}"
        result << "Usage percentage: #{values[4]}"
        result_text = result.join("\n")
      else
        result_text = "❌ Error getting disk information"
      end
    else
      result_text = "❌ Platform not supported"
    end

    result_text
  end
end

class CheckMemoryTool < FastMcp::Tool
  description 'Checks memory usage'

  arguments do
  end

  def call
    if RUBY_PLATFORM =~ /darwin/
      output = `vm_stat`
      result_text = "🧠 Memory (macOS):\n#{output}"
    elsif RUBY_PLATFORM =~ /linux/
      output = `free -h`
      result_text = "🧠 Memory (Linux):\n#{output}"
    else
      result_text = "❌ Platform not supported"
    end

    result_text
  end
end

class CheckCPUTool < FastMcp::Tool
  description 'Checks CPU load'

  arguments do
  end

  def call
    if RUBY_PLATFORM =~ /darwin/
      output = `top -l 1 | grep "CPU usage"`
      result_text = "🖥️  CPU (macOS):\n#{output}"
    elsif RUBY_PLATFORM =~ /linux/
      output = `top -bn1 | grep "Cpu(s)"`
      result_text = "🖥️  CPU (Linux):\n#{output}"
    else
      result_text = "❌ Platform not supported"
    end

    result_text
  end
end

class SystemInfoTool < FastMcp::Tool
  description 'Shows system information'

  arguments do
  end

  def call
    result = ["💻 System information:"]
    result << ""

    # Ruby platform
    result << "Platform: #{RUBY_PLATFORM}"

    # Hostname
    hostname = `hostname`.strip
    result << "Hostname: #{hostname}"

    # Uptime
    if RUBY_PLATFORM =~ /darwin|linux/
      uptime = `uptime`.strip
      result << "Uptime: #{uptime}"
    end

    # Ruby version
    result << ""
    result << "Ruby version: #{RUBY_VERSION}"

    # Architecture
    arch = `uname -m`.strip rescue 'unknown'
    result << "Architecture: #{arch}"

    # OS
    if RUBY_PLATFORM =~ /darwin/
      os_version = `sw_vers -productVersion`.strip rescue 'unknown'
      result << "macOS version: #{os_version}"
    elsif RUBY_PLATFORM =~ /linux/
      os_info = `cat /etc/os-release | grep PRETTY_NAME`.strip rescue 'unknown'
      result << "OS: #{os_info.gsub('PRETTY_NAME=', '').gsub('"', '')}"
    end

    {
      content: [
        {
          type: 'text',
          text: result.join("\n")
        }
      ]
    }
  end
end

# Create server instance
server = FastMcp::Server.new(
  name: 'system-monitor-working-mcp',
  version: '1.0.0'
)

# Register tools
server.register_tool(CheckDiskSpaceTool)
server.register_tool(CheckMemoryTool)
server.register_tool(CheckCPUTool)
server.register_tool(SystemInfoTool)

# Run the server
server.start if __FILE__ == $0
