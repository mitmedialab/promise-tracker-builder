desc "generate new api key"
task :create_api_key, [:username] => :environment do |task, args|
  ApiKey.create!(user: args[:username])
end