require 'rubygems'

require File.join(File.expand_path(File.dirname(__FILE__)),"..","vendor","sinatra","lib","sinatra")

JS_SERVER_PATH = File.join(File.expand_path(File.dirname(__FILE__)),"..","server","main.js")

require 'json'
require 'cgi'

$LOAD_PATH.unshift File.dirname(__FILE__)

Booth ||= {}

# TODO Help! I want code reloading during dev.

# mime :json, "application/json"

set :public, File.join(File.expand_path(File.dirname(__FILE__)),"..","public")


# json error
def je code, name, message
  j code, {"error" => name, "reason" => message}
end

def j code, json
  status code
  content_type "json"
  json.to_json
end

get '/' do
  j 200, "couchdb"=>"Welcome","version"=>"0"
end

require 'uuid'
get "/_uuids" do
  uuid = UUID.new
  uuids = (1..10).collect{uuid.generate}
  j(200, {"uuids" => uuids})
end


load 'db_req.rb'
load 'doc_req.rb'
load 'view_req.rb'

