class Message < ApplicationRecord
	belongs_to :user, :foreign_key => "user_id"

	def self.retirement_remind
		employees = Employee.where(age: 60)
		employees.each do |employee|
			a = Time.now - employee.birth_date.to_datetime
			b = 60*365*24*60*60 - a
			month = (b/3600/24/30).round
			day = (b/3600/24%30).round
			Message.create(message_type: "退休提醒", message: "#{employee.name}还有#{month}个月#{day}天到60岁", user_id: 2, have_read: 0, remind_time: Time.now)
		end
	end
end
 