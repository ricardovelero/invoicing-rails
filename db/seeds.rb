#run seed file based on development
puts "Seeding database"
load(Rails.root.join("db", "seeds", "development.rb"))
