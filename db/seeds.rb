User.create!( user_name:     "admin_user",
              display_name:  "admin",
              email:         "admin@railstutorial.org",
              password:      "hogehogehogeo",
              admin:         true,
              activated:     true,
              activated_at:  Time.zone.now)

99.times do |n|
  name  = Faker::Name.first_name
  email = "example-#{n+1}@railstutorial.org"
  password = "password"
  User.create!( user_name:      name,
                display_name:   name,
                email:          email,
                password:       password,
                activated:      true,
                activated_at:   Time.zone.now)
end