# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

desc "Build and publish the gem"
task publish: %w[build release:rubygem_push]

RSpec::Core::RakeTask.new(:spec)

require "rubocop/rake_task"

RuboCop::RakeTask.new

task default: %i[spec rubocop]
