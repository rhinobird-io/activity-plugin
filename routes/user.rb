class App < Sinatra::Base

  # retrieve all users
  get '/users' do
    User.all.to_json
  end

  # user rank sorted by total point
  # retrieve ten users by default
  # you can use a query parameter 'limit' to retrieve a specific amount of user
  post '/users/rank' do
    limit = params[:limit] || 10
    User.order(point_total: :desc).limit(limit).to_json
  end

  # retrieve one user
  get '/users/:user_id' do
      User.find(params[:user_id]).to_json
  end

  # retrieve speeches of one user
  # if current user is the target user, return all speeches
  # otherwise, return confirmed and finished speeches
  get '/users/:user_id/speeches' do
    if @userid == params[:user_id].to_i
      User.find(params[:user_id]).speeches.order(id: :desc).to_json
    else
      User.find(params[:user_id]).speeches.where(status: [Constants::SPEECH_STATUS::CONFIRMED, Constants::SPEECH_STATUS::FINISHED]).order(id: :desc).to_json
    end
  end

  # retrieve speeches this user have applied as an audience
  get '/users/:user_id/applied_speeches' do
    User.find(params[:user_id]).applied_speeches.order(time: :desc).to_json
  end

  # retrieve speeches this user have attended
  get '/users/:user_id/attended_speeches' do
    User.find(params[:user_id]).attended_speeches.order(time: :desc).to_json
  end

  # retrieve exchange history, including prize information
  get '/users/:user_id/exchanges' do
    User.find(params[:user_id]).exchanges.to_json(include: :prize)
  end


end