class App < Sinatra::Base

  # retrieve speeches sorted by time in desc order
  # retrieve confirmed and finished speeches by default
  # admins can use a query parameter 'status' to retrieve speeches in other status
  # use comma to separate each status
  # /speeches?status=auditing,confirmed
  get '/speeches' do
    status = Constants::SPEECH_STATUS::CONFIRMED + ',' + Constants::SPEECH_STATUS::FINISHED
    if @user.is_admin && params[:status]
      status = params[:status]
    end
    Speech.where(status: status.gsub(/\s+/, '').split(',')).order(time: :desc).to_json
  end

  # retrieve a speech, including applied audiences (not finished) or participants (finished)
  get '/speeches/:speech_id' do
    speech = Speech.find(params[:speech_id])
    if speech.user_id != @userid && !(@user.is_admin) && speech.status != Constants::SPEECH_STATUS::CONFIRMED && speech.status != Constants::SPEECH_STATUS::FINISHED
      halt 404
    end
    if speech.status == Constants::SPEECH_STATUS::FINISHED
      speech.to_json(include: [:attendances, :comments])
    else
      speech.to_json(include: [:audiences, :comments])
    end
  end

  # add a speech, status = auditing
  post '/speeches' do
    ActiveRecord::Base.transaction do
      speech = Speech.new(title: @body['title'], description: @body['description'],
                          user_id: @userid, expected_duration: @body['expected_duration'],
                          status: Constants::SPEECH_STATUS::AUDITING, category: @body['category'],
                          speaker_name: @body['speaker_name'])
      speech.save!
      if (@body['comment'] && @body['comment'].length > 0)
        comment = Comment.new(user_id: @userid, speech_id: speech.id, comment: @body['comment'], step: Constants::COMMENT_STEP::AUDITING)
        comment.save!
      end
      speech.to_json(include: :comments)
    end
  end

  # update the basic information of the speech in 'auditing' status
  # only 'auditing' speeches can be edited
  put '/speeches/:speech_id' do
    speech = Speech.find(params[:speech_id])
    self_required! speech.user_id
    if speech.status != Constants::SPEECH_STATUS::AUDITING
      400
    else
      ActiveRecord::Base.transaction do
        speech.title = @body['title']
        speech.description = @body['description']
        speech.expected_duration = @body['expected_duration']
        speech.category = @body['category']
        speech.speaker_name = @body['speaker_name']
        speech.save!
        comment = Comment.where("speech_id = ? and step = ?", speech.id, Constants::COMMENT_STEP::AUDITING).first
        if (@body['comment'] && @body['comment'].length > 0)
          if comment.nil?
            comment = Comment.new(user_id: @userid, speech_id: speech.id, comment: @body['comment'], step: Constants::COMMENT_STEP::AUDITING)
            comment.save!
          else
            comment.comment = @body['comment']
            comment.save!
          end
        else
          unless comment.nil?
            comment.destroy!
          end
        end
        speech.to_json
      end
    end
  end

  # delete a speech in 'auditing' status
  # only 'auditing' speeches can be deleted
  delete '/speeches/:speech_id' do
    speech = Speech.find(params[:speech_id])
    self_required! speech.user_id
    if speech.status == Constants::SPEECH_STATUS::AUDITING
      speech.destroy!
      content_type 'text/plain'
      200
    else
      400
    end
  end

  # upload resource to the speech
  post '/speeches/:speech_id/attachments' do
    speech = Speech.find(params[:speech_id])
    if speech.user_id != @userid && !(@user.is_admin)
        halt 401
    end

    if speech.status == Constants::SPEECH_STATUS::CONFIRMED || @user.is_admin
      if @body['attachmentType'] == Constants::ATTACHMENT_TYPE::VIDEO
          url = speech.video_resource_url || ""
          url = '/' + url unless url.empty?
          speech.video_resource_url = @body['resource_url'] + url
      else
          url = speech.resource_url || ""
          url = '/' + url unless url.empty?
          speech.resource_url = @body['resource_url'] + url
      end

      if @body['attachmentType'] == Constants::ATTACHMENT_TYPE::VIDEO
          name = speech.video_resource_name || ""
          name = '/' + name unless name.empty?
          speech.video_resource_name = @body['resource_name'] + name
      else
          name = speech.resource_name || ""
          name = '/' + name unless name.empty?
          speech.resource_name = @body['resource_name'] + name
      end

      speech.save!
      speech.to_json(include: [:attendances, :audiences, :comments])
    else
      400
    end
  end

  delete '/speeches/:speech_id/attachments/:type/:file_id' do
    speech = Speech.find(params[:speech_id])
    if speech.user_id != @userid && !(@user.is_admin)
        halt 401
    end

    if speech.status == Constants::SPEECH_STATUS::CONFIRMED  || @user.is_admin
      attachmentType = params[:type]

      if attachmentType == Constants::ATTACHMENT_TYPE::VIDEO
          urls = speech.video_resource_url.split('/')
          names = speech.video_resource_url.split('/')
          pos = urls.index(params[:file_id])
          if pos
            urls.delete_at(pos)
            names.delete_at(pos)
          end
          speech.video_resource_url = urls.join('/')
          speech.video_resource_url = names.join('/')
      else
          urls = speech.resource_url.split('/')
          names = speech.resource_name.split('/')
          pos = urls.index(params[:file_id])
          if pos
            urls.delete_at(pos)
            names.delete_at(pos)
          end
          speech.resource_url = urls.join('/')
          speech.resource_name = names.join('/')
      end

      speech.save!
      speech.to_json(include: [:attendances,:audiences, :comments])
    else
      400
    end
  end

  # auditing -> approved
  post '/speeches/:speech_id/approve' do
    admin_required!
    speech = Speech.find(params[:speech_id])
    if speech.status == Constants::SPEECH_STATUS::AUDITING
      ActiveRecord::Base.transaction do
        speech.status = Constants::SPEECH_STATUS::APPROVED
        speech.time = @body['time']
        speech.save!
        if (@body['comment'] && @body['comment'].length > 0)
          comment = Comment.new(user_id: @userid, speech_id: speech.id, comment: @body['comment'], step: Constants::COMMENT_STEP::APPROVE)
          comment.save!
        end
        speech.to_json(include: :comments)
      end
    else
      400
    end
  end
  # reject by admin, speech status remains the same
  post '/speeches/:speech_id/reject' do
    admin_required!
    speech = Speech.find(params[:speech_id])
    if speech.status == Constants::SPEECH_STATUS::AUDITING && @body['comment'] && @body['comment'].length > 0
      comment = Comment.new(user_id: @userid, speech_id: speech.id, comment: @body['comment'], step: Constants::COMMENT_STEP::REJECT)
      comment.save!
      speech.to_json(include: :comments)
    else
      400
    end
  end
  # approved -> confirmed
  post '/speeches/:speech_id/agree' do
    speech = Speech.find(params[:speech_id])
    self_required! speech.user_id
    if speech.status == Constants::SPEECH_STATUS::APPROVED
      ActiveRecord::Base.transaction do
        speech.status = Constants::SPEECH_STATUS::CONFIRMED
        speech.save!
        MailHelper::sendCreateActivityEmail(speech)
      end
      speech.to_json(include: :comments)
    else
      400
    end
  end
  # approved -> auditing
  post '/speeches/:speech_id/disagree' do
    speech = Speech.find(params[:speech_id])
    self_required! speech.user_id
    if speech.status == Constants::SPEECH_STATUS::APPROVED && @body['comment'] && @body['comment'].length > 0
      ActiveRecord::Base.transaction do
        speech.status = Constants::SPEECH_STATUS::AUDITING
        speech.save!
        comment = Comment.new(user_id: @userid, speech_id: speech.id, comment: @body['comment'], step: Constants::COMMENT_STEP::DISAGREE)
        comment.save!
        speech.to_json(include: :comments)
      end
    else
      400
    end
  end
  # confirmed -> closed
  post '/speeches/:speech_id/close' do
    admin_required!
    speech = Speech.find(params[:speech_id])
    if speech.status == Constants::SPEECH_STATUS::CONFIRMED
      ActiveRecord::Base.transaction do
        comment = Comment.new(user_id: @userid, speech_id: speech.id, comment: @body['comment'], step: Constants::COMMENT_STEP::CLOSED)
        comment.save!
        speech.status = Constants::SPEECH_STATUS::CLOSED
        speech.save!
      end
      speech.to_json(include: [:audiences, :comments])
    else
      400
    end
  end
  # confirmed -> finish
  post '/speeches/:speech_id/finish' do
    admin_required!
    speech = Speech.find(params[:speech_id])
    if speech.status == Constants::SPEECH_STATUS::CONFIRMED
      participants = @body['participants']

      ActiveRecord::Base.transaction do
        notifications = []
        participants.each{|u|
          point = 0
          if u['role'] == Constants::ATTENDANCE_ROLE::SPEAKER
            point += speech.category == Constants::SPEECH_CATEGORY::MONTHLY ? Constants::POINT::MONTHLY : Constants::POINT::WEEKLY
          else
            point += (speech.category == Constants::SPEECH_CATEGORY::MONTHLY ? Constants::POINT::MONTHLY_AUDIENCE : Constants::POINT::WEEKLY_AUDIENCE) + (u['commented'] ? Constants::POINT::COMMENT : 0)
          end
          not_add_point = true
          user = User.find_by_id(u['user_id'])
          if user.nil?
            user = User.new(id: u['user_id'], role: Constants::USER_ROLE::USER, point_total: 0, point_available: 0)
            user.change_point(point)
            user.save!
            not_add_point = false
          end
          unless Attendance.exists?(user_id: u['user_id'], speech_id: params[:speech_id])
              attendance = Attendance.new(user_id: u['user_id'], speech_id: params[:speech_id],
                                          role: u['role'], point: point, commented: u['commented'])
              attendance.save!
              if not_add_point
                user.change_point(point)
                user.save!
              end
          end
          like_url = "/speeches/#{speech.id}/like?user_id=#{u['user_id']}"
          encrypted = EncryptHelper.encrypt(like_url)
          controller = EmailBinding.new(speech.id, speech.title, u['user_id'], encrypted, point, u['user_id'] == speech.user_id)
          notifications.push({
                                 'users': [u['user_id']],
                                 'teams': [],
                                 'content': {content: "You got #{point} points from the activity #{speech.title}"},
                                 'url': "/platform/activity/activities/#{speech.id}",
                                 'email_subject': "[RhinoBird] You got #{point} points",
                                 'email_body': ERB.new(File.read('./views/activity_point.erb')).result(controller.get_binding)
                             })
        }
        if notifications.length > 0
          MailHelper::batchSend(notifications, request.cookies, @userid)
        end

        speech.status = Constants::SPEECH_STATUS::FINISHED
        speech.save!
        speech.to_json(include: [:attendances, :comments])
      end
    else
      400
    end
  end

  class EmailBinding
    attr_reader :id, :title, :user_id, :hash, :point, :is_owner
    def initialize(id, title, user_id, hash, point, is_owner)
      @id = id
      @title = title
      @user_id = user_id
      @hash = hash
      @point = point
      @is_owner = is_owner
    end

    def get_binding
      binding
    end
  end

  # user apply to be an audience
  post '/speeches/:speech_id/audiences' do
    speech = Speech.find(params[:speech_id])
    halt 400 if speech.status != Constants::SPEECH_STATUS::CONFIRMED || withSpeakerName(speech)
    if !(AudienceRegistration.exists?(user_id: @userid, speech_id: params[:speech_id])) && speech.user_id != @userid
      ActiveRecord::Base.transaction do
        audience = AudienceRegistration.new(user_id: @userid, speech_id: params[:speech_id])
        audience.save!
      end
    end
    speech.to_json(include: [:audiences, :comments])
  end

  # user withdraw his apply to be an audience
  delete '/speeches/:speech_id/audiences/:user_id' do
    self_required! params[:user_id].to_i
    speech = Speech.find(params[:speech_id])
    halt 400 if speech.status != Constants::SPEECH_STATUS::CONFIRMED || withSpeakerName(speech)
    registration = AudienceRegistration.where(user_id: params[:user_id], speech_id: params[:speech_id])
    unless registration.empty?
      ActiveRecord::Base.transaction do
        AudienceRegistration.destroy_all(user_id: params[:user_id], speech_id: params[:speech_id])
      end
    end
    speech.to_json(include: [:audiences, :comments])
  end


  # mark user likes a speech and add points to the speaker
  post '/speeches/:speech_id/like' do
    user_id = @userid
    speech = Speech.find(params[:speech_id])
    if !withSpeakerName(speech) && user_id != speech.user_id && Attendance.exists?(user_id: user_id, speech_id: params[:speech_id], liked: false)
      ActiveRecord::Base.transaction do
        attendance = Attendance.where(user_id: user_id, speech_id: params[:speech_id]).first
        attendance.liked = true
        attendance.save!

        speaker_id = speech.user_id
        speaker_attendance = Attendance.where(user_id: speaker_id, speech_id: params[:speech_id]).first
        speaker_attendance.point = speaker_attendance.point + Constants::POINT::LIKE
        speaker_attendance.save!

        speaker = User.find(speaker_id)
        speaker.change_point(Constants::POINT::LIKE)
        speaker.save!
      end
    end
    speech.to_json(include: [:attendances, :comments])
  end
  # mark user likes a speech and add points to the speaker
  # for link from email
  get '/speeches/:speech_id/like' do
    user_id = @userid
    unless params[:user_id].nil?
      path = request.path
      if EncryptHelper.encrypt("#{path}?user_id=#{params[:user_id]}") == params[:hash]
        user_id = params[:user_id]
      else
        halt 401
      end
    end

    speech = Speech.find(params[:speech_id])
    if !withSpeakerName(speech) && user_id != speech.user_id && Attendance.exists?(user_id: user_id, speech_id: params[:speech_id], liked: false)
      ActiveRecord::Base.transaction do
        attendance = Attendance.where(user_id: user_id, speech_id: params[:speech_id]).first
        attendance.liked = true
        attendance.save!

        speaker_id = speech.user_id
        speaker_attendance = Attendance.where(user_id: speaker_id, speech_id: params[:speech_id]).first
        speaker_attendance.point = speaker_attendance.point + Constants::POINT::LIKE
        speaker_attendance.save!

        speaker = User.find(speaker_id)
        speaker.change_point(Constants::POINT::LIKE)
        speaker.save!
      end
    end
    controller = LikeBinding.new(speech.id, speech.title)
    content_type 'text/html'
    status 200
    body ERB.new(File.read('./views/like.erb')).result(controller.get_binding)
  end

  class LikeBinding
    attr_reader :id, :title
    def initialize(id, title)
      @id = id
      @title = title
    end
    def get_binding
      binding
    end
  end

  # does this speech has speaker_name?
  # return true if has
  # return false otherwise
  def withSpeakerName(speech)
    return speech.speaker_name.to_s.length != 0
  end
end
