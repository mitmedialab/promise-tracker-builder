desc "generate new api key"
task :create_api_key, [:username] => :environment do |task, args|
  ApiKey.create!(client_name: args[:username])
end