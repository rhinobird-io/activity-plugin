require 'sinatra/base'
require 'sinatra/activerecord'


class App < Sinatra::Base
  set :show_exceptions, :after_handler
  error ActiveRecord::RecordInvalid do
    status 400
    body env['sinatra.error'].message
  end

  error ActiveRecord::RecordNotFound do
    status 404
    body env['sinatra.error'].message
  end

  error ActiveRecord::RecordNotUnique do
    status 400
    body env['sinatra.error'].message
  end

  error do
    status 500
    body env['sinatra.error'].message
  end

  def admin_required!
    halt 401 unless @user.is_admin
  end
  def self_required!(id)
    halt 401 if @userid != id
  end

  before do
    content_type 'application/json'
    if request.media_type == 'application/json'
      body = request.body.read
      unless body.empty?
        @body = JSON.parse(body)
      end
    end

    unless request.env['HTTP_X_USER'].nil?
      @userid = request.env['HTTP_X_USER'].to_i
      @user = User.find_by_id(@userid)
      if @user.nil?
        @user = User.new(id: @userid, role: 'user', point: 0)
        @user.save!
      end
    end

  end
  
end

require_relative 'helpers/init'
require_relative 'models/init'
require_relative 'routes/init'
