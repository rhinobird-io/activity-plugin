require 'rest_client'
require 'rufus-scheduler'

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
  def self.batchSend(notifications, cookies, x_user)
    RestClient.post(
        NOTIFICATION_URL + '/batch',
        {
            'notifications': notifications
        }.to_json,
        {:cookies => cookies, :content_type => :json, :x_user => x_user}
    )
  end


end

def sendCreateActivityEmail(speech)
  subject = "[RhinoBird] Join activity #{speech.title} with us"
  puts speech.speaker_name.nil?
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
          <div style='font-size: 1.2em;'>
              This time we will hold below activity:
          </div>
          <br/>
          <table style='margin: auto; text-align: left;'>
              <tbody>
              <tr>
                <td class='title'>Subject</td>
                <td>#{speech.title}</td>
              </tr>
              <tr>
                <td class='title'>Description</td>
                <td>#{speech.description}</td>
              </tr>
              <tr>
                <td class='title'>When</td>
                <td>#{speech.time.in_time_zone('Beijing')}</td>
              </tr>
              <tr>
                <td class='title'>Duration</td>
                <td>#{speech.expected_duration} min</td>
              </tr>
              <div>
              </div>
              </tbody>
          </table>
          <div style='margin: 32px auto;'>Want more details? <a href='http://rhinobird.workslan/platform/activity/activities/#{speech.id}'>View</a> the details on RhinoBird</div>
          #{withSpeakerName(speech) ? '' :
                "<div style='margin: 32px auto;'>
                  Click join on <a href='http://rhinobird.workslan/platform/activity/activities/#{speech.id}'>details page</a> to receive the latest information!
                </div>"
          }
          <p>Sent from RhinoBird platform.</p>
          <p>If you have any question or feedback, contact with us at works-college@ml.worksap.com</p>
          <hr>
          <p style='text-align: center;'>Designed by ATE-Shanghai, © Works Applications Co.,Ltd.</p>
        </div>"

  from = settings.email
  scheduler = Rufus::Scheduler.new
  scheduler.in '5s' do
    puts "send notification email for activity #{speech.title}"
    Mail.deliver do
      from from
      to EMAIL_ADDRESS
      subject subject
      content_type 'text/html; charset=UTF-8'
      body body
    end
  end
end