require 'open-uri'
require 'cgi'
require 'json'
require 'pp'

require 'net/http'
require 'net/https'

DEBUG = true

module Neurogami
  module Todoist

    # May want an Item class at some point ...
    class Query
      include Constants

      def self.qs_to_str qs
        
        a= []
        qs.each do |k, v|
          a  << "#{k}=#{v}"
        end

        a.join ';'

      end

      def self.debuggery s
        if DEBUG
          warn "* * * *    #{s}  * * * * "
        end

      end

      def self.get_token
        '270cab3140600925484e23ef8a4c8958466aa238'
      end

      # It would be nice to have a nicer UI than the user having to know this or that option
      # Following queries are supported: viewall, overdue, p1, p2, p3
      def self.run query_set, token
        #    * queries: A JSON string list of queries. Date format is 2007-4-29T10:59. 
        #    Following queries are supported: viewall, overdue, p1, p2, p3
        # Example:
        # http://todoist.com/API/query?queries=["2007-4-29T10:13","overdue","p1","p2"]&token=x2601ec5xxxxxxxxxxxxx573e908xxxa272e5 
        query_set.map!do |q|
          case q.class.to_s
          when 'Time'
            timestamp_to_querydate q
          when 'Symbol'
            q.to_s
          else
            q
          end
        end
        query_set_to_json = query_set.to_json

        _url = "#{BASE_URL_HTTPS}/query?queries=#{query_set_to_json}&token=#{token}"

        query = CGI.escape(query_set_to_json)
        #query = query_set_to_json
        url = "#{BASE_URL}/query?queries=#{query}&token=#{token}"
        
        debuggery "url is '#{url}'"
        #json = https_get url # open( _url ).read
        json = open( url ).read
        results = JSON.parse json

        # We get an array of hashes: type => data, where type is the query.
        #      [{"type"=>"overdue",
        #        "data"=>
        #          [{"checked"=>0,
        #            "project_id"=>501517,
        #            "collapsed"=>0,


        results.map do |result|
          { "type" => result["type"], "data" => result["data"].map{ |i| Item.new(i) } }     
        end
      end

      def self.timestamp_to_querydate time
        "#{time.year}-#{time.mon}-#{time.day}T#{time.hour}:#{time.min}"
      end


      def self.https_get url
        uri = URI.parse url
       https = Net::HTTP.new uri.host,uri.port
       https.use_ssl = true
       req = Net::HTTP::Get.new uri.path

       res = https.request(req)
        res.body
      end
    end
  end
end

