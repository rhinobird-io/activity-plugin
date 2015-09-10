class App < Sinatra::Base

  # retrieve speeches sorted by time in desc order
  # retrieve confirmed and finished speeches by default
  # you can use a query parameter 'status' to retrieve speeches in other status
  # use comma to separate each status
  # /speeches?status=auditing,confirmed
  get '/speeches' do
    status = params[:status] || Constants::SPEECH_STATUS::CONFIRMED + ',' + Constants::SPEECH_STATUS::FINISHED
    Speech.where(status: status.gsub(/\s+/, '').split(',')).order(time: :desc).to_json
  end

  # retrieve a speech, including applied audiences (not finished) or participants (finished)
  get '/speeches/:speech_id' do
    speech = Speech.find(params[:speech_id])
    if speech.status == Constants::SPEECH_STATUS::FINISHED
      speech.to_json(include: :attendances)
    else
      speech.to_json(include: :audiences)
    end
  end

  # add a speech, status = new
  post '/speeches' do
    speech = Speech.new(title: @body['title'], description: @body['description'],
                        user_id: @userid, expected_duration: @body['expected_duration'],
                        status: Constants::SPEECH_STATUS::NEW, category: @body['category'])
    speech.save!
    speech.to_json
  end

  # update the basic information of the speech in 'new' status
  # only 'new' speeches can be edited
  put '/speeches/:speech_id' do
    speech = Speech.find(params[:speech_id])
    self_required! speech.user_id
    if speech.status != Constants::SPEECH_STATUS::NEW
      400
    else
      speech.title = @body['title']
      speech.description = @body['description']
      speech.expected_duration = @body['expected_duration']
      speech.category = @body['category']
      speech.save!
      speech.to_json
    end
  end

  # delete a speech in 'new' status
  # only 'new' speeches can be deleted
  delete '/speeches/:speech_id' do
    speech = Speech.find(params[:speech_id])
    self_required! speech.user_id
    if speech.status == Constants::SPEECH_STATUS::NEW
      speech.destroy!
      content_type 'text/plain'
      200
    else
      400
    end
  end

  # upload resource to the speech
  post '/speeches/:speech_id/upload' do
    speech = Speech.find(params[:speech_id])
    self_required! speech.user_id
    if speech.status == Constants::SPEECH_STATUS::CONFIRMED
      speech.resource_url = @body['resource_url']
      speech.resource_name = @body['resource_name']
      speech.save!
      speech.to_json(include: :audiences)
    else
      400
    end
  end

  # new -> auditing
  post '/speeches/:speech_id/submit' do
    speech = Speech.find(params[:speech_id])
    self_required! speech.user_id
    if speech.status == Constants::SPEECH_STATUS::NEW
      speech.status = Constants::SPEECH_STATUS::AUDITING
      speech.save!
      speech.to_json
    else
      400
    end
  end
  # auditing || approved -> new, by speaker
  post '/speeches/:speech_id/withdraw' do
    speech = Speech.find(params[:speech_id])
    self_required! speech.user_id
    if speech.status == Constants::SPEECH_STATUS::AUDITING || speech.status == Constants::SPEECH_STATUS::APPROVED
      speech.status = Constants::SPEECH_STATUS::NEW
      speech.save!
      speech.to_json
    else
      400
    end
  end
  # auditing -> approved
  post '/speeches/:speech_id/approve' do
    admin_required!
    speech = Speech.find(params[:speech_id])
    if speech.status == Constants::SPEECH_STATUS::AUDITING
      speech.status = Constants::SPEECH_STATUS::APPROVED
      speech.time = @body['time']
      speech.save!
      speech.to_json
    else
      400
    end
  end
  # auditing -> new, by admin
  post '/speeches/:speech_id/reject' do
    admin_required!
    speech = Speech.find(params[:speech_id])
    if speech.status == Constants::SPEECH_STATUS::AUDITING
      speech.status = Constants::SPEECH_STATUS::NEW
      speech.save!
      speech.to_json
    else
      400
    end
  end
  # approved -> confirmed
  post '/speeches/:speech_id/agree' do
    puts request.cookies
    speech = Speech.find(params[:speech_id])
    self_required! speech.user_id
    if speech.status == Constants::SPEECH_STATUS::APPROVED
      ActiveRecord::Base.transaction do
        speech.status = Constants::SPEECH_STATUS::CONFIRMED
        event = CalendarHelper::post_event(request.cookies, @userid, speech.title, speech.description, speech.time, speech.time, @userid)
        speech.event_id = JSON.parse(event)['id']
        speech.save!
      end
      speech.to_json
    else
      400
    end
  end
  # approved -> auditing
  post '/speeches/:speech_id/disagree' do
    speech = Speech.find(params[:speech_id])
    self_required! speech.user_id
    if speech.status == Constants::SPEECH_STATUS::APPROVED
      speech.status = Constants::SPEECH_STATUS::AUDITING
      speech.save!
      speech.to_json
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
        CalendarHelper::delete_event(request.cookies, @userid, speech.event_id)
        speech.status = Constants::SPEECH_STATUS::CLOSED
        speech.save!
      end
      speech.to_json(include: :audiences)
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
        participants.each{|u|
          not_add_point = true
          user = User.find_by_id(u['user_id'])
          if user.nil?
            user = User.new(id: u['user_id'], role: Constants::USER_ROLE::USER, point_total: 0, point_available: 0)
            user.change_point(u['point'] + (u['commented'] ? 1 : 0))
            user.save!
            not_add_point = false
          end
          unless Attendance.exists?(user_id: u['user_id'], speech_id: params[:speech_id])
              attendance = Attendance.new(user_id: u['user_id'], speech_id: params[:speech_id],
                                          role: u['role'], point: u['point'], commented: u['commented'])
              attendance.save!
              if not_add_point
                user.change_point(u['point'] + (u['commented'] ? 1 : 0))
                user.save!
              end
          end
        }
        speech.status = Constants::SPEECH_STATUS::FINISHED
        speech.save!
        speech.to_json(include: :attendances)
      end
    else
      400
    end
  end

  get '/speeches/:speech_id/audiences' do
    Speech.find(params[:speech_id]).audiences.to_json
  end

  # user apply to be an audience
  post '/speeches/:speech_id/audiences' do
    speech = Speech.find(params[:speech_id])
    halt 400 if speech.status != Constants::SPEECH_STATUS::CONFIRMED
    unless AudienceRegistration.exists?(user_id: @userid, speech_id: params[:speech_id])
      ActiveRecord::Base.transaction do
        CalendarHelper::apply(request.cookies, @userid, speech.event_id, @userid)
        audience = AudienceRegistration.new(user_id: @userid, speech_id: params[:speech_id])
        audience.save!
      end
    end
    speech.to_json(include: :audiences)
  end

  # user withdraw his apply to be an audience
  delete '/speeches/:speech_id/audiences/:user_id' do
    self_required! params[:user_id].to_i
    speech = Speech.find(params[:speech_id])
    halt 400 if speech.status != Constants::SPEECH_STATUS::CONFIRMED
    registration = AudienceRegistration.where(user_id: params[:user_id], speech_id: params[:speech_id])
    unless registration.empty?
      ActiveRecord::Base.transaction do
        AudienceRegistration.destroy_all(user_id: params[:user_id], speech_id: params[:speech_id])
        CalendarHelper::withdraw_apply(request.cookies, @userid, speech.event_id, @userid)
      end
    end
    speech.to_json(include: :audiences)
  end

  get '/speeches/:speech_id/participants' do
    Speech.find(params[:speech_id]).participants.to_json
  end

  # add a participant, add point to the user
  post '/speeches/:speech_id/participants' do
    admin_required!
    unless Attendance.exists?(user_id: @body['user_id'], speech_id: params[:speech_id])
      ActiveRecord::Base.transaction do
        attendance = Attendance.new(user_id: @body['user_id'], speech_id: params[:speech_id],
                                    role: @body['role'], point: @body['point'], commented: @body['commented'])
        attendance.save!
        user = User.find(@body['user_id'])
        user.change_point(@body['point'] + (@body['commented'] ? 1 : 0))
        user.save!
      end
    end
    content_type 'text/plain'
    200
  end

  # delete a participant, minus point from the user
  delete '/speeches/:speech_id/participants/:user_id' do
    admin_required!
    attendance = Attendance.where(user_id: params[:user_id], speech_id: params[:speech_id])
    unless attendance.empty?
      ActiveRecord::Base.transaction do
        user = User.find(params[:user_id])
        user.change_point(- attendance.take.point - (attendance.take.commented ? 1 : 0))
        user.save!

        Attendance.destroy_all(user_id: params[:user_id], speech_id: params[:speech_id])
      end
    end
    content_type 'text/plain'
    200
  end

end