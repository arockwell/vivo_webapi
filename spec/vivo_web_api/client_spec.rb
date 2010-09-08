require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module VivoWebApi
  describe Client do
    # This is a stub test, I'm not sure what assertion to make
    it "should log me in" do
      client = Client.new(ENV['hostname'])
      client.authenticate(ENV['username'], ENV['password'])
    end

    it "should execute a sparql select" do
      client = Client.new(ENV['hostname'])
      client.authenticate(ENV['username'], ENV['password'])
      # This is the example query vivo ships with
      sparql = <<-EOH
PREFIX rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs:  <http://www.w3.org/2000/01/rdf-schema#>
PREFIX core: <http://vivoweb.org/ontology/core#>

SELECT ?geoLocation ?label
WHERE
{
  ?geoLocation rdf:type core:GeographicLocation .
  OPTIONAL { ?geoLocation rdfs:label ?label }
}
LIMIT 20
      EOH
      results = client.execute_sparql_select(ENV['username'], ENV['password'], sparql)
      results.size.should == 20
    end

    it "should execute a sparql construct" do
      client = Client.new(ENV['hostname'])
      client.authenticate(ENV['username'], ENV['password'])
      # This is the example query vivo ships with
      sparql = <<-EOH
PREFIX rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs:  <http://www.w3.org/2000/01/rdf-schema#>
PREFIX core: <http://vivoweb.org/ontology/core#>

construct 
{
  ?geoLocation rdf:type core:GeographicLocation
}
WHERE
{
  ?geoLocation rdf:type core:GeographicLocation
}
LIMIT 20
      EOH
      results = client.execute_sparql_construct(ENV['username'], ENV['password'], sparql)
      results.subjects.size.should == 20
    end
  end
end
