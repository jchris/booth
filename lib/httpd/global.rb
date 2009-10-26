
get '/' do
  j 200, "couchdb"=>"Welcome","version"=>"0"
end

post '/:db/_ensure_full_commit' do
  j 200, "ok" => true
end

post '/_restart' do
  j 200, "ok" => true
end

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


# json error
def je code, name, message
  j code, {"error" => name, "reason" => message}
end

def j code, json, h = {}
  status code
  content_type "json"
  headers h
  json.to_json
end

def jbody message = "Request body must be a JSON object"
  json = JSON.parse(request.body.read)
  if !json || json.is_a?(Array)
    raise BoothError.new(400, "bad_request", message);
  end
  json
end