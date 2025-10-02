#!/usr/bin/env ruby
# git_working_mcp.rb

require 'fast_mcp'
require 'git'

class GitStatusTool < FastMcp::Tool
  description 'Shows git repository status'

  arguments do
    optional(:path).filled(:string).description('Repository path (default: current directory)')
  end

  def call(path: '.')
    repo = Git.open(path)
    status = repo.status

    result = ["📊 Git Status for #{path}:"]
    result << ""

    if status.changed.any?
      result << "📝 Modified files:"
      status.changed.each { |file, _| result << "  M #{file}" }
      result << ""
    end

    if status.added.any?
      result << "➕ Added files:"
      status.added.each { |file, _| result << "  A #{file}" }
      result << ""
    end

    if status.deleted.any?
      result << "🗑️  Deleted files:"
      status.deleted.each { |file, _| result << "  D #{file}" }
      result << ""
    end

    if status.untracked.any?
      result << "❓ Untracked files:"
      status.untracked.each { |file, _| result << "  ? #{file}" }
      result << ""
    end

    if status.changed.empty? && status.added.empty? && status.deleted.empty? && status.untracked.empty?
      result << "✅ Working directory clean"
    end

    result.join("\n")
  rescue => e
    "❌ Error getting git status: #{e.message}"
  end
end

class GitLogTool < FastMcp::Tool
  description 'Shows git commit history'

  arguments do
    optional(:path).filled(:string).description('Repository path (default: current directory)')
    optional(:limit).filled(:integer).description('Number of commits to show (default: 10)')
  end

  def call(path: '.', limit: 10)
    repo = Git.open(path)
    commits = repo.log(limit)

    result = ["📜 Git Log for #{path}:"]
    result << ""

    commits.each_with_index do |commit, i|
      result << "#{i + 1}. #{commit.sha[0..7]} - #{commit.message.lines.first.strip}"
      result << "   Author: #{commit.author.name} <#{commit.author.email}>"
      result << "   Date: #{commit.date}"
      result << ""
    end

    result.join("\n")
  rescue => e
    "❌ Error getting git log: #{e.message}"
  end
end

class GitBranchesTool < FastMcp::Tool
  description 'Lists all git branches'

  arguments do
    optional(:path).filled(:string).description('Repository path (default: current directory)')
  end

  def call(path: '.')
    repo = Git.open(path)
    branches = repo.branches.local

    result = ["🌿 Git Branches for #{path}:"]
    result << ""

    current_branch = repo.current_branch

    branches.each do |branch|
      marker = branch.name == current_branch ? "👉 " : "   "
      result << "#{marker}#{branch.name}"
    end

    result.join("\n")
  rescue => e
    "❌ Error getting git branches: #{e.message}"
  end
end

# Create server instance
server = FastMcp::Server.new(
  name: 'git-mcp-server',
  version: '1.0.0'
)

# Register tools
server.register_tool(GitStatusTool)
server.register_tool(GitLogTool)
server.register_tool(GitBranchesTool)

# Run the server
server.start if __FILE__ == $0
