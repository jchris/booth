

def with_db db
  if Booth[db]
    yield Booth[db]
  else
    je(404, "not_found", "No database: #{db}")
  end
end


put "/:db/?" do
  db = params[:db]
  if Booth[db]
    je(412, "db_exists", "The database already exists.")
  else
    Booth[db] = {}
    headers "Location" => "/#{CGI.escape(db)}"
    j(201, {"ok" => true})
  end
end

get "/:db/?" do
  with_db(params[:db]) do |db|
    j(200, {
      :db_name => db,
      :doc_count => db.length
    })    
  end
end

delete "/:db/?" do
  db = params[:db]
  if Booth[db]
    Booth.delete(db)
    j(200, {"ok" => true})
  else
    je(404, "not_found", "No database: #{db}")
  end
end