class App < Sinatra::Base

  # retrieve all users
  get '/users' do
    User.all.to_json
  end

  # user rank sorted by point
  # retrieve ten users by default
  # you can use a query parameter 'limit' to retrieve a specific amount of user
  post '/users/rank' do
    limit = params[:limit]
    if limit.nil?
      limit = 10
    end
    User.order(point: :desc).limit(limit).to_json
  end

  # retrieve one user
  get '/users/:user_id' do
      User.find(params[:user_id]).to_json
  end

  # retrieve speeches this user makes
  get '/users/:user_id/speeches' do
    User.find(params[:user_id]).speeches.to_json
  end

  # retrieve speeches this user have applied as an audience
  get '/users/:user_id/applied_speeches' do
    User.find(params[:user_id]).applied_speeches.to_json
  end

  # retrieve speeches this user have attended
  get '/users/:user_id/attended_speeches' do
    User.find(params[:user_id]).attended_speeches.to_json
  end

  # retrieve exchange history, including prize information
  get '/users/:user_id/exchanges' do
    User.find(params[:user_id]).exchanges.to_json(include: :prize)
  end

  # add a normal user
  post '/users' do
    user = User.new(id: @body['id'], role: 'user', point: 0)
    user.save!
    user.to_json
  end


end