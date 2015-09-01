require 'pp'
require 'rest_client'

class CalendarHelper
  def self.post_event(cookies, title, description, from_time, to_time)
    auth_url = ENV['AUTH_URL'] || 'http://rhinobird.workslan/platform/api/events'
    RestClient.post(
        auth_url,
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
  def self.apply

  end
  def self.withdraw_apply

  end
  def self.delete_event

  end
end