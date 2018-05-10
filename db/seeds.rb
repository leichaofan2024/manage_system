# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

puts "创建多个管理员"
User.create(name: "超级管理员", password: "123456", password_confirmation: "123456")
User.create(name: "现员管理员", password: "123456", password_confirmation: "123456")
User.create(name: "考勤管理员", password: "123456", password_confirmation: "123456")
User.create(name: "定额管理员", password: "123456", password_confirmation: "123456")
User.create(name: "财务管理员", password: "123456", password_confirmation: "123456")
User.create(name: "奖惩管理员", password: "123456", password_confirmation: "123456")
puts "管理员创建成功"
"\n"


puts "创建车间管理员，请稍等。。。"
Employee.pluck(:workshop).uniq.each do |e|
  if e == "内退"
    User.create(:name => "内退管理员", :password => "123456", :password_confirmation => "123456")
  elsif e == "见习生"
    User.create(:name => "见习生管理员", :password => "123456", :password_confirmation => "123456")
  else
    User.create(:name => e, :password => "123456", :password_confirmation => "123456")
  end
end
workshop_count = Employee.pluck(:workshop).uniq.count
puts "共创建#{workshop_count}个车间管理员"
"\n"


puts "创建班组管理员，请稍等。。。"
Employee.pluck(:group).uniq.each do |e|
  User.create(:name => e, :password => "123456", :password_confirmation => "123456")
end
group_count = Employee.pluck(:group).uniq.count
puts "共创建#{group_count}个班组管理员"
