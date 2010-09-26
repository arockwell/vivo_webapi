
#!/usr/bin/ruby

require 'rubygems'
require 'vivo_web_api'
require 'google_chart'

require '~/.vivo_auth.rb'

# Find the number of object of type person, publication and grants.

def count_by_type(hostname, username, password, type)
  client = VivoWebApi::Client.new(hostname)
  client.authenticate(username, password)

  sparql = <<-EOH
PREFIX rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#>

select (count(?subject) as ?count)
where 
{
    ?subject rdf:type #{type} 
} 
  EOH

  result = client.execute_sparql_select(username, password, sparql)
  result[0][:count].value
end

hostname = ENV['hostname'] 
username = ENV['username']
password = ENV['password']

types = { 'Faculty Member' => '<http://vivoweb.org/ontology/core#FacultyMember>',
  'Staff' => '<http://vivoweb.org/ontology/core#NonAcademic>',
  'Professor Emeritus' => '<http://vivoweb.org/ontology/core#EmeritusProfessor>',
  'Publication' => '<http://purl.org/ontology/bibo/Document>',
  'Grant' => '<http://vivoweb.org/ontology/core#Grant>'
}

types.each do |name, type|
  puts "#{name} count: #{count_by_type(hostname, username, password, type)}"
end
