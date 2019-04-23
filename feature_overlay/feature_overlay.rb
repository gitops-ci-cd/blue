#!/usr/bin/env ruby
# frozen_string_literal: true

require 'slop'
# require 'byebug'
require '/creation.rb'
require '/cleanup.rb'
Dir["/templates/*.rb"].each { |file| require file }

$opts = Slop.parse do |o|
  o.banner = 'usage: feature_overlay [options]'
  o.separator 'example: feature_overlay --service my-service --cluster-repo my-company/my-cluster --target-image my-company/my-service'
  o.separator ''
  o.separator 'options:'
  o.string '-s', '--service', 
    'the service to deploy to your cluster', required: true
  o.string '-r', '--cluster-repo', 
    'GitHub repository that controls your cluster', required: true
  o.string '-i', '--target-image', 
    'remotely hosted target image', required: true
  o.string '-n', '--namespace', 
    'desired namespace, or inferred from GITHUB_REF', default: ENV['GITHUB_REF']&.split('/')&.reject{ |i| %w(refs heads).include? i }&.join('-') # TODO: include special chars
  o.string '-t', '--tag', 
    'image tag, or inferred from GITHUB_SHA', default: ENV['GITHUB_SHA']&.[](0..6)
  o.string '-g', '--github-token', 
    'GitHub token, or taken from GITHUB_TOKEN', default: ENV['GITHUB_TOKEN']
  o.string '-e', '--github-event',
    'GitHub event to perform', default: ENV['GITHUB_EVENT_NAME']
  o.string '-f', '--env-file', 
    'location of environment file', default: File.join(Dir.home.to_s, '.profile')
end

def exit_code(message, number)
  puts
  puts message
  puts
  puts $opts
  puts
  exit number
end

# ensure we have all the appropriate parameters to proceed
arguments = [$opts[:namespace], $opts[:tag]]
exit_code('Missing required arguments', 2) unless arguments.all? 

case $opts[:github_event]
when 'closed'
  Cleanup.perform
else
  Creation.perform
end