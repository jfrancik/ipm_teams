# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

User.delete_all
Team.delete_all
Deliverable.delete_all
Contribution.delete_all
HistoryItem.delete_all

Team.create([
	{
		:name => "A1"
	}
])

User.create([ 
	{
		:k_number => "KU32139",
		:first_name => "Jarek",
		:last_name => "Francik",
		:password => "salatka",
		:new_password => "salatka",
		:privilege => 1,
		:key => "",
		:ver => true,
		:salt => SecureRandom.base64(8),
		:passwd_reset => false,
		:team_id => 0,
		:test_mark_A => 0,  
		:test_mark_B => 0,  
		:test_mark => 0
	}
])