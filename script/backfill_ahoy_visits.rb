#!/usr/bin/env ruby
# Simple wrapper to run the ahoy backfill rake task from Ruby
require_relative File.expand_path('../../config/environment', __FILE__)
require 'rake'
Rails.application.load_tasks

task = Rake::Task['ahoy:backfill_visits']
task.reenable
task.invoke
