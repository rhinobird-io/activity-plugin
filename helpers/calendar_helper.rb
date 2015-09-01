require 'pp'
require 'rest_client'

class CalendarHelper
  def self.post_event(title, description, from_time, to_time)
    # event = {}
    #
    # event.title = title
    # event.description = description
    # event.full_day = false
    #
    # event.from_time = from_time
    # event.to_time = to_time
    #
    # event.participants = { teams: [], users: [] }
    # event.repeated = false

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
        {:cookies => {'Auth': '92c459f2a264316c662077b18d59522e'}, :content_type => :json}
    )
  end
  def self.apply

  end
  def self.withdraw_apply

  end
  def self.delete_event

  end
  def self.test(cookie)

    # response = HTTParty.get('http://rhinobird.workslan/api/events', header: cookie)
    # puts response.body, response.code, response.message, response.headers.inspect
  end
end