class HighSpeedRailStuffsController < ApplicationController

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
    @high_speed_stuff = HighSpeedRailStuff.new
  end

  def create_line
    if params[:name].present?
      @name = params[:name]
      @params_hash = params.delete_if{|key,value| ["utf8","authenticity_token","commit","controller","action","name"].include?(key) || (value =="")}
      @high_speed_stuff = HighSpeedRailStuff.new(:name => @name, :formula => @params_hash)
      if @high_speed_stuff.save
        flash[:notice] = "项目新增成功！"
        redirect_to high_speed_rail_stuffs_path
      else
        flash[:warning] = "项目名称不能重复！"
        render "high_speed_rail_stuffs/new_line"
      end
    else
      flash[:warning] = "项目名称不能为空!"
      render "high_speed_rail_stuffs/new_line"
    end
  end

  def edit_line
    @high_speed_stuff = HighSpeedRailStuff.find(params[:id])
  end

  def update_line
    @high_speed_stuff = HighSpeedRailStuff.find(params[:id])
    @name = params[:name]
    @params_hash = params.delete_if{|key,value| ["utf8","authenticity_token","commit","controller","action","name","id","_method"].include?(key) || (value =="")}
    if @name.present? && @params_hash.present?
       if @high_speed_stuff.update(:name => @name, :formula => @params_hash)
        redirect_to high_speed_rail_stuffs_path
        flash[:notice] = "项目名及筛选条件更新成功！"
      else
        flash[:warning] = "项目名称不能重复！"
        render "high_speed_rail_stuffs/new_line"
      end
    elsif @name.present? && @params_hash.blank?
      if @high_speed_stuff.update(:name => @name)

        redirect_to high_speed_rail_stuffs_path
        flash[:notice] = "项目名更新成功！"
      else
        flash[:warning] = "项目名称不能重复！"
        render "high_speed_rail_stuffs/new_line"
      end
    elsif @name.blank? && @params_hash.present?
      @high_speed_stuff.update(:formula => @params_hash)
      redirect_to high_speed_rail_stuffs_path
      flash[:notice] = "筛选条件更新成功！"
    elsif @name.blank? && @params_hash.blank?
      redirect_to high_speed_rail_stuffs_path
    end
  end

  def delete_line
    @high_speed_stuff = HighSpeedRailStuff.find(params[:id])
    name  =  @high_speed_stuff.name
    @high_speed_stuff.delete
    flash[:notice] = "已删除'#{name}'!"
    redirect_to high_speed_rail_stuffs_path
  end

  def new_head
   @high_speed_stuff = "col"+(HighSpeedRailStuffHead.count+1).to_s
  end

  def create_head
    if params[:head_name].present?
      high_head_name= params[:high_head_name]
      @name = params[:head_name]
      @params_hash = params.delete_if{|key,value| ["utf8","authenticity_token","commit","controller","action","head_name","high_head_name","_method"].include?(key) || (value =="")}
      @high_speed_stuff_head = HighSpeedRailStuffHead.new(:head_name => @name, :high_head_name => high_head_name,:formula => @params_hash)
      if @high_speed_stuff_head.save
        redirect_to high_speed_rail_stuffs_path
      else
        flash[:warning] = "项目名称不能重复！"
        render "high_speed_rail_stuffs/new_head"
      end
    else
      flash[:warning] = "项目名称不能为空!"
      render "high_speed_rail_stuffs/new_head"
    end
  end

  def edit_head
   @high_speed_stuff_head = HighSpeedRailStuffHead.find(params[:id])
  end

  def update_head
    @high_speed_stuff_head = HighSpeedRailStuffHead.find(params[:id])
    @name = params[:head_name]
    @params_hash = params.delete_if{|key,value| ["utf8","authenticity_token","commit","controller","action","head_name","high_head_name","id","_method"].include?(key) || (value =="")}
    if @name.present? && @params_hash.present?
      @high_speed_stuff_head.update(:head_name => @name ,:formula => @params_hash)
      redirect_to high_speed_rail_stuffs_path
      flash[:notice] = "成功更新表头及公式！"
    elsif @name.present? && @params_hash.blank?
      @high_speed_stuff_head.update(:head_name => @name )
      redirect_to high_speed_rail_stuffs_path
      flash[:notice] = "成功更新表头！"
    elsif @name.blank? && @params_hash.present?
      @high_speed_stuff_head.update(:formula => @params_hash)
      redirect_to high_speed_rail_stuffs_path
      flash[:notice] = "成功更新公式！"
    else
      redirect_to high_speed_rail_stuffs_path
    end
  end

  def delete_head
    @high_speed_stuff_head = HighSpeedRailStuffHead.find(params[:id])
    @high_speed_stuff_heads = HighSpeedRailStuffHead.all
    name = @high_speed_stuff_head.head_name
    high_head_id = (@high_speed_stuff_head.high_head_name.split("l")[1]).to_i
    head_count = HighSpeedRailStuffHead.count - 1
    @high_speed_stuff_head.delete

    (high_head_id..head_count).each do |high_head|

        @high_speed_stuff_heads[high_head-1].update(:high_head_name => ("col" + production_head.to_s))
    end

    flash[:notice] = "已删除'#{name}'!"
    redirect_to high_speed_rail_stuffs_path
  end
end
