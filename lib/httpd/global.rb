
get '/' do
  j 200, "couchdb"=>"Welcome","version"=>"0"
end


get "/_uuids" do
  uuid = UUID.new
  uuids = (1..10).collect{uuid.generate}
  j(200, {"uuids" => uuids})
end


# json error
def je code, name, message
  j code, {"error" => name, "reason" => message}
end

def j code, json
  status code
  content_type "json"
  json.to_json
end