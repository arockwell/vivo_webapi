#!/usr/bin/ruby

require 'rubygems'
require 'vivo_web_api'
require 'google_chart'

require '~/.vivo_auth.rb'

# Find the number of triples directly connceted to a person and generate 
# a graph showing the power law distribution.

hostname = ENV['hostname'] 
username = ENV['username']
password = ENV['password']

client = VivoWebApi::Client.new(hostname)
client.authenticate(username, password)

sparql = <<-EOH
PREFIX rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX core: <http://vivoweb.org/ontology/core#>

select ?person (count(?pred) as ?count_pred)
where 
{
    ?person ?pred ?o .
    ?person rdf:type core:FacultyMember .
           
} 
group by ?person
order by desc(?count_pred)
limit 500
EOH

results = client.execute_sparql_select(username, password, sparql)

data = []
results.each do |solution|
  data << solution[:count_pred].value.to_i
end

GoogleChart::LineChart.new('640x400', "Triples Directly Connected to a Person (first 500 people)", false) do |lc|
  lc.title_color = '000000'
  lc.data "Number of Triples", data, '0000ff'
  lc.show_legend = true
  lc.axis :y, :range => [0, 300], :color => '000000'
  lc.axis :x, :range => [1, 500], :color => '000000'
  puts lc.to_url
end

sparql = <<-EOH
PREFIX rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX core: <http://vivoweb.org/ontology/core#>
PREFIX rdfs:  <http://www.w3.org/2000/01/rdf-schema#>

select ?label (count(?pred) as ?count_pred)
where 
{
    ?person rdf:type core:Faculty .
    ?person ?pred ?o .
    ?pred rdfs:label ?label
}
group by ?label
having (?count_pred < 30)
order by desc(?count_pred)
EOH

results = client.execute_sparql_select(username, password, sparql)

preds = []
counts = []
results.each do |solution| 
  preds << solution[:label].value
  counts << solution[:count_pred].value.to_i
end

GoogleChart::BarChart.new('350x800', "Usage of predicates", :horizontal, false) do |bc|
  bc.title_color = '000000'
  bc.data "Number of Predicates", counts, '0000ff'
  bc.show_legend = true
  bc.axis :y, :color => '000000', :labels => preds
  bc.axis :x, :range => [1, 250], :color => '000000'
  puts bc.to_url
end
