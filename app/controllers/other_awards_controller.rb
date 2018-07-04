class OtherAwardsController < ApplicationController
  layout 'home'

  def index
    @other_awards = OtherAward.all
  end
end
