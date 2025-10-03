#!/usr/bin/env ruby

require 'net/http'
require 'uri'
require 'json'
require 'fileutils'
require 'cgi'

class BulkImageUploader
  BUCKY_URL = 'https://bucky.hackclub.com'
  CDN_URL = 'https://cdn.hackclub.com/api/v3/new'
  CDN_TOKEN = 'beans'

  def initialize(images_dir:, output_file: nil, test_mode: false, limit: nil)
    @images_dir = File.expand_path(images_dir)
    @output_file = output_file || generate_output_filename
    @results = []
    @failed_uploads = []
    @test_mode = test_mode
    @limit = limit
  end

  def run
    puts "Starting bulk image upload process..."
    puts "Images directory: #{@images_dir}"
    puts "Output file: #{@output_file}"
    puts "Test mode: #{@test_mode ? 'ON' : 'OFF'}"

    unless Dir.exist?(@images_dir)
      puts "Error: Directory #{@images_dir} does not exist!"
      return false
    end

    image_files = Dir.glob(File.join(@images_dir, '*.{png,jpg,jpeg,gif,svg}'))

    if @limit
      image_files = image_files.first(@limit)
      puts "Limited to first #{@limit} images for testing"
    end

    puts "Found #{image_files.length} images to process"

    if image_files.empty?
      puts "No images found in #{@images_dir}"
      return false
    end

    image_files.each_with_index do |image_path, index|
      puts "\n[#{index + 1}/#{image_files.length}] Processing: #{File.basename(image_path)}"
      process_image(image_path)
    end

    generate_output_file
    print_summary
    true
  end

  private

  def process_image(image_path)
    begin
      # Step 1: Upload to Bucky
      bucky_url = upload_to_bucky(image_path)
      unless bucky_url
        @failed_uploads << {
          filename: File.basename(image_path),
          error: "Failed to upload to Bucky"
        }
        return
      end

      # Step 2: Upload to CDN using Bucky URL
      cdn_info = upload_to_cdn(bucky_url)
      unless cdn_info
        @failed_uploads << {
          filename: File.basename(image_path),
          error: "Failed to upload to CDN"
        }
        return
      end

      # Store the mapping
      @results << {
        original_filename: File.basename(image_path),
        original_path: image_path,
        bucky_url: bucky_url,
        cdn_url: cdn_info['deployedUrl'],
        cdn_file: cdn_info['file'],
        sha: cdn_info['sha'],
        size: cdn_info['size']
      }

      puts "✓ Successfully uploaded and got CDN URL: #{cdn_info['deployedUrl']}"

    rescue => e
      puts "✗ Error processing #{File.basename(image_path)}: #{e.message}"
      puts "  Stack trace: #{e.backtrace.first(3).join(', ')}" if @test_mode
      @failed_uploads << {
        filename: File.basename(image_path),
        error: e.message
      }
    end
  end

  def upload_to_bucky(image_path)
    uri = URI.parse(BUCKY_URL)

    File.open(image_path, 'rb') do |file|
      request = Net::HTTP::Post.new(uri)
      form_data = [ [ 'file', file, { filename: File.basename(image_path) } ] ]
      request.set_form(form_data, 'multipart/form-data')

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
        http.request(request)
      end

      if response.code == '200'
        bucky_url = response.body.strip

        # Fix the malformed URL encoding from Bucky
        if bucky_url.include?('%!i(MISSING)mage%!(NOVERB)')
          # Extract the base URL and hash part
          url_parts = bucky_url.split('/')
          base_url = url_parts[0..-2].join('/')
          filename = File.basename(image_path)
          encoded_filename = CGI.escape(filename)
          bucky_url = "#{base_url}/#{encoded_filename}"
          puts "  → Fixed malformed Bucky URL" if @test_mode
        end

        puts "  → Raw Bucky response: #{response.body.inspect}" if @test_mode
        puts "  → Final Bucky URL: #{bucky_url.inspect}" if @test_mode
        puts "  → Uploaded to Bucky: #{bucky_url}"
        return bucky_url
      else
        puts "  ✗ Bucky upload failed: #{response.code} - #{response.body}"
        return nil
      end
    end
  rescue => e
    puts "  ✗ Bucky upload error: #{e.message}"
    nil
  end

  def upload_to_cdn(bucky_url)
    uri = URI.parse(CDN_URL)

    # The Bucky URL should be used as-is since it's properly encoded
    puts "  → Using Bucky URL for CDN: #{bucky_url}" if @test_mode

    request = Net::HTTP::Post.new(uri)
    request['Authorization'] = "Bearer #{CDN_TOKEN}"
    request['Content-Type'] = 'application/json'
    request.body = [ bucky_url ].to_json

    puts "  → CDN request body: #{request.body}" if @test_mode

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(request)
    end

    puts "  → CDN response code: #{response.code}" if @test_mode
    puts "  → CDN response body: #{response.body}" if @test_mode

    if response.code == '200'
      cdn_response = JSON.parse(response.body)
      if cdn_response['files'] && cdn_response['files'].first
        cdn_info = cdn_response['files'].first
        puts "  → Uploaded to CDN: #{cdn_info['deployedUrl']}"
        cdn_info
      else
        puts "  ✗ CDN response missing file info: #{response.body}"
        nil
      end
    else
      puts "  ✗ CDN upload failed: #{response.code} - #{response.body}"
      nil
    end
  rescue => e
    puts "  ✗ CDN upload error: #{e.message}"
    nil
  end

  def generate_output_file
    output_data = {
      timestamp: Time.now.iso8601,
      source_directory: @images_dir,
      total_images: @results.length + @failed_uploads.length,
      successful_uploads: @results.length,
      failed_uploads: @failed_uploads.length,
      mappings: @results,
      failures: @failed_uploads
    }

    File.write(@output_file, JSON.pretty_generate(output_data))
    puts "\n📄 Output file generated: #{@output_file}"
  end

  def print_summary
    puts "\n" + "="*50
    puts "UPLOAD SUMMARY"
    puts "="*50
    puts "Total images processed: #{@results.length + @failed_uploads.length}"
    puts "Successful uploads: #{@results.length}"
    puts "Failed uploads: #{@failed_uploads.length}"

    if @failed_uploads.any?
      puts "\nFailed uploads:"
      @failed_uploads.each do |failure|
        puts "  - #{failure[:filename]}: #{failure[:error]}"
      end
    end

    puts "\nJSON mapping file saved to: #{@output_file}"
  end

  private

  def generate_output_filename
    base_name = File.basename(@images_dir).gsub(/[^a-zA-Z0-9_-]/, '_')
    timestamp = Time.now.strftime('%Y%m%d_%H%M%S')
    "#{base_name}_image_mapping_#{timestamp}.json"
  end
