class RectificationAwardsController < ApplicationController
  layout 'home'


  def index
    @rectifications = RectificationAward.all
  end
end
