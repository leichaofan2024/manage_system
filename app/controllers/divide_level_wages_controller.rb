class DivideLevelWagesController < ApplicationController
  layout "home"


  def index
    @years = Wage.pluck("year").uniq
    @months = [["选择月份"]]

    if @years.present?
      @years.each do |year|
        @months<< Wage.where(:year => year).pluck("month").uniq.compact
      end
    end
    gon.month = @months

  end

  def new_line
    @divide_level_wage = DivideLevelWage.new
  end

  def create_line
    if params[:name].present?
      @name = params[:name]
      @params_hash = params.delete_if{|key,value| ["utf8","authenticity_token","commit","controller","action","name"].include?(key) || (value =="")}
      @divide_level_wage = DivideLevelWage.new(:name => @name, :formula => @params_hash)
      if @divide_level_wage.save
        flash[:notice] = "项目新增成功！"
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
    @dividelevelwage = DivideLevelWage.find(params[:id])
    @name = params[:name]
    @params_hash = params.delete_if{|key,value| ["utf8","authenticity_token","commit","controller","action","name","id","_method"].include?(key) || (value =="")}
    if @name.present? && @params_hash.present?
       if @dividelevelwage.update(:name => @name, :formula => @params_hash)
        redirect_to divide_level_wages_path
        flash[:notice] = "项目名及筛选条件更新成功！"
      else
        flash[:warning] = "项目名称不能重复！"
        render "divide_level_wages/new_line"
      end
    elsif @name.present? && @params_hash.blank?
      if @dividelevelwage.update(:name => @name)

        redirect_to divide_level_wages_path
        flash[:notice] = "项目名更新成功！"
      else
        flash[:warning] = "项目名称不能重复！"
        render "divide_level_wages/new_line"
      end
    elsif @name.blank? && @params_hash.present?
      @dividelevelwage.update(:formula => @params_hash)
      redirect_to divide_level_wages_path
      flash[:notice] = "筛选条件更新成功！"
    elsif @name.blank? && @params_hash.blank?
      redirect_to divide_level_wages_path
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

  def edit_head
   @divide_head = DivideLevelWageHead.find(params[:id])

  end

  def update_head
    @divide_level_wage_head = DivideLevelWageHead.find(params[:id])
    @name = params[:head_name]
    @params_hash = params.delete_if{|key,value| ["utf8","authenticity_token","commit","controller","action","head_name","divide_head_name","id"].include?(key) || (value =="")}
    if @name.present? && @params_hash.present?
      @divide_level_wage_head.update(:head_name => @name ,:formula => @params_hash)
      redirect_to divide_level_wages_path
      flash[:notice] = "成功更新表头及公式！"
    elsif @name.present? && @params_hash.blank?
      @divide_level_wage_head.update(:head_name => @name )
      redirect_to divide_level_wages_path
      flash[:notice] = "成功更新表头！"
    elsif @name.blank? && @params_hash.present?
      @divide_level_wage_head.update(:formula => @params_hash)
      redirect_to divide_level_wages_path
      flash[:notice] = "成功更新公式！"
    else
      redirect_to divide_level_wages_path
    end
  end

  def delete_head
    @divide_level_wage_head = DivideLevelWageHead.find(params[:id])
    @divide_level_wage_heads = DivideLevelWageHead.all
    name = @divide_level_wage_head.head_name
    divide_head_id = (@divide_level_wage_head.divide_head_name.split("l")[1]).to_i
    head_count = DivideLevelWageHead.count - 1
    @divide_level_wage_head.delete

    (divide_head_id..head_count).each do |divide_head|

        @divide_level_wage_heads[divide_head-1].update(:divide_head_name => ("col" + divide_head.to_s))
    end

    flash[:notice] = "已删除'#{name}'!"
    redirect_to divide_level_wages_path
  end


  # private
  #
  # def divide_level_wage_params
  #   params.require(:divide_level_wage).permit(:formula ,:name)
  # end
end
