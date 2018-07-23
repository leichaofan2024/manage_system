class DivideLevelWagesController < ApplicationController
  layout "home"


  def index

  end

  def new
  end

  def new_line
  end

  def create_line
    if params[:name].present?
      @name = params[:name]
      @params_hash = params.delete_if{|key,value| ["utf8","authenticity_token","commit","controller","action","name"].include?(key) || (value =="")}
      @divide_level_wage = DivideLevelWage.new(:name => @name, :formula => @params_hash)
      if @divide_level_wage.save
        redirect_to divide_level_wages_path
      else
        flash[:warning] = "项目名称不能重复！"
        render "divide_level_wages/new_line"
      end
    else
      flash[:warning] = "项目名称不能为空!"
      render "divide_level_wages/new_line"
    end
  end

  def edit_line
    @dividelevelwage = DivideLevelWage.find(params[:id])
  end

  def update_line
    if params[:name].present?
      @name = params[:name]
      @params_hash = params.delete_if{|key,value| ["utf8","authenticity_token","commit","controller","action","name"].include?(key) || (value =="")}
      @divide_level_wage = DivideLevelWage.new(:name => @name, :formula => @params_hash)
      if @divide_level_wage.save
        redirect_to divide_level_wages_path
      else
        flash[:warning] = "项目名称不能重复！"
        render "divide_level_wages/new_line"
      end
    else
      flash[:warning] = "项目名称不能为空!"
      render "divide_level_wages/new_line"
    end
  end

  def delete_line
    @dividelevelwage = DivideLevelWage.find(params[:id])
    name  =  @dividelevelwage.name
    @dividelevelwage.delete
    flash[:notice] = "已删除'#{name}'!"
    redirect_to divide_level_wages_path
  end

  def new_head
   @divide_head_name = "col"+(DivideLevelWageHead.count+1).to_s
   @wage_header_hash = Hash.new
    WageHeader.all.each do |wage_header|
      key = "col"+wage_header.id.to_s
      @wage_header_hash[key] = wage_header.header
    end
  end

  def create_head
    if params[:head_name].present?
      divide_head_name= params[:divide_head_name]
      @name = params[:head_name]
      @params_hash = params.delete_if{|key,value| ["utf8","authenticity_token","commit","controller","action","head_name","divide_head_name"].include?(key) || (value =="")}
      @divide_level_wage_head = DivideLevelWageHead.new(:head_name => @name, :divide_head_name => divide_head_name,:formula => @params_hash)
      if @divide_level_wage_head.save
        redirect_to divide_level_wages_path
      else
        flash[:warning] = "项目名称不能重复！"
        render "divide_level_wages/new_head"
      end
    else
      flash[:warning] = "项目名称不能为空!"
      render "divide_level_wages/new_head"
    end
  end
  def create
  end

  def edit

  end

  def update

  end



  def create_header
    if WageHeader.find_by(header: params[:header]).present?
      flash[:alert] = "您填写的表头已存在"
    else
      WageHeader.create(header: params[:header])
      flash[:notice] = "新增成功"
    end
    redirect_to import_wage_wages_path
  end

  def edit_header
    wage_header = WageHeader.find_by(header: params[:before_header])
    wage_header.update(header: params[:after_header])
    flash[:notice] = "修改成功"
    redirect_to import_wage_wages_path
  end

  # private
  #
  # def divide_level_wage_params
  #   params.require(:divide_level_wage).permit(:formula ,:name)
  # end
end
