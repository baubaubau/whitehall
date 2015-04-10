class CourtsController < ApplicationController

  def index
    @courts = Organisation.courts
  end

end
