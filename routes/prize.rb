class App < Sinatra::Base

  get '/prizes' do
    column = params[:column] == 'price' ? 'price' : 'exchanged_times'
    order = params[:order] == 'asc' ? 'asc' : 'desc'
    Prize.all.order(column + ' ' + order).to_json
  end

  get '/prizes/:prize_id' do
    Prize.find(params[:prize_id]).to_json
  end

  # retrieve exchange history of this prize, including users
  get '/prizes/:prize_id/exchanges' do
    Prize.find(params[:prize_id]).exchanges.to_json
  end

  post '/prizes' do
    admin_required!
    prize = Prize.new(name: @body['name'], description: @body['description'],
                        picture_url: @body['picture_url'], price: @body['price'], exchanged_times: 0)
    prize.save!
    prize.to_json
  end

  put '/prizes/:prize_id' do
    admin_required!
    prize = Prize.find(params[:prize_id])
    prize.name = @body['name']
    prize.description = @body['description']
    prize.picture_url = @body['picture_url']
    prize.price = @body['price']
    prize.save!
    prize.to_json
  end

  delete '/prizes/:prize_id' do
    admin_required!
    Prize.find(params[:prize_id]).destroy!
    content_type 'text/plain'
    200
  end

  get '/exchanges' do
    before = params[:before]
    if before.nil?
      Exchange.all.order(exchange_time: :desc).limit(20).to_json(include: :prize)
    else
      Exchange.where('id < ?', before).order(exchange_time: :desc).limit(20).to_json(include: :prize)
    end
  end

  post '/exchanges' do
    prize = Prize.find(@body['prize_id'])
    if @user.point_available < prize.price
      status 400
      body 'The available point of this user is not enough to exchange this prize.'
    else
      ActiveRecord::Base.transaction do
        prize = Prize.find(@body['prize_id'])
        prize.lock!
        @user.change_point_available(- prize.price)
        @user.save!
        exchange = Exchange.new(user_id: @userid, prize_id: @body['prize_id'],
                          point: prize.price, exchange_time: Time.now, status: Constants::EXCHANGE_STATUS::NEW)
        exchange.save!
        prize.increment(:exchanged_times, 1)
        prize.save!
      end
      prize.to_json
    end
  end

  post '/exchanges/:id/sent' do
    admin_required!
    exchange = Exchange.find(params[:id])
    if exchange.status == Constants::EXCHANGE_STATUS::NEW
      exchange.status = Constants::EXCHANGE_STATUS::SENT
      exchange.save!
      exchange.to_json(include: :prize)
    else
      400
    end
  end
end