#!/usr/bin/ruby

require 'rubygems'
require 'vivo_web_api'

require '~/.vivo_auth.rb'
# Extract all people in the department, along with all statements about those
# people and all statements about their authorships.
#
# TODO: Add a construct that grabs all statements about their publications.
#

def extract_department(dept_uri, vivo_loc, username, password)
  client = VivoWebApi::Client.new(vivo_loc)
  client.authenticate(username, password)

  person_construct = <<-EOH
PREFIX rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs:  <http://www.w3.org/2000/01/rdf-schema#>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>
PREFIX core: <http://vivoweb.org/ontology/core#>

construct { 
  ?person core:personInPosition ?pos .
  ?person foaf:firstName ?firstName .
  ?person foaf:lastName ?lastName .
  ?person core:authorInAuthorship ?authorship .
  ?person rdf:type ?type .
  ?person rdfs:label ?label 
}
where {
  <#{dept_uri}> core:organizationForPosition ?pos .
  ?person core:personInPosition ?pos .

  ?person foaf:firstName ?firstName .
  ?person foaf:lastName ?lastName .
  ?person rdf:type ?type .
  ?person rdfs:label ?label .

  optional { ?person core:authorInAuthorship ?authorship }
}
  EOH

  authorship_construct = <<-EOH
PREFIX rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs:  <http://www.w3.org/2000/01/rdf-schema#>
PREFIX core: <http://vivoweb.org/ontology/core#>

construct { 
  ?authorship core:linkedAuthor ?person .
  ?authorship core:authorRank ?authorRank .
  ?authorship core:linkedInformationResource ?publication .

  ?authorship rdf:type ?type .
  ?authorship rdfs:label ?label 
}
where {
  <#{dept_uri}> core:organizationForPosition ?pos .
  ?person core:personInPosition ?pos .

  ?authorship core:linkedAuthor ?person .
  ?authorship core:linkedInformationResource ?publication .

  ?authorship rdf:type ?type .
  optional { ?authorship rdfs:label ?label }
  optional { ?authorship core:authorRank ?authorRank }
}
  EOH

  publication_construct = <<-EOH
PREFIX rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs:  <http://www.w3.org/2000/01/rdf-schema#>
PREFIX core: <http://vivoweb.org/ontology/core#>
PREFIX bibo: <http://purl.org/ontology/bibo/>

construct {
  ?publication rdf:type ?type .
  ?publication rdfs:label ?label . 

  ?authorship core:linkedInformationResource ?publication .
  ?publication core:informationResourceInAuthorship ?authorship .
  ?publication bibo:pageStart ?pageStart .
  ?publication bibo:pageEnd ?pageEnd .
  ?publication bibo:volume ?volume .
  ?publication bibo:issue ?issue .
  ?publication core:yearMonth ?yearMonth .
  ?publication core:doi ?doi
}
where {
  <#{dept_uri}> core:organizationForPosition ?pos .
  ?person core:personInPosition ?pos .
  ?person core:authorInAuthorship ?authorship .
  ?authorship core:linkedInformationResource ?publication .

  ?publication rdf:type ?type .
  ?publication rdfs:label ?label . 

  ?authorship core:linkedInformationResource ?publication .
  ?publication core:informationResourceInAuthorship ?authorship .
  optional { ?publication bibo:pageStart ?pageStart }
  optional { ?publication bibo:pageEnd ?pageEnd }
  optional { ?publication bibo:volume ?volume }
  optional { ?publication bibo:issue ?issue }
  optional { ?publication core:yearMonth ?yearMonth }
  optional { ?publication core:doi ?doi }
}
  EOH

  person_results = client.execute_sparql_construct(username, password, 
                                            person_construct)
  authorship_results = client.execute_sparql_construct(username, password, 
                                            authorship_construct)
  publication_results = client.execute_sparql_construct(username, password, 
                                                        publication_construct)

  results = []
  person_results.each do |statement| 
    results << statement
  end

  authorship_results.each do |statement| 
    results << statement
  end

  publication_results.each do |statement| 
    results << statement
  end

  return results
end
  

dept_uris = [
  "http://vivo.ufl.edu/individual/individual511219679", # MGM
  "http://vivo.ufl.edu/individual/individual1413831214", # Otolaryngology
  "http://vivo.ufl.edu/individual/individual2030376853", # Biology
  "http://vivo.ufl.edu/individual/EntomologyandNematology" # Entomology
]

hostname = ENV['hostname'] 
username = ENV['username']
password = ENV['password']

results = []

dept_uris.each do |dept_uri|
  results = results + extract_department(dept_uri, hostname, username, password)
end

RDF::Writer.open("test.nt") do |writer|
  results.each do |result|
    writer << result
  end
end
