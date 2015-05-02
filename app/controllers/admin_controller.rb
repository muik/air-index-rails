class AdminController < ApplicationController
  if Rails.env.production?
    http_basic_authenticate_with :name => ENV["ADMIN_USERNAME"], :password => ENV["ADMIN_PASSWORD"]
  end

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
end
