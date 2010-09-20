#!/usr/bin/ruby 

require 'rubygems'
require 'vivo_web_api'

require '~/.vivo_auth.rb'

# Attempt to match a uri to a glid. 
# Consider any email address of the form name@ufl.edu to be a glid.

sparql = <<-EOH
PREFIX core: <http://vivoweb.org/ontology/core#>

select ?person ?workEmail
where
{
  ?person core:workEmail ?workEmail
}
EOH

hostname = ENV['hostname'] 
username = ENV['username']
password = ENV['password']

client = VivoWebApi::Client.new(hostname)
client.authenticate(username, password)
results = client.execute_sparql_select(username, password, sparql)

results.each do |result| 
  result = result.to_hash
  person = result[:person].to_s.match(/http:\/\/vivo.ufl.edu\/individual\/(.*)/)[1]
  if result[:workEmail].value.match(/(.*)@ufl.edu$/) != nil
    email = result[:workEmail].value.match(/(.*)@ufl.edu$/)[1]
      puts "#{email} #{person}"
    end
end
