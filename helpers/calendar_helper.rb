require 'pp'
require 'rest_client'

class CalendarHelper
  @@calendar_url = ENV['CALENDAR_URL'] || 'http://rhinobird.workslan/platform/api/events'
  def self.post_event(cookies, title, description, from_time, to_time)
    RestClient.post(
        @@calendar_url,
        {
            'title': title,
            'description': description,
            'full_day': false,
            'from_time': from_time,
            'to_time': to_time,
            'participants': {teams: [], users: []},
            'repeated': false,
            'secret_key': 'secret_key'
        }.to_json,
        {:cookies => cookies, :content_type => :json}
    )
  end
  def self.apply

  end
  def self.withdraw_apply

  end
  def self.delete_event
    RestClient.post(
        @@calendar_url,
        {
            'title': title,
            'description': description,
            'full_day': false,
            'from_time': from_time,
            'to_time': to_time,
            'participants': {teams: [], users: []},
            'repeated': false
        }.to_json,
        {:cookies => cookies, :content_type => :json}
    )
  end
end