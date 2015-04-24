module DataHygiene
  # Used during the election period of 2015 to unpublish old whitehall policies
  # and redirect them to the new policies being managed by policy-publisher.
  #
  # Note: Can be removed after the migration to new policies has been complete.
  class OldPolicyRedirector
    attr_reader :error

    def initialize(policy, redirect_url)
      @policy = policy
      @redirect_url = redirect_url
    end

    # Returns true if the redirect is successful, false if it fails.
    # When it fails, the +error+ method will return a string describing why.
    def redirect!
      perform_unpublishing!
    end

  private
    attr_reader :policy, :redirect_url

    def perform_unpublishing!
      if edition_unpublisher.perform!
        true
      else
        @error = edition_unpublisher.failure_reason
        false
      end
    end

    def options
      {
        unpublishing: {
          unpublishing_reason_id: UnpublishingReason::Consolidated.id,
          alternative_url: redirect_url
        }
      }
    end

    def edition_unpublisher
      @edition_unpublisher ||= EditionUnpublisher.new(policy, options)
    end
  end
end
