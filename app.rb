require 'sinatra/base'
require 'sinatra/activerecord'


class App < Sinatra::Base

end

require_relative 'helpers/init'
require_relative 'models/init'
require_relative 'routes/init'
