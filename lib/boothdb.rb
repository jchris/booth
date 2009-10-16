require 'rubygems'

require File.join(File.expand_path(File.dirname(__FILE__)),"..","vendor","sinatra","lib","sinatra")


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

load 'db_req.rb'
load 'doc_req.rb'

