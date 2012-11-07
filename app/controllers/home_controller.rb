class HomeController < ApplicationController
  def front_page
    render :file => 'home/front_page', :layout => 'layouts/front_page'
  end
end
