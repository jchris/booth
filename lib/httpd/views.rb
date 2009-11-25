require 'view'

# handle temp views
post "/:db/_temp_view/?" do
  with_db(params[:db]) do |db|
    req = JSON.parse(request.body.read)
    v = View.new(db, req["map"], req["reduce"])
    j(200, v.query(View.view_params(params)))
  end
end

# ddoc views should be similar,
# just keep a ref to the view around 
# so we can update it.
