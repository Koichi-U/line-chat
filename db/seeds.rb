# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

User.create!(
   email: 'test@test.com',
   password: 'aaaaaa',
   admin: true,
   active: true
)

Lineuser.create!(
   displayname: "内田光一",
   userid: "U9a84a5528333b26242a4ee9f377128c4",
   language: "ja",
   pictureurl: "https://profile.line-scdn.net/0m02d92e6a72518b95e464e154ebff91e90bd054ab0ae8",
   statusmessage: nil,
   active: true,
   lastmessagetime: DateTime.new(2022, 10, 9, 3, 11, 12, '+09:00')
)

Lineuser.create!(
   displayname: "Shiho",
   userid: "U02cfa3d8de3b99cfb00ac4a5cdf0d5d7",
   language: "ja",
   pictureurl: "https://sprofile.line-scdn.net/0hy2RNVCAgJh1_NzK0EFVYYg9nJXdcRn8PWgZgK08wKyVBUGYbUVhqLk5kLH4QUDYYA1ZpKxkyLC1zJFF7YWHaKXgHeCpGAWVJVlht-Q",
   statusmessage: nil,
   active: true,
   lastmessagetime: DateTime.new(2022, 10, 3, 3, 11, 12, '+09:00')
)
