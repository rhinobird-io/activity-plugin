require 'sinatra/base'
require 'sinatra/activerecord'
require 'sinatra/config_file'
require 'rufus-scheduler'
require 'mail'

EMAIL_ADDRESS = ENV['EMAIL_ADDRESS'] || 'wang_bo@worksap.co.jp'
class App < Sinatra::Base
  register Sinatra::ConfigFile

  config_file './config/platform.yml'

  scheduler = Rufus::Scheduler.new
  
  scheduler.every '30s' do
    now = DateTime.now
    half_an_hour = 30.minute
    half_an_hour_later = now + half_an_hour

    speeches = Speech.where('time >= ? and time <= ? and status = ?', now, half_an_hour_later, Constants::SPEECH_STATUS::CONFIRMED)

    speeches.each { |e|
      next if e.time.to_datetime.to_i - now.to_i < 1770
      subject = "[RhinoBird] Activity #{e.title} will start in half an hour"
      body = "<style>
          table tr td {
              padding: 4px 8px;
          }
          table tr td.title {
              font-weight: 600;
              vertical-align: top;
              text-align: right;
          }
      </style>
      <div style='max-width: 600px; margin: auto;'>
          <div style='font-size: 1.2em; line-height: 1.5em;'>
               Activity <a href='http://rhinobird.workslan/platform/activity/activities/#{e.id}'>#{e.title}</a> will start in half an hour.</div>
          <br>
          <table style='margin: auto; text-align: left;'>
            <tbody>
            <tr>
              <td class='title'>Subject</td>
              <td>#{e.title}</td>
            </tr>
            <tr>
              <td class='title'>Description</td>
              <td>#{e.description}</td>
            </tr>
            <tr>
              <td class='title'>When</td>
              <td>#{e.time.in_time_zone('Beijing')}</td>
            </tr>
            <tr>
              <td class='title'>Duration</td>
              <td>#{e.expected_duration} min</td>
            </tr>
            <div>
            </div>
            </tbody>
        </table>
          <p>Sent from <a href='http://rhinobird.workslan/platform/activity'>RhinoBird platform</a>.</p>
          <p>If you have any question or feedback, contact with us at works-college@ml.worksap.com</p>
          <hr>
          <p style='text-align: center;'>Designed by ATE-Shanghai, © Works Applications Co.,Ltd.</p>
      </div>"

      puts "send notification email for activity #{e.title}"
      Mail.deliver do
        from settings.email
        to EMAIL_ADDRESS
        subject subject
        content_type 'text/html; charset=UTF-8'
        body body
      end
    }
  end

  options = { :address              => 'smtp.gmail.com',
              :port                 => 587,
              :domain               => 'www.gmail.com',
              :user_name            => settings.email,
              :password             => ENV['EMAIL_PASSWORD'],
              :authentication       => 'plain',
              :enable_starttls_auto => true  }
  Mail.defaults do
    delivery_method :smtp, options
  end


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
        @user = User.new(id: @userid, role: 'user', point_total: 0, point_available: 0)
        @user.save!
      end
    end

  end
  
end

require_relative 'helpers/init'
require_relative 'models/init'
require_relative 'routes/init'
