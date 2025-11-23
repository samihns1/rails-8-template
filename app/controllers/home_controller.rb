class HomeController < ApplicationController
  def index
    render({ :template => "home_templates/index" })
  end
end
