require 'yaml'
require 'resque'

Resque.redis = Redis.new
unless Rails.env.test?
  Resque.logger = Logger.new(Rails.root.join("log/resque.log"))
end
Resque.after_fork = Proc.new { ApplicationRecord.establish_connection }
