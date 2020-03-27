namespace :test do
  task test_host: :environment do
    puts CURRENT_HOST
  end
end

