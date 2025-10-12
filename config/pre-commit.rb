#!/usr/bin/env ruby

changed_files = ARGV

if changed_files.empty?
  exit 0
end

violations = []

changed_files.each do |file|
  next unless File.exist?(file)
  next unless file.end_with?('.erb', '.html', '.rb')

  content = File.read(file)
  if content.include?('<%') && content.match?(/<%\s*console\s*%>/)
    violations << file
  end
end

if violations.any?
  puts "\n❌ ERROR: Found <% console %> in the following files:"
  violations.each do |file|
    puts "  - #{file}"
  end
  puts "\nPlease remove the console debugging statements before committing.\n"
  exit 1
end

exit 0
