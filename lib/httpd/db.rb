
# a magic block that gets your db for you.
def with_db db
  if Booth[db]
    yield Booth[db]
  else
    je(404, "not_found", "No database: #{db}")
  end
end

# for futon
get "/_all_dbs/?" do
  a=[]
  Booth.each do |k, v|
    a << k
  end
  j(200, a)
end

# create a database
put "/:db/?" do
  db = params[:db]
  if Booth[db]
    je(412, "db_exists", "The database already exists.")
  else
    Booth[db] = Database.new
    j(201, {"ok" => true}, {"Location" => "/#{CGI.escape(db)}"})
  end
end

# get database info
get "/:db/?" do
  with_db(params[:db]) do |db|
    j(200, {
      :db_name => params[:db],
      :doc_count => db.doc_count,
      :disk_size => (db.doc_count * 339.2)
    })    
  end
end

# delete a database
delete "/:db/?" do
  db = params[:db]
  if Booth[db]
    Booth.delete(db)
    j(200, {"ok" => true})
  else
    je(404, "not_found", "No database: #{db}")
  end
end

# upload docs in batch
post "/:db/_bulk_docs" do
  with_db(params[:db]) do |db|
    j = jbody
    docs = j["docs"]
    params[:all_or_nothing] = "true" if j["all_or_nothing"]
    results = docs.collect do |doc|
      if !doc["_id"]
        doc["_id"] = BOOTH_UUID.generate
      end
      begin
        db.put(doc, params)
      rescue BoothError => e
        e
      end
    end
    j(200, results)
  end
end

# view of all docs in the database
get "/:db/_all_docs" do
  with_db(params[:db]) do |db|
    rows = []
    db.all_docs(View.view_params(params)) do |docid, doc|
      rows << {
        "id" => docid,
        "key" => docid,
        "value" => {
          "rev" => doc.rev
        }
      }
    end
    j(200, {"rows" => rows,"total_rows" => db.doc_count})
  end
end
post "/:db/_all_docs" do
  with_db(params[:db]) do |db|
    query = jbody
    unless query["keys"].is_a?(Array)
      raise BoothError.new(400, "bad_request", "`keys` member must be a array.");
    end
  end
end


# feed of changes to the database
get "/:db/_changes" do
  with_db(params[:db]) do |db|
    rows = []
    db.by_seq(params) do |seq, doc|
      r = {
        "id" => doc.id,
        "seq" => seq,
        "changes" => [{
          "rev" => doc.rev
        }]
      }
      if params[:include_docs] == "true"
        r["doc"] = doc.jh
      end
      r["deleted"] = true if doc.deleted
      rows << r
    end
    # if params[:feed] == "continuous"
    j(200, {"results" => rows,"total_rows" => db.doc_count,"last_seq" => db.seq})
  end
end


