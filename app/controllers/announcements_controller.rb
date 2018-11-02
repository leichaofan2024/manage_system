class AnnouncementsController < ApplicationController
  before_action :required_is_admin, only: [:new, :create, :edit, :update]
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

  # 模版首页：
  def download_table_template
  end

  #工挂工资明细表（科室下载）
  def download_workshop_relative_saler_table_template
    respond_to do |format|
      format.html
      format.csv { send_data to_csv}
      format.xls { headers["Content-Disposition"] = 'attachment; filename="工挂工资明细表.xls"'}
    end
  end


  #单项奖明细表（科室下载）
  def download_workshop_single_award_table_template
    respond_to do |format|
      format.html
      format.csv { send_data to_csv}
      format.xls { headers["Content-Disposition"] = 'attachment; filename="单项奖明细表.xls"'}
    end
  end

  #工挂工资明细表（劳资下载）
  def download_relative_saler_table_template
    respond_to do |format|
      format.html
      format.csv { send_data to_csv}
      format.xls { headers["Content-Disposition"] = 'attachment; filename="工挂工资明细表(劳资专用).xls"'}
    end
  end

  #工挂工资汇总表（劳资下载）
  def download_relative_salers_total_table_template
    respond_to do |format|
      format.html
      format.csv { send_data to_csv}
      format.xls { headers["Content-Disposition"] = 'attachment; filename="工挂工资汇总表.xls"'}
    end
  end

  #考核扣款明细表（劳资下载）
  def download_charge_details_table_template
    respond_to do |format|
      format.html
      format.csv { send_data to_csv}
      format.xls { headers["Content-Disposition"] = 'attachment; filename="考核扣款明细表.xls"'}
    end
  end

  #整改返奖明细表（劳资下载）
  def download_rectification_awards_table_template
    respond_to do |format|
      format.html
      format.csv { send_data to_csv}
      format.xls { headers["Content-Disposition"] = 'attachment; filename="整改返奖明细表.xls"'}
    end
  end

  #中层返奖细表（劳资下载）
  def download_middle_awards_table_template
    respond_to do |format|
      format.html
      format.csv { send_data to_csv}
      format.xls { headers["Content-Disposition"] = 'attachment; filename="中层返奖细表.xls"'}
    end
  end

  #班组长返奖明细表（劳资下载）
  def download_teamleader_awards_table_template
    respond_to do |format|
      format.html
      format.csv { send_data to_csv}
      format.xls { headers["Content-Disposition"] = 'attachment; filename="班组长返奖明细表.xls"'}
    end
  end

  #其他返奖明细表（劳资下载）
  def download_other_awards_table_template
    respond_to do |format|
      format.html
      format.csv { send_data to_csv}
      format.xls { headers["Content-Disposition"] = 'attachment; filename="其他返奖明细表.xls"'}
    end
  end

  #现员表（科室下载）
  def download_emp_table_template
    respond_to do |format|
      format.html
      format.csv { send_data to_csv}
      format.xls { headers["Content-Disposition"] = 'attachment; filename="现员表.xls"'}
    end
  end

  #抽考返奖明细表（科室下载）
  def download_examination_awards_table_template
    respond_to do |format|
      format.html
      format.csv { send_data to_csv}
      format.xls { headers["Content-Disposition"] = 'attachment; filename="抽考返奖明细表.xls"'}
    end
  end

  #人员变动明细表（科室下载）
  def download_people_change_table_template
    respond_to do |format|
      format.html
      format.csv { send_data to_csv}
      format.xls { headers["Content-Disposition"] = 'attachment; filename="人员变动明细表.xls"'}
    end
  end

  #抽考扣款明细表（科室下载）
  def download_examination_charges_table_template
    respond_to do |format|
      format.html
      format.csv { send_data to_csv}
      format.xls { headers["Content-Disposition"] = 'attachment; filename="抽考扣款明细表.xls"'}
    end
  end

  #红牌中层扣款明细表（科室下载）
  def download_red_middle_charges_table_template
    respond_to do |format|
      format.html
      format.csv { send_data to_csv}
      format.xls { headers["Content-Disposition"] = 'attachment; filename="红牌中层扣款明细表.xls"'}
    end
  end


  #标准化汇总表（科室下载）
  def download_standard_award_total_table_template
    respond_to do |format|
      format.html
      format.csv { send_data to_csv}
      format.xls { headers["Content-Disposition"] = 'attachment; filename="标准化汇总表.xls"'}
    end
  end

  #标准化班组表（科室下载）
  def download_standard_group_table_template
    respond_to do |format|
      format.html
      format.csv { send_data to_csv}
      format.xls { headers["Content-Disposition"] = 'attachment; filename="标准化班组表.xls"'}
    end
  end

  #星级岗奖励总明细表（科室下载）
  def download_star_award_table_template
    respond_to do |format|
      format.html
      format.csv { send_data to_csv}
      format.xls { headers["Content-Disposition"] = 'attachment; filename="星级岗奖励总明细表.xls"'}
    end
  end

  #其他单项奖总明细表（科室下载）
  def download_other_award_total_table_template
    respond_to do |format|
      format.html
      format.csv { send_data to_csv}
      format.xls { headers["Content-Disposition"] = 'attachment; filename="其他单项奖总明细表.xls"'}
    end
  end

  private

   def notice_params
     params.require(:announcement).permit(:title, :content, :user_id, :read)
   end


end
