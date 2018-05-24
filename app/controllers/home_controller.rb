class HomeController < ApplicationController
  layout 'home'
  def index
    flash[:notice] = "well"
  end
end
