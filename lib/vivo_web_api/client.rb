require 'mechanize'
require 'digest/md5'

module VivoWebApi
  class Client
    class << self
      def authenticate(username, password)
        agent = Mechanize.new
        password = Digest::MD5.hexdigest(password).upcase
        agent.post('http://vivo.ufl.edu/login_process.jsp', {
          'home' => '1',
          'loginName' => username,
          'loginPassword' => password,
          'loginSubmitMode' => 'Log in'
        })
        return agent
      end

      def execute_sparql_select(username, password, sparql)
        agent = authenticate(username, password)
        format = 'RS_XML'
        page = agent.get('http://vivo.ufl.edu/admin/sparqlquery',
                         { :query => sparql, :resultFormat => format })
        client = SPARQL::Client.new('http://vivo.ufl.edu')
        return client.parse_xml_bindings(page.body)
      end
    end
  end
end
