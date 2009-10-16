require 'rubygems'

filepath = File.expand_path(File.dirname(__FILE__))

require File.join(filepath,"..","vendor","sinatra","lib","sinatra")

JS_SERVER_PATH = File.join(filepath,"query","server","main.js")

require 'json'
require 'cgi'

$LOAD_PATH.unshift filepath
$LOAD_PATH.unshift File.join(filepath,"httpd")
$LOAD_PATH.unshift File.join(filepath,"query")
$LOAD_PATH.unshift File.join(filepath,"store")

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

load 'global_req.rb'
load 'db_req.rb'
load 'doc_req.rb'
load 'view_req.rb'

