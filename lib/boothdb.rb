require 'rubygems'
require 'sinatra'

COUCHDB_SHARE = File.join(File.expand_path(File.dirname(__FILE__)),"..","share")

get '/' do
'  {"boothdb"=>"Welcome","version"=>"0"}'
end
