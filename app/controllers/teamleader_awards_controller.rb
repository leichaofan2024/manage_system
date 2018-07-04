class TeamleaderAwardsController < ApplicationController
  layout 'home'

  def index
    @teamleader_awards = TeamleaderAward.all
  end
end
