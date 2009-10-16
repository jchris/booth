require 'rubygems'
require 'sinatra'
require 'json'

$LOAD_PATH.unshift File.dirname(__FILE__)

mime :json, "application/json"

set :public, File.join(File.expand_path(File.dirname(__FILE__)),"..","public")

get '/' do
  {"couchdb"=>"Welcome","version"=>"0"}.to_json
end

load 'db_req.rb'

