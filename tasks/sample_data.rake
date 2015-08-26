require 'faker'


namespace :db do
  desc 'Fill database with sample data'
  task :populate => :environment do
    Rake::Task['db:reset'].invoke
    ActiveRecord::Base.transaction do
      20.times do
        User.create!({
           point: Faker::Number.number(4),
           role: 'user'
         })
      end
      20.times do
        Speech.create!({
             title: Faker::Lorem.sentence,
             description: Faker::Lorem.paragraph,
             resource_url: '',
             user_id: Faker::Number.between(1, 20),
             status: 'new',
             category: Faker::Number.between(0, 1) == 0 ? "weekly" : "monthly",
             time: Faker::Time.forward(100),
             expected_duration: Faker::Number.between(10, 180)
         })
      end
      20.times do
        AudienceRegistration.create!({
                             user_id: Faker::Number.between(1, 20),
                             speech_id: Faker::Number.between(1, 20)
                         })
      end
      20.times do
        Attendance.create!({
                             user_id: Faker::Number.between(1, 20),
                             speech_id: Faker::Number.between(1, 20),
                             role: Faker::Number.between(0, 10) == 10 ? "speaker" : "audience",
                             point: Faker::Number.between(1, 50),
                             is_comment: false
                         })
      end
      20.times do
        Prize.create!({
                          name: Faker::Lorem.word,
                          description: Faker::Lorem.paragraph,
                          price: Faker::Number.number(3),
                          picture_url: Faker::Avatar.image
                      })
      end
      20.times do
        Exchange.create!({
                             prize_id: Faker::Number.between(1, 20),
                             user_id: Faker::Number.between(1, 20),
                             point: Faker::Number.number(3),
                             exchange_time: Faker::Time.backward(30)
                         })
      end
    end
  end
end
