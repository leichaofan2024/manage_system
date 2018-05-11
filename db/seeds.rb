# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# puts "创建用户角色"
# Role.create(:name => "superadmin")        #超级管理员
# Role.create(:name => "empadmin")          #现员管理员
# Role.create(:name => "attendance_admin")  #考勤管理员
# Role.create(:name => "saleradmin")        #工资管理员
# Role.create(:name => "awardadmin")        #奖惩管理员
# Role.create(:name => "limitadmin")        #定额管理员
# Role.create(:name => "organsadmin")       #机关管理员
# Role.create(:name => "workshopadmin")     #车间管理员
# Role.create(:name => "groupadmin")        #班组管理员


puts "创建多个管理员"
User.create(name: "超级管理员", password: "123456", password_confirmation: "123456").add_role :superadmin
User.create(name: "现员管理员", password: "123456", password_confirmation: "123456").add_role :empadmin
User.create(name: "考勤管理员", password: "123456", password_confirmation: "123456").add_role :attendance_admin
User.create(name: "定额管理员", password: "123456", password_confirmation: "123456").add_role :limitadmin
User.create(name: "财务管理员", password: "123456", password_confirmation: "123456").add_role :saleradmin
User.create(name: "奖惩管理员", password: "123456", password_confirmation: "123456").add_role :awardadmin
"\n"



puts "创建车间管理员，请稍等。。。"
Employee.pluck(:workshop).uniq.each do |e|
  if e == "内退"
    User.create(:name => "内退管理员", :password => "123456", :password_confirmation => "123456").add_role :workshopadmin
  elsif e == "见习生"
    User.create(:name => "见习生管理员", :password => "123456", :password_confirmation => "123456").add_role :workshopadmin
  elsif e == "机关"
    User.create(:name => e, :password => "123456", :password_confirmation => "123456").add_role :organsadmin
  else
    User.create(:name => e, :password => "123456", :password_confirmation => "123456").add_role :workshopadmin
  end
end
workshop_count = Employee.pluck(:workshop).uniq.count
puts "共创建#{workshop_count}个车间管理员"
"\n"


puts "创建班组管理员，请稍等。。。"
@employees = Employee.all
@employees.where(:workshop => "机关").pluck(:group).uniq.each do |i|
  User.create(:name => i, :password => "123456", :password_confirmation => "123456").add_role :organsadmin
end

@workshops = Employee.where.not(:workshop => "机关").pluck(:workshop).uniq
@workshops.each do |j|
  groups = Employee.where(:workshop => j).pluck(:group).uniq
  groups.uniq.each do |k|
    User.create(:name => (j + "-" + k), :password => "123456", :password_confirmation => "123456").add_role :groupadmin
  end
end

group_count = Employee.pluck(:group).uniq.count
puts "共创建#{group_count}个班组管理员"
