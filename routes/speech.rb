class App < Sinatra::Base

  # retrieve speeches sorted by time in desc order
  # retrieve confirmed and finished speeches by default
  # you can use a query parameter 'status' to retrieve speeches in other status
  # use comma to separate each status
  # /speeches?status=auditing,confirmed
  get '/speeches' do
    status = params[:status]
    if (status.nil?)
      status = Constants::CONFIRMED + ',' + Constants::FINISH
    end
    Speech.where(status: status.gsub(/\s+/, '').split(',')).order(time: :desc).to_json
  end

  # retrieve a speech, including applied audiences
  get '/speeches/:speech_id' do
    Speech.find(params[:speech_id]).to_json(include: :audiences)
  end

  get '/speeches/:speech_id/audiences' do
    Speech.find(params[:speech_id]).audiences.to_json
  end

  post '/speeches' do

  end

  put '/speeches/:speech_id' do

  end

  delete 'speeches/:speech_id' do

  end

  # user apply to be an audience
  post '/speeches/:speech_id/register' do
    200
  end

  # user withdraw his apply to be an audience
  delete '/speeches/:speech_id/register' do
    200
  end

  # add participants
  post '/speeches/:speech_id/participants' do

  end

end