module DataHygiene
    # Used to identify the appropriate redirect URL for a whitehall policy.
    #
    # Note: Can be removed after the migration to new policies has been complete.
  class OldPolicyRedirectIdentifier
    # These policies are not being made into new policies so there is no
    # corresponding future-policy. Instead, they should be redirected to the
    # corresponding policy publication, as defined by the follow ID mapping:
    RETIRED_POLICY_MAPPINGS = {
      228679 => 489746, # Helping employers make safer recruiting decisions
      484893 => 489849, # Making it easier for HMRC customers to deal with their taxes
      484897 => 489851, # Making the administration of the tax system more efficient
    }

    def initialize(policy)
      @policy = policy
    end

    def redirect_url
      if corresponding_future_policy.present?
        corresponding_future_policy_url
      else
        corresponding_policy_publication_url
      end
    end

  private
    attr_reader :policy

    def corresponding_future_policy
      Future::Policy.find(policy.content_id)
    end

    def corresponding_future_policy_url
      Whitehall.public_root + corresponding_future_policy.base_path
    end

    def corresponding_policy_publication_url
      Whitehall.url_maker.document_url(corresponding_policy_publication)
    end

    def corresponding_policy_publication
      Publication.find(RETIRED_POLICY_MAPPINGS[policy.id])
    end
  end
end