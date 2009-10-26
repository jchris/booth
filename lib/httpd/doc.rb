# document access
get "/:db/:docid/?" do
  docid = params[:docid]
  with_db(params[:db]) do |db|
    doc = db.get(docid)
    if doc
      j(200, doc)
    else
      je(404, 'not_found', "No doc with id: #{docid}")
    end
  end
end

post "/:db/?" do
  with_db(params[:db]) do |db|
    doc = jbody("Document must be a JSON object")
    if !doc["_id"]
      uuid = UUID.new
      doc["_id"] = uuid.generate
    end
    rev = db.put(doc)
    j(201, {"ok" => true,
      :id => doc["_id"],
      :rev => rev},{
        "Location" => ["",params[:db],doc["_id"]].join('/')
      })
  end
end

put "/:db/:docid/?" do
  docid = params[:docid]
  with_db(params[:db]) do |db|
    doc = jbody("Document must be a JSON object")
    doc["_id"] = docid
    rev = db.put(doc)
    j(201, {"ok" => true,
      :id => docid,
      :rev => rev},{
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
get "/:db/:docid/:att?" do
  docid = params[:docid]
  with_db(params[:db]) do |db|
    doc = db.get(docid)
    if doc
      att = doc.attachment(params[:att])
      headers({
        "content-type" => att["content_type"],
        "Etag" => doc.etag
        })
      att["data"]
    else
      je(404, 'not_found', "No doc with id: #{docid}")
    end
  end
end

put "/:db/:docid/:att?" do
  docid = params[:docid]
  rev = params[:rev]
  with_db(params[:db]) do |db|
    doc = db.get(docid)
    if doc
      puts 'd'*40
      puts doc.rev
      att = {}
      att["data"] = request.body.read
      att["content_type"] =  @env["CONTENT_TYPE"]
      doc.attachment_put(params[:att], att)
      new_rev = db.put(doc)
      headers("Location" => ["",params[:db],docid,params[:att]].join('/'))
      j(201, {"ok" => true, :id => docid, :rev => new_rev})
    else
      je(404, 'not_found', "No doc with id: #{docid}")
    end
  end
end