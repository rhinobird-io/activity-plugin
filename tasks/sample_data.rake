require 'faker'


namespace :db do
  desc 'Fill database with sample data'
  task :populate => :environment do
    Rake::Task['db:reset'].invoke
    ActiveRecord::Base.transaction do
      p = Faker::Number.number(4)
      User.create!({
                       point_total: p,
                       point_available: Faker::Number.between(1, p.to_i),
                       role: Constants::USER_ROLE::ADMIN
                   })
      19.times do
        p = Faker::Number.number(4)
        User.create!({
                         point_total: p,
                         point_available: Faker::Number.between(1, p.to_i),
                         role: Constants::USER_ROLE::USER
                     })
      end
      Constants::SPEECH_STATUS.constants.each do |status|
        10.times do
          Speech.create!({
                             title: Faker::Lorem.sentence,
                             description: Faker::Lorem.paragraph,
                             resource_url: '',
                             user_id: 16,#Faker::Number.between(1, 20),
                             status: Constants::SPEECH_STATUS.const_get(status),
                             category: Faker::Number.between(0, 1) == 0 ? Constants::SPEECH_CATEGORY::WEEKLY : Constants::SPEECH_CATEGORY::MONTHLY,
                             time: Faker::Time.between(1.months.ago, 3.months.from_now),
                             expected_duration: Faker::Number.between(10, 180)
                         })
        end
      end


      20.times do
        AudienceRegistration.create!({
                             user_id: 16,#Faker::Number.between(1, 20),
                             speech_id: Faker::Number.between(1, 60)
                         })
      end
      20.times do
        Attendance.create!({
                             user_id: 16,#Faker::Number.between(1, 20),
                             speech_id: Faker::Number.between(1, 60),
                             role: Faker::Number.between(0, 10) == 10 ? Constants::ATTENDANCE_ROLE::SPEAKER : Constants::ATTENDANCE_ROLE::AUDIENCE,
                             point: Faker::Number.between(1, 50),
                             commented: false
                         })
      end
      20.times do
        Prize.create!({
                          name: Faker::Lorem.word,
                          description: Faker::Lorem.paragraph,
                          price: Faker::Number.number(3),
                          picture_url: Faker::Avatar.image,
                          exchanged_times: Faker::Number.number(3)
                      })
      end
      20.times do
        Exchange.create!({
                             prize_id: Faker::Number.between(1, 20),
                             user_id: Faker::Number.between(1, 20),
                             point: Faker::Number.number(3),
                             exchange_time: Faker::Time.backward(30),
                             status: Constants::EXCHANGE_STATUS::NEW
                         })
      end
    end
  end
end
