class App < Sinatra::Base

  get '/prizes' do
    Prize.all.order(created_at: :desc).to_json
  end

  get '/prizes/:prize_id' do
    Prize.find(params[:prize_id]).to_json
  end

  # retrieve exchange history of this prize, including users
  get '/prizes/:prize_id/exchanges' do
    Prize.find(params[:prize_id]).exchanges.to_json
  end

  post '/prizes' do
    prize = Prize.new(name: @body['name'], description: @body['description'],
                        picture_url: @body['picture_url'], price: @body['price'])
    prize.save!
    prize.to_json
  end

  put '/prizes/:prize_id' do
    prize = Prize.find(params[:prize_id])
    prize.name = @body['name']
    prize.description = @body['description']
    prize.picture_url = @body['picture_url']
    prize.price = @body['price']
    prize.save!
    prize.to_json
  end

  delete '/prizes/:prize_id' do
    Prize.find(params[:prize_id]).destroy!
    200
  end

  get '/exchanges' do
    Exchange.all.order(exchange_time: :desc).to_json(include: :prize)
  end

  post '/exchanges' do
    prize = Prize.find(@body['prize_id'])
    user = User.find(@body['user_id'])
    if user.point < prize.price
      status 400
      body 'The point of this user is not enough to exchange this prize.'
    else
      ActiveRecord::Base.transaction do
        user.change_point(- prize.price)
        user.save!
        exchange = Exchange.new(user_id: @body['user_id'], prize_id: @body['prize_id'],
                          point: prize.price, exchange_time: Time.now)
        exchange.save!
      end
      200
    end
  end


end