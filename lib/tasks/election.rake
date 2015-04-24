namespace :election do
  desc "Republishes all case studies to the Publishing API"
  task :republish_case_studies => :environment do
    require 'data_hygiene/publishing_api_republisher'

    DataHygiene::PublishingApiRepublisher.new(CaseStudy.published).perform
  end

  desc "Creates the associations between all editions and new/future policies, based on their existing policy relations"
  task :migrate_old_policy_taggings_to_new => :environment do
    require 'data_hygiene/future_policy_tagging_migrator'

    edition_scope = Edition.
                      where(type: policy_taggable_edition_classes).
                      where(state: editable_edition_states).
                      includes(related_policies: :related_documents)

    DataHygiene::FuturePolicyTaggingMigrator.new(edition_scope, Logger.new(STDOUT)).migrate!
  end

  desc "Unpublish and redirect all published policies"
  task :unpublish_policies => :environment do
    Policy.published.with_translations.includes(:document).find_each do |policy|
      redirector_url = DataHygiene::OldPolicyRedirectIdentifier.new(policy).redirect_url
      redirector     = DataHygiene::OldPolicyRedirector.new(policy, redirector_url)

      if redirector.redirect!
        puts "Policy (#{policy.id}) \"#{policy.title}\" redirected to #{redirector_url}"
      else
        puts "Error for Policy (#{policy.id}) - #{redirector.error}"
      end
    end
  end

private

  def editable_edition_states
    Edition.state_machine.states.map(&:name) - [:superseded, :deleted, :archived]
  end

  def policy_taggable_edition_classes
    Whitehall.edition_classes.select { |klass| klass.ancestors.include?(Edition::RelatedPolicies) }
  end
end
