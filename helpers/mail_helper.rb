require 'rest_client'

class MailHelper
  NOTIFICATION_URL = ENV['NOTIFICATION_URL'] || 'http://localhost:8000/platform/api/users/notifications'
  def self.send(to, content, url, subject, body, cookies, x_user)
    RestClient.post(
        NOTIFICATION_URL,
        {
            'users': [to],
            'teams': [],
            'content': {content: content},
            'url': url,
            'email_subject': subject,
            'email_body': body
        }.to_json,
        {:cookies => cookies, :content_type => :json, :x_user => x_user}
    )
  end
end