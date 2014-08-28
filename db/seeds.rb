# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.create(email:'test@example.com', username:"System" , password: 'password', password_confirmation: 'password')

Sheet.create(user_id: 1, title: "Another Guldove", description: "Guitar piece by Yasunori Mitsuda, from Chrono Cross.", pages: 2, instruments: [:guitar], composer_list: ["Yasunori Mitsuda".to_sym], genre_list: [:videogame, :fingerstyle] ,tag_list: [:summer], source_list: ["Chrono Cross".to_sym])

Sheet.create(user_id: 1, title: "Another Marbule", description: "Guitar piece by Yasunori Mitsuda, from Chrono Cross.", pages: 2, composer_list: ["Yasunori Mitsuda".to_sym], genre_list: [:fingerstyle] , instruments: [:piano])

Sheet.create(user_id: 1, title: "Another Termina", description: "Guitar piece by Yasunori Mitsuda, from Chrono Cross.", pages: 2, composer_list: ["Yasunori Mitsuda".to_sym], genre_list: [:videogame],  instruments: [:guitar])

seed_data = []
50.times do
  seed_data << {user_id: 1, title: Faker::Company.name, description: Faker::Company.bs}
end
Sheet.create(seed_data)