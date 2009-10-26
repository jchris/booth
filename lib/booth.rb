require 'rubygems'

filepath = File.expand_path(File.dirname(__FILE__))

require File.join(filepath,"..","vendor","sinatra","lib","sinatra")

JS_SERVER_PATH = File.join(filepath,"query","server","main.js")

require 'json'
require 'cgi'
require 'uuid'

$LOAD_PATH.unshift filepath
$LOAD_PATH.unshift File.join(filepath,"httpd")
$LOAD_PATH.unshift File.join(filepath,"query")
$LOAD_PATH.unshift File.join(filepath,"store")

require 'database'

Booth ||= {}

class BoothError < StandardError
  attr_reader :code
  def initialize code, error, reason
    @code = code
    @error = error
    @reason = reason
  end
  def to_json
    to_hash.to_json
  end
  def to_hash
    {"error" => @error, "reason" => @reason}
  end
end

# TODO Help! I want code reloading during dev.

set :public, File.join(filepath,"..","public")
set :show_exceptions, false
set :raise_errors, false

error(BoothError) do
  be =  @env['sinatra.error']
  [be.code, {}, be.to_json]
end

error(Sinatra::NotFound) do
  [404, {}, {"error"=>"not_found"}.to_json]
end

load 'global.rb'
load 'db.rb'
load 'doc.rb'
load 'view.rb'

