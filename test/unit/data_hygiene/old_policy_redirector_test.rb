require 'test_helper'

module DataHygiene
  class OldPolicyRedirectorTest < ActiveSupport::TestCase
    include ContentRegisterHelpers

    setup do
      stub_content_register_policies
    end

    test "unpublishes and redirects a policy to the redirect URL" do
      policy       = create(:published_policy)
      redirect_url = "#{Whitehall.public_root}#{policy_1["base_path"]}"
      redirector   = OldPolicyRedirector.new(policy, redirect_url)

      assert redirector.redirect!
      assert policy.reload.draft?
      assert unpublishing = policy.unpublishing
      assert_equal UnpublishingReason::Consolidated, unpublishing.unpublishing_reason
      assert_equal redirect_url, unpublishing.alternative_url
    end

    test "it returns false and reports an error if the unpublish action fails" do
      policy     = create(:published_policy)
      draft      = policy.create_draft(create(:gds_editor))
      redirector = OldPolicyRedirector.new(policy, Whitehall.url_maker.policies_url)

      refute redirector.redirect!
      assert_match "There is already a draft edition", redirector.error
    end
  end
end
