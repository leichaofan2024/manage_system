class MiddleAwardsController < ApplicationController
  layout 'home'

  def index
    @middle_awards = MiddleAward.all
  end
end
