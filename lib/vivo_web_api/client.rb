require 'rubygems'

require 'sparql/client'
require 'mechanize'
require 'digest/md5'

module VivoWebApi
  class Client
    attr_accessor :base_url

    def initialize(base_url)
      @base_url = base_url
    end

    def authenticate(username, password)
      agent = Mechanize.new
      # must access the login page to setup the cookie before issuing a post
      agent.get("#{@base_url}/siteAdmin")
      agent.post("#{@base_url}/authenticate?home=1&login=block", { 
        'loginName' => username,
        'loginPassword' => password,
        'loginForm' => 'Log in'
      })
      return agent
    end

    def execute_sparql_select(username, password, sparql, format='RS_XML')
      agent = authenticate(username, password)
      page = agent.get("#{@base_url}/admin/sparqlquery",
                       { :query => sparql, :resultFormat => format })
      client = SPARQL::Client.new('http://vivo.ufl.edu')
      if format == 'RS_XML'
        return client.parse_xml_bindings(page.body)
      elsif format == 'RS_JSON'
        return client.parse_json_bindings(page.body)
      end
    end

    def execute_sparql_construct(username, password, sparql, format='N-TRIPLE')
      agent = authenticate(username, password)
      page = agent.get("#{@base_url}/admin/sparqlquery",
                       { :query => sparql, :resultFormat => 'RS_TEXT', :rdfResultFormat => format })
      results = RDF::Graph.new
      RDF::Reader.for(:ntriples).new(page.body) do |reader|
        reader.each_statement do |statement|
          results << statement
        end
      end
      return results
    end
  end
end
