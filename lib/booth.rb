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

set :public, File.join(filepath,"..","public")


load 'global.rb'
load 'db.rb'
load 'doc.rb'
load 'view.rb'

