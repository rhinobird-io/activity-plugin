require 'rest_client'

class CalendarHelper
  CALENDAR_URL = ENV['CALENDAR_URL'] || 'http://localhost:8000/platform/api/events'
  SECRET_KEY = ENV['SECRET_KEY'] || 'secret_key'

  def self.post_event(cookies, x_user, title, description, from_time, to_time, user_id)
    RestClient.post(
        CALENDAR_URL,
        {
            'title': title,
            'description': description,
            'full_day': false,
            'from_time': from_time,
            'to_time': to_time,
            'participants': {teams: [], users: [user_id]},
            'repeated': false
        }.to_json,
        {:cookies => cookies, :content_type => :json, :secret_key => SECRET_KEY, :x_user => x_user}
    )
  end
  def self.apply(cookies, x_user, event_id, user_id)
    RestClient.put(
        CALENDAR_URL + "/" + event_id.to_s + "/register/" + user_id.to_s,
        {},
        {:cookies => cookies, :content_type => :json, :secret_key => SECRET_KEY, :x_user => x_user}
    )
  end
  def self.withdraw_apply(cookies, x_user, event_id, user_id)
    RestClient.put(
        CALENDAR_URL + "/" + event_id.to_s + "/unregister/" + user_id.to_s,
        {},
        {:cookies => cookies, :content_type => :json, :secret_key => SECRET_KEY, :x_user => x_user}
    )
  end
  def self.delete_event(cookies, x_user, event_id)
    RestClient.delete(
        CALENDAR_URL + '/' + event_id.to_s,
        {:cookies => cookies, :content_type => :json, :secret_key => SECRET_KEY, :x_user => x_user}
    )
  end
end