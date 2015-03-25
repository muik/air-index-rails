class HomeController < ApplicationController
  def index
    unless cookies[:uuid]
      cookies[:uuid] = SecureRandom.uuid
    end

    @user = User.find_or_create_by(id: cookies[:uuid])

    if request.xhr?
      lat = params[:lat].to_f
      lng = params[:lng].to_f
      s = Station.geo_near([lng, lat]).first
      unless @user.station_id == s.id
        @user.station_id = s.id
        @user.save
      end
      m = s.get_last_measure
      render json: get_response(s, m)
    else
      if @user.station_id
        @station = @user.station 
        @measure = @station.get_last_measure
        @data = get_response(@station, @measure)
      end
    end
  end

  private
  def get_response(s, m)
    {
      station: {
        name: s.name
      },
      measure: {
        grade: m.grade,
        time: m.time.localtime.to_s
      }
    }
  end
end
