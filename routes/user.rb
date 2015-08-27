class App < Sinatra::Base

  # retrieve all users
  get '/users' do
    User.all.to_json
  end

  # retrieve top ten users sorted by point
  get '/users/topten' do
    User.order(point: :desc).limit(10).to_json
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
  get '/users/:user_id/exchange_history' do
    User.find(params[:user_id]).exchanges.to_json(include: :prize)
  end

  # add a user
  post '/users' do
    user = User.new(@body)
    user.save!
    user.to_json
  end

  # update the point of a user
  put '/users/:user_id' do
    user = User.find(params[:user_id])
    user.update(point: @body['point'])
    user.to_json
  end


end