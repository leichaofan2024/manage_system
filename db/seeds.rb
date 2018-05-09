# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

printf "创建多个管理员"
User.create(name: "超级管理员", password: "123456", password_confirmation: "123456")
User.create(name: "现员管理员", password: "123456", password_confirmation: "123456")
User.create(name: "考勤管理员", password: "123456", password_confirmation: "123456")
User.create(name: "定额管理员", password: "123456", password_confirmation: "123456")
User.create(name: "财务管理员", password: "123456", password_confirmation: "123456")
User.create(name: "奖惩管理员", password: "123456", password_confirmation: "123456")

printf "创建成功"
