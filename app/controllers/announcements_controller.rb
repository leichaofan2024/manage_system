class AnnouncementsController < ApplicationController
  layout 'home'
  def index
    @notices = Announcement.order('id DESC').page(params[:page]).per(20)
  end

  def show
    @notice = Announcement.find(params[:id])
  end

  def new
    @notice = Announcement.new
  end

  def create
    @notice = Announcement.new(notice_params)
    @notice.user_id = current_user.id
    if  @notice.save
      flash[:notice] = "新增关于#{@notice.title} 的公告"
      redirect_to announcements_path
    else
      flash[:alert] = "新增失败"
      render :new
    end

  end

  def edit
    @notice = Announcement.find(params[:id])
  end

  def update
    @notice = Announcement.find(params[:id])
    if @notice.update(notice_params)
      flash[:notice] = "更新成功"
      redirect_to announcements_path
    else
      flash[:warning] = "更新失败"
      render :edit
    end
  end

  def destroy
    @notice = Announcement.find(params[:id])
    if @notice.destroy
      flash[:notice] = "已删除"
      redirect_to announcements_path
    else
      flash[:warning] = "删除失败"
    end
  end


  #表模板下载
  def download_table_template
    @relative_salers = RelativeSaler.page(params[:page]).per(20)
    respond_to do |format|
      format.html
      format.csv { send_data @relative_salers.to_csv}
      format.xls
    end
  end

  def download_charge_details_table_template
    respond_to do |format|
      format.html
      format.csv { send_data to_csv}
      format.xls
    end
  end

  def download_rectification_awards_table_template
    respond_to do |format|
      format.html
      format.csv { send_data to_csv}
      format.xls
    end
  end

  def download_middle_awards_table_template
    respond_to do |format|
      format.html
      format.csv { send_data to_csv}
      format.xls
    end
  end

  def download_teamleader_awards_table_template
    respond_to do |format|
      format.html
      format.csv { send_data to_csv}
      format.xls
    end
  end

  def download_other_awards_table_template
    respond_to do |format|
      format.html
      format.csv { send_data to_csv}
      format.xls
    end
  end

  def download_emp_table_template
    respond_to do |format|
      format.html
      format.csv { send_data to_csv}
      format.xls
    end
  end

  def download_examination_awards_table_template
    respond_to do |format|
      format.html
      format.csv { send_data to_csv}
      format.xls
    end
  end

  def download_people_change_table_template
    respond_to do |format|
      format.html
      format.csv { send_data to_csv}
      format.xls
    end
  end

  def download_examination_charges_table_template
    respond_to do |format|
      format.html
      format.csv { send_data to_csv}
      format.xls
    end
  end

  private

   def notice_params
     params.require(:announcement).permit(:title, :content, :user_id, :read)
   end


end
