class CourtsController < ApplicationController
  def index
    @courts = Organisation.courts
  end

  def show
    @court = Organisation.courts.find_by! slug: params[:id]
  end
end
