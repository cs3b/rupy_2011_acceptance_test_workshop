# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Emanuel', :city => cities.first)


SpreeCore::Engine.load_seed if defined?(SpreeCore)
SpreeAuth::Engine.load_seed if defined?(SpreeAuth)


# Taxonomies

Taxonomy.create(:name => 'Categories')

# Products

%w(pinaple apple lemon raspberries orange).each do |fruit|
  Product.create(:name => fruit, :available_on => Time.now-12.hours, :description => '', :price => rand(12)+3)
end
