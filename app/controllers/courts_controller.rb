class CourtsController < PublicFacingController
  include CacheControlHelper

  enable_request_formats show: [:atom]
  before_filter :set_court_slimmer_headers, only: [:show]
  skip_before_filter :set_cache_control_headers, only: [:show]
  before_filter :set_cache_max_age, only: [:show]

  def index
    @courts = Organisation.courts.listable.ordered_by_name_ignoring_prefix
    @hmcts_tribunals = Organisation.hmcts_tribunals.listable.ordered_by_name_ignoring_prefix
  end

  def show
    @court = Organisation.courts.find_by! slug: params[:id]
    recently_updated_source = @court.published_non_corporate_information_pages.in_reverse_chronological_order
    set_expiry 5.minutes
    respond_to do |format|
      format.html do
        @announcements = latest_presenters(@court.published_announcements, translated: true, count: 2)
        @publications = latest_presenters(@court.published_non_statistics_publications, translated: true, count: 2)

        if @court.live?
          @recently_updated = recently_updated_source.with_translations(I18n.locale).limit(3)
          @feature_list = OrganisationFeatureListPresenter.new(@court, view_context)
          set_meta_description(@court.summary)

          expire_on_next_scheduled_publication(@court.scheduled_editions)

          @topics = @court.topics
          @mainstream_categories = @court.mainstream_categories
          @judges = judges
        else
          render action: 'not_live'
        end
      end
      format.atom do
        @documents = EditionCollectionPresenter.new(recently_updated_source.limit(10), view_context)
      end
    end
  end

  def judges
    @judge_roles ||= filled_roles_presenter_for(@court, :judge)
    @judge_roles.with_unique_people
  end

  def filled_roles_presenter_for(organisation, association)
    roles_presenter = roles_presenter_for(organisation, association)
    roles_presenter.remove_unfilled_roles!
    roles_presenter
  end

  def roles_presenter_for(organisation, association)
    roles = organisation.send("#{association}_roles").
                         with_translations.
                         includes(:current_people).
                         order("organisation_roles.ordering")
    RolesPresenter.new(roles, view_context)
  end

  def set_court_slimmer_headers
    set_slimmer_organisations_header([@court])
    set_slimmer_page_owner_header(@court)
  end

  def set_cache_max_age
    @cache_max_age = 5.minutes
  end
end
