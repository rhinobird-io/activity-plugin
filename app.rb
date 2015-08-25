require 'sinatra/base'
require 'sinatra/activerecord'


class App < Sinatra::Base
  get '/' do
    "hello"
  end
end

require_relative 'helpers/init'
require_relative 'models/init'
require_relative 'routes/init'
