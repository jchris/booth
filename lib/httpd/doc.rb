# document access
get "/:db/:docid/?" do
  docid = params[:docid]
  with_db(params[:db]) do |db|
    doc = db.get(docid)
    etag(doc.etag)
    if doc
      jdoc = if params[:attachments] == "true"
        doc.with_attachments
      else
        doc.with_stubs
      end
      j(200, jdoc)
    else
      je(404, 'not_found', "No doc with id: #{docid}")
    end
  end
end

post "/:db/?" do
  with_db(params[:db]) do |db|
    doc = jbody("Document must be a JSON object")
    if !doc["_id"]
      doc["_id"] = BOOTH_UUID.generate
    end
    resp = db.put(doc)
    resp["ok"] = true
    j(201, resp, {
        "Location" => ["",params[:db],doc["_id"]].join('/')
      })
  end
end

put "/:db/:docid/?" do
  docid = params[:docid]
  with_db(params[:db]) do |db|
    doc = jbody("Document must be a JSON object")
    doc["_id"] = docid
    resp = db.put(doc)
    resp["ok"] = true
    j(201, resp, {
        "Location" => ["",params[:db],docid].join('/')
      })
  end
end

delete "/:db/:docid/?" do
  docid = params[:docid]
  rev = params[:rev]
  with_db(params[:db]) do |db|
    doc = db.get(docid)
    if doc
      new_rev = db.delete(docid, rev)
      j(200, {"ok" => true, :id => docid, :rev => new_rev})
    else
      je(404, 'not_found', "No doc with id: #{docid}")
    end
  end
end

# attachment handling

def docid_att_name(params)
  if params[:docid] == "_design"
    ps = params[:splat][0].split('/')
    ["_design/#{ps.shift}", ps.join('/')]
  else
    [params[:docid], params[:splat][0]]    
  end
end


get "/:db/:docid/*" do
  docid, att_name = docid_att_name(params)
  # docid = params[:docid]
  # att_name = params[:splat][0]
  with_db(params[:db]) do |db|
    doc = db.get(docid)
    etag(doc.rev)
    att = doc.attachment(att_name)
    headers({
      "content-type" => att["content_type"],
      "Etag" => doc.etag
      })
    att["data"]
  end
end

put "/:db/:docid/*" do
  docid = params[:docid]
  rev = params[:rev]
  att_name = params[:splat][0]
  with_db(params[:db]) do |db|
    begin
      doc = db.get(docid)
    rescue BoothError
      db.put({"_id" => docid})
      doc = db.get(docid)
      rev = doc.rev
    end
    att = {}
    att["data"] = request.body.read
    att["length"] = att["data"].length
    att["content_type"] =  @env["CONTENT_TYPE"]
    new_rev = doc.attachment_put(rev, att_name, att)
    headers("Location" => ["",params[:db],docid,att_name].join('/'))
    j(201, {"ok" => true, :id => docid, :rev => new_rev})
  end
end

delete "/:db/:docid/*" do
  docid = params[:docid]
  rev = params[:rev]
  att_name = params[:splat][0]
  with_db(params[:db]) do |db|
    doc = db.get(docid)
    new_rev = doc.attachment_put(rev, att_name, nil)
    # headers("Location" => ["",params[:db],docid,att_name].join('/'))
    j(200, {"ok" => true, :id => docid, :rev => new_rev})
  end
end