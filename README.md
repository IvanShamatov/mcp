# MCP Servers Collection

A collection of Model Context Protocol (MCP) servers written in Ruby for various system operations.

## Servers

### 1. Simple MCP Server (`simple_mcp_server.rb`)
Basic MCP server with mathematical calculations and time functions.

**Tools:**
- `get_current_time` - Returns current time
- `calculate` - Performs mathematical calculations

### 2. Swagger MCP Wrapper (`swagger_mcp_wrapper.rb`)
Automatically generates MCP tools from Swagger/OpenAPI specifications.

**Usage:**
```bash
ruby swagger_mcp_wrapper.rb <swagger_path> <api_base_url>
```

### 3. System Monitor MCP (`system_monitor_mcp.rb`)
Monitors system resources and performance.

**Tools:**
- `check_disk_space` - Checks available disk space
- `check_memory` - Checks memory usage
- `check_cpu` - Checks CPU load
- `list_processes` - Shows top processes by resource usage
- `system_info` - Shows system information
- `network_connections` - Shows active network connections

### 4. System Monitor MCP (Working Fast-MCP version) (`system_monitor_working_mcp.rb`)
Working system monitoring using the `fast_mcp` gem:
- `check_disk_space` - Checks available disk space
- `check_memory` - Checks memory usage
- `check_cpu` - Checks CPU load
- `system_info` - Shows system information

### 5. Git MCP Server (Working Fast-MCP version) (`git_working_mcp.rb`)
Working Git operations using the `fast_mcp` gem:
- `git_status` - Shows git repository status
- `git_log` - Shows git commit history
- `git_branches` - Lists all git branches

### 6. Task Manager MCP (Fast-MCP version) (`task_manager_fast_mcp.rb`)
Manages tasks with priority levels and status tracking using `fast_mcp` gem.

**Tools:**
- `list_tasks` - Shows all tasks
- `add_task` - Adds a new task
- `complete_task` - Marks task as completed
- `delete_task` - Deletes a task
- `task_stats` - Shows task statistics

### 7. Swagger MCP Wrapper (Fast-MCP version) (`swagger_fast_mcp.rb`)
Automatically generates MCP tools from Swagger/OpenAPI specifications using `fast_mcp` gem.

**Tools:**
- `swagger_api` - Calls API endpoint from Swagger specification
- `load_swagger` - Loads and parses Swagger/OpenAPI specification
- `generate_api_tools` - Generates MCP tools from Swagger specification


## Installation

1. Install Ruby dependencies:
```bash
bundle install
```

2. Make scripts executable:
```bash
chmod +x *.rb
```

## Usage

### Running individual servers

```bash
# Simple MCP Server
ruby simple_mcp_server.rb

# System Monitor MCP
ruby system_monitor_working_mcp.rb

# Task Manager MCP (Fast-MCP version)
ruby task_manager_fast_mcp.rb

# Swagger MCP Wrapper (Fast-MCP version)
ruby swagger_fast_mcp.rb

# Original versions (for reference)
ruby task_manager_mcp.rb
ruby swagger_mcp_wrapper.rb ./swagger.json http://localhost:3000
```

### Integration with MCP clients

These servers can be integrated with MCP-compatible clients by configuring them in your MCP client configuration file.

Example configuration for Cursor:
```json
{
  "mcpServers": {
    "system-monitor": {
      "command": "ruby",
      "args": ["/path/to/system_monitor_working_mcp.rb"]
    },
    "git-ops": {
      "command": "ruby",
      "args": ["/path/to/git_working_mcp.rb"]
    },
    "task-manager": {
      "command": "ruby",
      "args": ["/path/to/task_manager_fast_mcp.rb"]
    },
    "swagger-api": {
      "command": "ruby",
      "args": ["/path/to/swagger_fast_mcp.rb"]
    }
  }
}
```

## Dependencies

- Ruby 2.7+
- `fast_mcp` gem (for fast-mcp based servers)
- `git` gem (for Git operations)
- Standard Ruby libraries (json, yaml, net/http, fileutils)

## Features

- **English language support** - All user-facing messages are in English
- **Cross-platform compatibility** - Works on macOS and Linux
- **Error handling** - Comprehensive error handling with user-friendly messages
- **Extensible** - Easy to add new tools and functionality
- **MCP compliant** - Follows Model Context Protocol specifications

## Development

To add new tools to existing servers:

1. Add tool definition in `setup_tools` method
2. Implement the corresponding method
3. Add appropriate error handling
4. Test with MCP client

## License

MIT License

