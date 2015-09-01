class App < Sinatra::Base

  # retrieve speeches sorted by time in desc order
  # retrieve confirmed and finished speeches by default
  # you can use a query parameter 'status' to retrieve speeches in other status
  # use comma to separate each status
  # /speeches?status=auditing,confirmed
  get '/speeches' do
    status = params[:status] || Constants::CONFIRMED + ',' + Constants::FINISHED
    Speech.where(status: status.gsub(/\s+/, '').split(',')).order(time: :desc).to_json
  end

  # retrieve a speech, including applied audiences (not finished) or participants (finished)
  get '/speeches/:speech_id' do
    speech = Speech.find(params[:speech_id])
    if speech.status == Constants::FINISHED
      speech.to_json(include: :participants)
    else
      speech.to_json(include: :audiences)
    end
  end

  # add a speech, status = new
  post '/speeches' do
    speech = Speech.new(title: @body['title'], description: @body['description'],
                        user_id: @userid, expected_duration: @body['expected_duration'],
                        status: Constants::NEW, category: @body['category'])
    speech.save!
    speech.to_json
  end

  # update the basic information of the speech in 'new' status
  # only 'new' speeches can be edited
  put '/speeches/:speech_id' do
    speech = Speech.find(params[:speech_id])
    self_required! speech.user_id
    if speech.status != Constants::NEW
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
    if speech.status == Constants::NEW
      speech.destroy!
      200
    else
      400
    end
  end

  # upload resource to the speech
  post '/speeches/:speech_id/upload' do
    speech = Speech.find(params[:speech_id])
    self_required! speech.user_id
    if speech.status == Constants::CONFIRMED
      speech.resource_url = @body['resource_url']
      speech.save!
      200
    else
      400
    end
  end

  # new -> auditing
  post '/speeches/:speech_id/submit' do
    speech = Speech.find(params[:speech_id])
    self_required! speech.user_id
    if speech.status == Constants::NEW
      speech.status = Constants::AUDITING
      speech.save!
      200
    else
      400
    end
  end
  # auditing || approved -> new, by speaker
  post '/speeches/:speech_id/withdraw' do
    speech = Speech.find(params[:speech_id])
    self_required! speech.user_id
    if speech.status == Constants::AUDITING || speech.status == Constants::APPROVED
      speech.status = Constants::NEW
      speech.save!
      200
    else
      400
    end
  end
  # auditing -> approved
  post '/speeches/:speech_id/approve' do
    admin_required!
    speech = Speech.find(params[:speech_id])
    if speech.status == Constants::AUDITING
      speech.status = Constants::APPROVED
      speech.time = @body['time']
      speech.save!
      200
    else
      400
    end
  end
  # auditing -> new, by admin
  post '/speeches/:speech_id/reject' do
    admin_required!
    speech = Speech.find(params[:speech_id])
    if speech.status == Constants::AUDITING
      speech.status = Constants::NEW
      speech.save!
      200
    else
      400
    end
  end
  # approved -> confirmed
  post '/speeches/:speech_id/agree' do
    puts request.cookies
    speech = Speech.find(params[:speech_id])
    self_required! speech.user_id
    if speech.status == Constants::APPROVED
      ActiveRecord::Base.transaction do
        speech.status = Constants::CONFIRMED
        speech.save!
        CalendarHelper::post_event(request.cookies, speech.title, speech.description, speech.time, speech.time)
      end
      200
    else
      400
    end
  end
  # approved -> auditing
  post '/speeches/:speech_id/disagree' do
    speech = Speech.find(params[:speech_id])
    self_required! speech.user_id
    if speech.status == Constants::APPROVED
      speech.status = Constants::AUDITING
      speech.save!
      200
    else
      400
    end
  end
  # confirmed -> closed
  post '/speeches/:speech_id/close' do
    admin_required!
    speech = Speech.find(params[:speech_id])
    if speech.status == Constants::CONFIRMED
      speech.status = Constants::CLOSED
      speech.save!
      200
    else
      400
    end
  end
  # confirmed -> finish
  post '/speeches/:speech_id/finish' do
    admin_required!
    speech = Speech.find(params[:speech_id])
    if speech.status == Constants::CONFIRMED
      speech.status = Constants::FINISHED
      speech.save!
      200
    else
      400
    end
  end

  get '/speeches/:speech_id/audiences' do
    Speech.find(params[:speech_id]).audiences.to_json
  end

  # user apply to be an audience
  post '/speeches/:speech_id/audiences' do
    audience = AudienceRegistration.new(user_id: @userid, speech_id: params[:speech_id])
    audience.save!
    audience.to_json
  end

  # user withdraw his apply to be an audience
  delete '/speeches/:speech_id/audiences/:user_id' do
    self_required! params[:user_id].to_i
    AudienceRegistration.destroy_all(user_id: params[:user_id], speech_id: params[:speech_id])
    200
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
    200
  end

end