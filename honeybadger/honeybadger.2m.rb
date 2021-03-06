#!/usr/bin/env ruby

# <bitbar.title>Honeybadger Fault Monitor</bitbar.title>
# <bitbar.version>v1.2</bitbar.version>
# <bitbar.author>Greg Fox</bitbar.author>
# <bitbar.author.github>greg-fox</bitbar.author.github>
# <bitbar.desc>Watches for faults in Honeybadger.</bitbar.desc>
# <bitbar.dependencies>ruby</bitbar.dependencies>

require 'net/http'
require 'uri'
require 'open-uri'
require 'json'
require 'digest'

# <bitbar.settings>

# Honeybadger API access token (https://codeship.com/user/edit)
HONEYBADGER_ACCESS_TOKEN=''
HONEYBADGER_PROJECT_ID=''

# </bitbar.settings>

HONEYBADGER_BASE_URL = 'https://app.honeybadger.io'
HONEYBADGER_FAULTS_API = "#{HONEYBADGER_BASE_URL}/v1/projects/#{HONEYBADGER_PROJECT_ID}/faults?auth_token=#{HONEYBADGER_ACCESS_TOKEN}&resolved=f&ignored=f&order=frequent"
HONEYBADGER_FAULT_URI = "#{HONEYBADGER_BASE_URL}/projects/#{HONEYBADGER_PROJECT_ID}/faults/FAULT_ID"

def fault_info
  response = Net::HTTP.get_response(URI.parse(HONEYBADGER_FAULTS_API))
  JSON.parse(response.body)['results']
end

def format_tickets(fault)
  return unless fault['tickets']
  fault['tickets'].each do |ticket|
    puts "Jira #{ticket.split('/').last} | size=10 href=#{ticket} color=yellow"
  end
end

def format_output(fault)
  fault_link = HONEYBADGER_FAULT_URI.gsub('FAULT_ID', fault['id'].to_s)
  puts "Fault #{fault['klass']}  #{fault['component']}/##{fault['action']} | size=12 href=#{fault_link} color=red"
  puts "Instance Count: #{fault['notices_count']} | size=12 href=#{fault_link} color=red"
  puts "#{fault['message']} | size=10 color=green"

  format_tickets(fault)
  separator
end


def separator
  puts '---'
end

def overall_status(fault_list)
  puts "HoneyBadger(#{fault_list.size})"
end

begin
  faults = fault_info
  overall_status(faults)
  separator
  faults.each do |fault|
    format_output(fault)
  end
end
