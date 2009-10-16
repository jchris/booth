


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
  db = params[:db]
  if Booth[db]
    j(200, {
      :db_name => db,
      :doc_count => Booth[db].length
    })
  else
    je(404, "not_found", "No database: #{db}")
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