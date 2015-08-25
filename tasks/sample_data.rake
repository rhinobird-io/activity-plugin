require 'faker'


namespace :db do
  desc 'Fill database with sample data'
  task :populate => :environment do
    Rake::Task['db:reset'].invoke
    ActiveRecord::Base.transaction do
      20.times do
        User.create!({
           point: Faker::Number.number(4),
           role: ''
         })
      end
    end
  end
end
