class AnnouncementsController < ApplicationController
  layout 'home'
  def index
    @notices = Announcement.order('id DESC').page(params[:page]).per(20)
  end

  def new
    @notice = Announcement.new
  end

  def create
    @notice = Announcement.new(notice_params)
    @notice.user = current_user
    if  @notice.save!
      flash[:notice] = "新增关于#{@notice.title} 的公告"
      redirect_to announcements_path
    else
      flash[:alert] = "新增失败"
      render :new
    end
  end

  def edit

  end

  def update

  end

  def destory

  end

  private

   def notice_params
     params.require(:announcement).permit(:title, :content, :user_id, :read)
   end


end
