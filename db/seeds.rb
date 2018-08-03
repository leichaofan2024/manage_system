# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


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
@not_organs = Workshop.current.where.not(:name => "机关").pluck(:name).uniq
@not_organs.uniq.each do |e|
    User.create(:name => e, :password => "123456", :password_confirmation => "123456").add_role :workshopadmin
end
workshop_count = Workshop.current.where.not(:name => "机关").pluck(:name).uniq.count
puts "共创建#{workshop_count}个车间管理员"
"\n"


puts "创建班组管理员，请稍等。。。"
Group.current.where(:workshop_id => Workshop.current.where(:name => "机关").ids).pluck(:name).each do |i|
  User.create(:name => i, :password => "123456", :password_confirmation => "123456").add_role :organsadmin
end


Group.current.where(:workshop_id => Workshop.current.where.not(:name => "机关").ids).pluck(:name)
@workshops = Workshop.current.where.not(:name => "机关")
@workshops.each do |j|
  groups = Group.current.where(:workshop_id => j.id).pluck(:name).uniq
  groups.uniq.each do |k|
    User.create(:name => (j.name + "-" + k), :password => "123456", :password_confirmation => "123456").add_role :groupadmin
  end
end

group_count = Employee.current.pluck(:group).uniq.count
puts "共创建#{group_count}个班组管理员"

User.all.each do |u|
  if u.has_role? :workshopadmin
    u.update(:workshop_id => Workshop.current.find_by(name: u.name).id)
  elsif u.has_role? :organsadmin
    u.update(:group_id => Group.current.find_by(name: u.name).id.to_i, :workshop_id => Group.current.find_by(name: u.name).workshop_id.to_i)
  elsif u.has_role? :groupadmin
    u.update()
  end
end


User.all.each do |u|
  if u.has_role? :workshopadmin
    u.update(workshop_id: Workshop.find_by(name: u.name).id)
  end
end

User.all.each do |u|
  if u.has_role? :groupadmin
    u.update(workshop_id: Workshop.find_by(name: u.name.split('-')[0]).id, group_id: Group.find_by(name: u.name.split('-')[1]).id)
  end
end

User.all.each do |u|
  if u.has_role? :organsadmin
    u.update(workshop_id: Workshop.find_by(name: '机关').id, group_id: Group.find_by(name: u.name).id)
  end
end

User.all.each do |u|
  if u.has_role? :wgadmin
    u.update(workshop_id: Workshop.find_by(name: u.name.split('-')[0]).id, group_id: Group.find_by(name: u.name).id)
  end
end



User.all.each do |u|
  if u.has_role? :attendance_admin
     u.update(:role_id =>  Role.find_by_name('attendance_admin').id )
  elsif u.has_role? :workshopadmin
   u.update(:role_id =>  Role.find_by_name('workshopadmin').id )
  elsif u.has_role? :awardadmin
   u.update(:role_id =>  Role.find_by_name('awardadmin').id )
  elsif u.has_role? :empadmin
   u.update(:role_id =>  Role.find_by_name('empadmin').id )
  elsif u.has_role? :groupadmin
   u.update(:role_id =>  Role.find_by_name('groupadmin').id )
  elsif u.has_role? :leaderadmin
   u.update(:role_id =>  Role.find_by_name('leaderadmin').id )
  elsif u.has_role? :limitadmin
   u.update(:role_id =>  Role.find_by_name('limitadmin').id )
  elsif u.has_role? :organsadmin
   u.update(:role_id =>  Role.find_by_name('organsadmin').id )
  elsif u.has_role? :saleradmin
   u.update(:role_id =>  Role.find_by_name('saleradmin').id )
  elsif u.has_role? :superadmin
   u.update(:role_id =>  Role.find_by_name('superadmin').id )
  elsif u.has_role? :wgadmin
   u.update(:role_id =>  Role.find_by_name('wgadmin').id )
  end
end