end

# Run the uploader if this script is executed directly
if __FILE__ == $0
  # Parse command line arguments
  if ARGV.empty? || ARGV.include?('--help') || ARGV.include?('-h')
    puts "Usage: ruby script/bulk_upload_images.rb <images_directory> [options]"
    puts ""
    puts "Arguments:"
    puts "  images_directory    Path to directory containing images to upload"
    puts ""
    puts "Options:"
    puts "  --output FILE       Output JSON file path (default: auto-generated)"
    puts "  --test              Enable test mode with debugging output"
    puts "  --limit N           Limit processing to first N images"
    puts "  --help, -h          Show this help message"
    puts ""
    puts "Examples:"
    puts "  ruby script/bulk_upload_images.rb app/assets/images/devboard"
    puts "  ruby script/bulk_upload_images.rb /path/to/images --test --limit 5"
    puts "  ruby script/bulk_upload_images.rb images/ --output my_mapping.json"
    exit 0
  end

  images_dir = ARGV[0]
  unless images_dir
    puts "Error: Please provide a directory path as the first argument"
    puts "Use --help for usage information"
    exit 1
  end

  # Parse optional arguments
  test_mode = ARGV.include?('--test')
  limit = nil
  output_file = nil

  if test_index = ARGV.index('--limit')
    limit = ARGV[test_index + 1].to_i if ARGV[test_index + 1]
  end

  if output_index = ARGV.index('--output')
    output_file = ARGV[output_index + 1] if ARGV[output_index + 1]
  end

  uploader = BulkImageUploader.new(
    images_dir: images_dir,
    output_file: output_file,
    test_mode: test_mode,
    limit: limit
  )

  success = uploader.run
  exit(success ? 0 : 1)
end
