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
User.create(name: "供电段管理员", password: "123456", password_confirmation: "123456").add_role :leaderadmin
User.create(name: "现员管理员", password: "123456", password_confirmation: "123456").add_role :empadmin
User.create(name: "考勤管理员", password: "123456", password_confirmation: "123456").add_role :attendance_admin
User.create(name: "定额管理员", password: "123456", password_confirmation: "123456").add_role :limitadmin
User.create(name: "财务管理员", password: "123456", password_confirmation: "123456").add_role :saleradmin
User.create(name: "奖惩管理员", password: "123456", password_confirmation: "123456").add_role :awardadmin
"\n"



puts "创建车间管理员，请稍等。。。"
@not_organs = Workshop.where.not(:name => "机关").pluck(:name).uniq
@not_organs.uniq.each do |e|
    User.create(:name => e, :password => "123456", :password_confirmation => "123456").add_role :workshopadmin
end
workshop_count = Workshop.where.not(:name => "机关").pluck(:name).uniq.count
puts "共创建#{workshop_count}个车间管理员"
"\n"


puts "创建班组管理员，请稍等。。。"
Group.where(:workshop_id => Workshop.where(:name => "机关").ids).pluck(:name).each do |i|
  User.create(:name => i, :password => "123456", :password_confirmation => "123456").add_role :organsadmin
end


Group.where(:workshop_id => Workshop.where.not(:name => "机关").ids).pluck(:name)
@workshops = Workshop.where.not(:name => "机关")
@workshops.each do |j|
  groups = Group.where(:workshop_id => j.id).pluck(:name).uniq
  groups.uniq.each do |k|
    User.create(:name => (j.name + "-" + k), :password => "123456", :password_confirmation => "123456").add_role :groupadmin
  end
end

group_count = Employee.current.pluck(:group).uniq.count
puts "共创建#{group_count}个班组管理员"



    [ 4] "groupadmin",
    [ 7] "organsadmin",
    [10] "wgadmin",
    [11] "workshopadmin"


User.all.each do |u|
  if u.has_role? :workshopadmin
    u.update(:workshop_id => Workshop.find_by(name: u.name).id.to_i)
  elsif u.has_role? :organsadmin
    u.update(:group_id => Group.find_by(name: u.name).id.to_i, :workshop_id => Group.find_by(name: u.name).workshop_id.to_i)
  end
end
