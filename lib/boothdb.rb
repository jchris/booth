require 'rubygems'
require 'sinatra'
require 'json'
require 'cgi'

$LOAD_PATH.unshift File.dirname(__FILE__)

Booth ||= {}

mime :json, "application/json"

set :public, File.join(File.expand_path(File.dirname(__FILE__)),"..","public")

get '/' do
  {"couchdb"=>"Welcome","version"=>"0"}.to_json
end

load 'db_req.rb'
load 'doc_req.rb'

