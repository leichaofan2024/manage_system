class FinalStatisticsController < ApplicationController
	layout 'home'
	def index 
	  @five_star_range = StarRange.find_by(:name => 5)
      @four_star_range = StarRange.find_by(:name => 4)
      @three_star_range = StarRange.find_by(:name => 3)
      @two_star_range = StarRange.find_by(:name => 2)
      @one_star_range = StarRange.find_by(:name => 1)
      if @five_star_range.present? and @four_star_range.present? and @three_star_range.present? and @two_star_range.present? and @one_star_range.present?
      	@star_range_all_present = 1
      else 
      	@star_range_all_present = 0
      end 
	  @years = BasicScore.pluck(:year).uniq.sort{|a,b| b<=>a}
	  @quarters = BasicScore.pluck(:quarter).uniq.sort{|a,b| b<=> a}
	  quarter_hash = {1=>1,2=>1,3=>1,4=>2,5=>2,6=>2,7=>3,8=>3,9=>3,10=>4,11=>4,12=>4}
	  if params[:year].present? 
	  	@year = params[:year].to_i 
	  else 
	  	@year = Time.now.year 
	  end 
	  if params[:quarter].present? 
	    @quarter = params[:quarter].to_i 
	  else 
        quarters = BasicScore.where(:year => Time.now.year).pluck(:quarter).uniq.sort{|a,b| b<=> a}
        if quarters.present? 
        	@quarter = quarters[0]
        else 
            @quarter = quarter_hash[Time.now.month]
        end 
	  end 

	  @workshops = StarInfo.where(:year => @year,:quarter => @quarter).pluck(:workshop).uniq
	  respond_to do |format| 
	  	format.html
	  	format.xls { headers["Content-Disposition"] = 'attachment; filename="星级岗考核汇总表.xls"'}
	  end 
	end 
end
