# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
# 更新每个车间下的班组




puts "创建多个管理员"
User.create(name: "超级管理员", password: "123456", password_confirmation: "123456").add_role :superadmin
User.create(name: "供电段管理员", password: "123456", password_confirmation: "123456").add_role :leaderadmin
User.create(name: "现员管理员", password: "123456", password_confirmation: "123456").add_role :empadmin
User.create(name: "考勤管理员", password: "123456", password_confirmation: "123456").add_role :attendance_admin
User.create(name: "定额管理员", password: "123456", password_confirmation: "123456").add_role :limitadmin
User.create(name: "财务管理员", password: "123456", password_confirmation: "123456").add_role :saleradmin
User.create(name: "奖惩管理员", password: "123456", password_confirmation: "123456").add_role :awardadmin
User.create(name: "收入管理员", password: "123456", password_confirmation: "123456").add_role :incomeadmin

User.create(name: "段长", password: "123456", password_confirmation: "123456").add_role :leaderadmin
User.create(name: "书记", password: "123456", password_confirmation: "123456").add_role :leaderadmin
User.create(name: "副段长-许", password: "123456", password_confirmation: "123456").add_role :depudy_leaderadmin
User.create(name: "副段长-安", password: "123456", password_confirmation: "123456").add_role :depudy_leaderadmin
User.create(name: "副段长-贾", password: "123456", password_confirmation: "123456").add_role :depudy_leaderadmin
User.create(name: "副段长-孟", password: "123456", password_confirmation: "123456").add_role :depudy_leaderadmin
User.create(name: "副段长-苏", password: "123456", password_confirmation: "123456").add_role :depudy_leaderadmin
User.create(name: "副段长-孙", password: "123456", password_confirmation: "123456").add_role :depudy_leaderadmin
User.create(name: "副段长-武", password: "123456", password_confirmation: "123456").add_role :depudy_leaderadmin
User.create(name: "纪委书记", password: "123456", password_confirmation: "123456").add_role :depudy_leaderadmin
User.create(name: "工会主席", password: "123456", password_confirmation: "123456").add_role :depudy_leaderadmin
"\n"

User.create(name: "企业管理员", password: "123456", password_confirmation: "123456").add_role :company_admin
User.create(name: "安全生产调度指挥中心", password: "123456", password_confirmation: "123456").add_role :safe_productionadmin
User.create(name: "承德南综合维修车间",workshop_id: 30, password: "123456", password_confirmation: "123456").add_role :workshopadmin
User.create(name: "承德南综合维修车间-承德南高铁供电运行工区",workshop_id: 30,group_id: 898, password: "123456", password_confirmation: "123456").add_role :groupadmin
User.create(name: "承德南综合维修车间-平泉北高铁供电运行工区",workshop_id: 30,group_id: 900, password: "123456", password_confirmation: "123456").add_role :groupadmin
User.create(name: "承德南综合维修车间-京沈介入班",workshop_id: 30,group_id: 901, password: "123456", password_confirmation: "123456").add_role :groupadmin
User.create(name: "承德南综合维修车间-车间",workshop_id: 30,group_id: 902, password: "123456", password_confirmation: "123456").add_role :wgadmin
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




#######################################################################################
Group.where(:name => '车间').pluck(:workshop_id).uniq.each do |i|
  Group.where(:name => '车间', :workshop_id => i).update(:name => Workshop.find(i).name + '-车间')
end

Group.where(:name => '车间车班').pluck(:workshop_id).uniq.each do |i|
  Group.where(:name => '车间车班', :workshop_id => i).update(:name => Workshop.find(i).name + '-车间车班')
end

Group.where(:name => '汽车班').pluck(:workshop_id).uniq.each do |i|
  Group.where(:name => '汽车班', :workshop_id => i).update(:name => Workshop.find(i).name + '-汽车班')
end
#######################################################################################

a = "-车间"
User.where("name LIKE ?", ['%', "#{a}", '%'].join).each do |u|
  u.remove_role :groupadmin
end

b = "-车间车班"
User.where("name LIKE ?", ['%', "#{b}", '%'].join).each do |u|
  u.remove_role :groupadm
end

c = "-汽车班"
User.where("name LIKE ?", ['%', "#{c}", '%'].join).each do |u|
  u.remove_role :groupadmin
end


User.where("name LIKE ?", ['%', "#{a}", '%'].join).each do |u|
  u.add_role :wgadmin
end


User.where("name LIKE ?", ['%', "#{b}", '%'].join).each do |u|
  u.add_role :wgadmin
end


User.where("name LIKE ?", ['%', "#{c}", '%'].join).each do |u|
  u.add_role :wgadmin
end





#######################################################################################
# 更新每个用户的workshop_id 和 group_id
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
#######################################################################################


# 增加调离种类：
["辞职","局内调动","在职死亡","退休"].each do |name|
  LeavingCategory.create(:name => name)
end
