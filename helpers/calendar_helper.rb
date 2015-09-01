require 'rest_client'

class CalendarHelper
  @@calendar_url = ENV['CALENDAR_URL'] || 'http://rhinobird.workslan/platform/api/events'
  @@secret_key = ENV['SECRET_KEY'] || 'secret_key'

  def self.post_event(cookies, title, description, from_time, to_time, user_id)
    RestClient.post(
        @@calendar_url,
        {
            'title': title,
            'description': description,
            'full_day': false,
            'from_time': from_time,
            'to_time': to_time,
            'participants': {teams: [], users: [user_id]},
            'repeated': false
        }.to_json,
        {:cookies => cookies, :content_type => :json, :secret_key => @@secret_key}
    )
  end
  def self.apply(cookies, event_id, user_id)

  end
  def self.withdraw_apply(cookies, event_id, user_id)

  end
  def self.delete_event(cookies, event_id)
    RestClient.delete(
        @@calendar_url + '/' + event_id.to_s,
        {:cookies => cookies, :content_type => :json, :secret_key => @@secret_key}
    )
  end
end