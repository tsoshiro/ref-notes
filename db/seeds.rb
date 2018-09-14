User.create!(user_name:  "Example User",
             email: "example@railstutorial.org",
             password:              "hogehogehogeo",
             admin: true)

99.times do |n|
  name  = Faker::Name.name
  email = "example-#{n+1}@railstutorial.org"
  password = "password"
  User.create!(user_name:  name,
               email: email,
               password:              password
               )
end