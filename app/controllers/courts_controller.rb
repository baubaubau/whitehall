class CourtsController < ApplicationController
  def index
    @courts = Organisation.courts
  end

  def show
    @court = Organisation.courts.find_by! slug: params[:id]

    judge_roles = @court.judge_roles.
                with_translations.
                includes(:current_people).
                order("organisation_roles.ordering")
    @judges = RolesPresenter.new(judge_roles, view_context)
    @judges.remove_unfilled_roles!
  end
end
