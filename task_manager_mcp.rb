#!/usr/bin/env ruby

require 'fast_mcp'
require 'json'
require 'fileutils'

class ListTasksTool < FastMcp::Tool
  description 'Shows all tasks'

  arguments do
    optional(:status).filled(:string).description('Filter by status (all, pending, done)')
  end

  def call(status: 'all')
    tasks = load_tasks
    filtered = if status == 'all'
      tasks
    else
      tasks.select { |t| t['status'] == status }
    end

    if filtered.empty?
      "No tasks"
    else
      filtered.map.with_index do |task, i|
        checkbox = task['status'] == 'done' ? '✓' : '☐'
        priority_emoji = case task['priority']
        when 'high' then '🔴'
        when 'medium' then '🟡'
        when 'low' then '🟢'
        else ''
        end
        "#{checkbox} #{i + 1}. #{priority_emoji} #{task['title']}"
      end.join("\n")
    end
  end

  private

  def load_tasks
    tasks_file = File.expand_path('~/.mcp_tasks.json')
    return [] unless File.exist?(tasks_file)
    JSON.parse(File.read(tasks_file))
  rescue
    []
  end
end

class AddTaskTool < FastMcp::Tool
  description 'Adds a new task'

  arguments do
    required(:title).filled(:string).description('Task title')
    optional(:priority).filled(:string).description('Task priority (low, medium, high)')
  end

  def call(title:, priority: 'medium')
    tasks_file = File.expand_path('~/.mcp_tasks.json')
    tasks = load_tasks

    task = {
      'id' => Time.now.to_i,
      'title' => title,
      'priority' => priority,
      'status' => 'pending',
      'created_at' => Time.now.to_s
    }

    tasks << task
    save_tasks(tasks)
    "✓ Task added: #{task['title']}"
  end

  private

  def load_tasks
    tasks_file = File.expand_path('~/.mcp_tasks.json')
    return [] unless File.exist?(tasks_file)
    JSON.parse(File.read(tasks_file))
  rescue
    []
  end

  def save_tasks(tasks)
    tasks_file = File.expand_path('~/.mcp_tasks.json')
    File.write(tasks_file, JSON.pretty_generate(tasks))
  end
end

class CompleteTaskTool < FastMcp::Tool
  description 'Marks task as completed'

  arguments do
    required(:task_id).filled(:integer).description('Task ID or number in list')
  end

  def call(task_id:)
    tasks_file = File.expand_path('~/.mcp_tasks.json')
    tasks = load_tasks
    index = task_id.to_i - 1

    if index >= 0 && index < tasks.length
      tasks[index]['status'] = 'done'
      save_tasks(tasks)
      "✓ Task completed: #{tasks[index]['title']}"
    else
      "✗ Task not found"
    end
  end

  private

  def load_tasks
    tasks_file = File.expand_path('~/.mcp_tasks.json')
    return [] unless File.exist?(tasks_file)
    JSON.parse(File.read(tasks_file))
  rescue
    []
  end

  def save_tasks(tasks)
    tasks_file = File.expand_path('~/.mcp_tasks.json')
    File.write(tasks_file, JSON.pretty_generate(tasks))
  end
end

class DeleteTaskTool < FastMcp::Tool
  description 'Deletes a task'

  arguments do
    required(:task_id).filled(:integer).description('Task ID or number in list')
  end

  def call(task_id:)
    tasks_file = File.expand_path('~/.mcp_tasks.json')
    tasks = load_tasks
    index = task_id.to_i - 1

    if index >= 0 && index < tasks.length
      deleted = tasks.delete_at(index)
      save_tasks(tasks)
      "✓ Task deleted: #{deleted['title']}"
    else
      "✗ Task not found"
    end
  end

  private

  def load_tasks
    tasks_file = File.expand_path('~/.mcp_tasks.json')
    return [] unless File.exist?(tasks_file)
    JSON.parse(File.read(tasks_file))
  rescue
    []
  end

  def save_tasks(tasks)
    tasks_file = File.expand_path('~/.mcp_tasks.json')
    File.write(tasks_file, JSON.pretty_generate(tasks))
  end
end

class TaskStatsTool < FastMcp::Tool
  description 'Shows task statistics'

  arguments do
  end

  def call
    tasks = load_tasks
    total = tasks.length
    done = tasks.count { |t| t['status'] == 'done' }
    pending = total - done

    by_priority = tasks.group_by { |t| t['priority'] }

    stats = [
      "📊 Task statistics:",
      "Total: #{total}",
      "Completed: #{done}",
      "In progress: #{pending}",
      "",
      "By priority:",
      "  🔴 High: #{(by_priority['high'] || []).length}",
      "  🟡 Medium: #{(by_priority['medium'] || []).length}",
      "  🟢 Low: #{(by_priority['low'] || []).length}"
    ]

    stats.join("\n")
  end

  private

  def load_tasks
    tasks_file = File.expand_path('~/.mcp_tasks.json')
    return [] unless File.exist?(tasks_file)
    JSON.parse(File.read(tasks_file))
  rescue
    []
  end
end

# Create server instance
server = FastMcp::Server.new(
  name: 'task-manager-mcp',
  version: '1.0.0'
)

# Register tools
server.register_tool(ListTasksTool)
server.register_tool(AddTaskTool)
server.register_tool(CompleteTaskTool)
server.register_tool(DeleteTaskTool)
server.register_tool(TaskStatsTool)

# Run the server
server.start if __FILE__ == $0
