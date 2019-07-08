class App < Sinatra::Base

  get '/attendances/points' do
    limit = params[:limit] || 1
    start_at = params[:start_at]
    end_at = params[:end_at]
    Attendance.select("user_id, sum(point) as point_total")
      .group("user_id")
      .where("created_at >= ? and created_at <= ?", start_at, end_at)
      .order("point_total desc").limit(limit).to_json
  end
  
  get '/attendances/mostPopularSpeech' do
    limit = params[:limit] || 1
    start_at = params[:start_at]
    end_at = params[:end_at]
    Attendance.select("speech_id, count(user_id) as audience_total")
      .group("speech_id")
      .where("role=? and created_at >= ? and created_at <= ?", Constants::ATTENDANCE_ROLE::AUDIENCE, start_at, end_at)
      .order("audience_total desc").limit(limit).to_json
  end

  get '/attendances/mostAttendance' do
    limit = params[:limit] || 1
    role = params[:role] || Constants::ATTENDANCE_ROLE::AUDIENCE
    start_at = params[:start_at]
    end_at = params[:end_at]
    Attendance.select("user_id, count(user_id) as attendance_total")
      .group("user_id")
      .where("role=? and created_at >= ? and created_at <= ?", role, start_at, end_at)
      .order("attendance_total desc").limit(limit).to_json
  end
end