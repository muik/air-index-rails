# Load the Rails application.
require File.expand_path('../application', __FILE__)

# sidekiq의 worker에서 export한 환경변수를 읽어오지 못해 파일로 불러오기
if !ENV['MONGOID_USERNAME'] && (Rails.env == 'production' or Rails.env == 'staging')
  begin
    require File.expand_path('../../../../shared/env', __FILE__)
  rescue Exception => e
    require File.expand_path('../../../shared/env', __FILE__)
  end
end 

# Initialize the Rails application.
Rails.application.initialize!
