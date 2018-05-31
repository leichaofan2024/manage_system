class HomeController < ApplicationController
  layout 'home'
  def index
    flash[:alert] = "hello, boy"
  end
end
