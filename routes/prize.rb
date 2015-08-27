class App < Sinatra::Base

  get '/prizes' do
    Prize.all.order(created_at: :desc).to_json
  end

  get '/prizes/:prize_id' do
    Prize.find(params[:prize_id]).to_json
  end

  # retrieve exchange history of this prize, including users
  get '/prizes/:prize_id/exchange_history' do
    Prize.find(params[:prize_id]).exchanges.to_json(include: :user)
  end

end