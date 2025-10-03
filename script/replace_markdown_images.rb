#!/usr/bin/env ruby

require 'json'
require 'fileutils'
require 'uri'

class MarkdownImageReplacer
  def initialize(mapping_file:, markdown_file:, output_file: nil, dry_run: false)
    @mapping_file = File.expand_path(mapping_file)
    @markdown_file = File.expand_path(markdown_file)
    @output_file = output_file ? File.expand_path(output_file) : @markdown_file
    @dry_run = dry_run
    @replacements = []
    @mapping_data = nil
  end

  def run
    puts "Starting markdown image replacement..."
    puts "Mapping file: #{@mapping_file}"
    puts "Markdown file: #{@markdown_file}"
    puts "Output file: #{@output_file}"
    puts "Dry run: #{@dry_run ? 'YES' : 'NO'}"
    puts

    # Load mapping data
    unless load_mapping_data
      return false
    end

    # Load markdown content
    unless File.exist?(@markdown_file)
      puts "Error: Markdown file #{@markdown_file} does not exist!"
      return false
    end

    markdown_content = File.read(@markdown_file)

    # Process replacements
    process_replacements(markdown_content)

    # Show summary
    print_summary

    # Write output if not dry run
    unless @dry_run
      if @replacements.any?
        File.write(@output_file, markdown_content)
        puts "\n✅ Updated markdown file: #{@output_file}"
      else
        puts "\n⚠️  No changes made - no matching images found"
      end
    end

    true
  end

  private

  def load_mapping_data
    unless File.exist?(@mapping_file)
      puts "Error: Mapping file #{@mapping_file} does not exist!"
      return false
    end

    begin
      @mapping_data = JSON.parse(File.read(@mapping_file))
      puts "Loaded #{@mapping_data['mappings'].length} image mappings"
      true
    rescue JSON::ParserError => e
      puts "Error: Invalid JSON in mapping file: #{e.message}"
      false
    end
  end

  def process_replacements(markdown_content)
    # Build filename to CDN URL mapping
    filename_to_cdn = {}
    @mapping_data['mappings'].each do |mapping|
      filename = mapping['original_filename']
      cdn_url = mapping['cdn_url']
      filename_to_cdn[filename] = cdn_url
    end

    # Find all image references in markdown
    # Pattern: ![alt text](path) where path contains the filename
    image_pattern = /!\[([^\]]*)\]\(([^)]+)\)/

    markdown_content.gsub!(image_pattern) do |match|
      alt_text = $1
      image_path = $2

      # Extract filename from path and decode URL encoding
      raw_filename = File.basename(image_path)
      filename = URI.decode_www_form_component(raw_filename)

      if filename_to_cdn.key?(filename)
        cdn_url = filename_to_cdn[filename]
        replacement = "![#{alt_text}](#{cdn_url})"

        @replacements << {
          original: match,
          replacement: replacement,
          filename: filename,
          cdn_url: cdn_url
        }

        puts "🔄 #{filename} -> #{cdn_url}" if @dry_run
        replacement
      else
        # No mapping found, keep original
        match
      end
    end
  end

  def print_summary
    puts "\n" + "="*60
    puts "REPLACEMENT SUMMARY"
    puts "="*60
    puts "Total image references found and replaced: #{@replacements.length}"

    if @replacements.any?
      puts "\nReplacements made:"
      @replacements.each_with_index do |replacement, index|
        puts "#{index + 1}. #{replacement[:filename]}"
        puts "   From: #{replacement[:original]}"
        puts "   To:   #{replacement[:replacement]}"
        puts
      end
    else
      puts "\nNo matching images found in the markdown file."
      puts "This could mean:"
      puts "- The image filenames don't match between the mapping and markdown"
      puts "- The markdown file doesn't contain image references"
      puts "- The image references use a different format"
    end
  end
end

# Run the replacer if this script is executed directly
if __FILE__ == $0
  # Parse command line arguments
  if ARGV.empty? || ARGV.include?('--help') || ARGV.include?('-h')
    puts "Usage: ruby script/replace_markdown_images.rb <mapping_file> <markdown_file> [options]"
    puts ""
    puts "Arguments:"
    puts "  mapping_file     JSON file with image mappings (from bulk upload script)"
    puts "  markdown_file    Markdown file to update with CDN URLs"
    puts ""
    puts "Options:"
    puts "  --output FILE    Output file (default: overwrites input file)"
    puts "  --dry-run        Show what would be replaced without making changes"
    puts "  --help, -h       Show this help message"
    puts ""
    puts "Examples:"
    puts "  # Replace images in devboard guide"
    puts "  ruby script/replace_markdown_images.rb devboard_cdn_mapping.json docs/guides/devboard.md"
    puts ""
    puts "  # Dry run to see what would be replaced"
    puts "  ruby script/replace_markdown_images.rb devboard_cdn_mapping.json docs/guides/devboard.md --dry-run"
    puts ""
    puts "  # Save to different file"
    puts "  ruby script/replace_markdown_images.rb mapping.json guide.md --output guide_updated.md"
    exit 0
  end

  mapping_file = ARGV[0]
  markdown_file = ARGV[1]

  unless mapping_file && markdown_file
    puts "Error: Please provide both mapping file and markdown file arguments"
    puts "Use --help for usage information"
    exit 1
  end

  # Parse optional arguments
  dry_run = ARGV.include?('--dry-run')
  output_file = nil

  if output_index = ARGV.index('--output')
    output_file = ARGV[output_index + 1] if ARGV[output_index + 1]
  end

  replacer = MarkdownImageReplacer.new(
    mapping_file: mapping_file,
    markdown_file: markdown_file,
    output_file: output_file,
    dry_run: dry_run
  )

  success = replacer.run
  exit(success ? 0 : 1)
end
