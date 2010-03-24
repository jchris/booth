# render couchdb's classic JSON welcome screen
# this is where redirect to other servers would go
get '/' do
  j 200, "couchdb"=>"Welcome","version"=>"0"
end

# just a stub for the tests, as booth is in-memory only
post '/:db/_ensure_full_commit' do
  j 200, "ok" => true
end

# also stubs
post '/_restart' do
  j 200, "ok" => true
end
put '/_config/*' do
  j 200, "ok" => true
end
get '/_config/*' do
  j 200, "ok" => true
end


# the uuid service works just like couchdb
get "/_uuids" do
  uuid = BOOTH_UUID
  count = if params[:count]
    params[:count].to_i
  else
    1
  end
  uuids = (1..count).collect{uuid.generate}
  j(200, {"uuids" => uuids},{
    "Cache-Control" => "no-cache",
    "Pragma" => "no-cache",
    "Etag" => uuid.generate
  })
end


# json error handling
def je code, name, message
  j code, {"error" => name, "reason" => message}
end

# json ok handling
def j code, json, h = {}
  status code
  content_type "json"
  headers h
  json.to_json
end

def changes rows
  status 200
  content_type "json"
  "{\"results\":[\n#{change_rows(rows)}],\n\"last_seq\":#{rows.length}}\n"
end

def change_rows rows
  b = ""
  rows.each do |r|
    b = b + "#{r.to_json},\n"
  end
  b
end

# parse request
def jbody message = "Request body must be a JSON object"
  json = JSON.parse(request.body.read)
  if !json || json.is_a?(Array)
    raise BoothError.new(400, "bad_request", message);
  end
  json
end