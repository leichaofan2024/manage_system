class MessagesController < ApplicationController
	layout 'home'

	def index
		if current_user.has_role? :empadmin
			@messages = Message.where(:user_id => "2")
		elsif current_user.has_role? :attendance_admin
			@messages = Message.where(:user_id => "3")
		elsif current_user.has_role? :superadmin
			@messages = Message.where(:user_id => "1")
		end
	end

	def update_have_read
		@message = Message.find(params[:id])
		if @message.update(:have_read => "1")
			flash[:notice] = "已设置为已读~"
		end
		redirect_back(fallback_location: messages_path)
	end
end
