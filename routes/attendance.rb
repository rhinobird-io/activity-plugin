class App < Sinatra::Base

  # retrieve rank points with time range
  get '/attendances/points' do
    limit = params[:limit] || 10
    start_at = params[:start_at]
    Attendance.select("user_id, sum(point) as point_total")
      .where("created_at >= ?", start_at)
      .group("user_id")
      .order("point_total desc").limit(limit).to_json
  end

end
