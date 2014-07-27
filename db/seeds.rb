# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Sheet.create(title: "Another Guldove", description: "Guitar piece by Yasunori Mitsuda, from Chrono Cross.", pages: 2, instruments: [:guitar], tag_list: [:summer])

Sheet.create(title: "Another Marbule", description: "Guitar piece by Yasunori Mitsuda, from Chrono Cross.", pages: 2, instruments: [:piano], tag_list: [:summer, :memories])

Sheet.create(title: "Another Termina", description: "Guitar piece by Yasunori Mitsuda, from Chrono Cross.", pages: 2, instruments: [:guitar], tag_list: [:summer, :memories, :beach])