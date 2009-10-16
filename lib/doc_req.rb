


get "/:db/:docid/?" do
  docid = params[:docid]
  with_db(params[:db]) do |db|
    doc = db[docid]
    if doc
      j(200, doc)
    else
      je(404, 'not_found', "No doc with id: #{docid}")
    end
  end
end

put "/:db/:docid/?" do
  docid = params[:docid]
  with_db(params[:db]) do |db|
    doc = JSON.parse(request.body.read)
    rev = "foo"
    db[docid] = doc.merge({
      "_id" => docid,
      "_rev" => "foo"
    })
    j(201, {"ok" => true,
      :id => docid,
      :rev => rev})
  end
end

delete "/:db/:docid/?" do
  docid = params[:docid]
  with_db(params[:db]) do |db|
    doc = db[docid]
    if doc
      db.delete(docid)
      j(200, {"ok" => true})
    else
      je(404, 'not_found', "No doc with id: #{docid}")
    end
  end
end