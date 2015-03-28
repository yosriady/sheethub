module Upgradable
  extend ActiveSupport::Concern

  included do
    INVALID_MEMBERSHIP_TYPE_MESSAGE = 'Membership type does not exist'
    MISSING_SUBSCRIPTION_OBJECT_MESSAGE = 'Error: Subscription object missing. Contact support.'

    enum membership_type: %w( basic plus pro staff )
    has_one :subscription
  end

  def update_membership_to(membership_type)
    m = membership_type.to_s.downcase
    raise INVALID_MEMBERSHIP_TYPE_MESSAGE unless m.in? User.membership_types.keys
    update(membership_type: m)
  end

  def has_subscription_for_membership(membership_type)
    Subscription.find_by(user: self,
                         membership_type:Subscription.membership_types[membership_type],
                         status: Subscription.statuses[:completed]).present?
  end

  def premium_subscription
    Subscription.find_by(user: self, status: Subscription.statuses[:completed])
  end

  def completed_subscriptions
    Subscription.where(user: self, status: Subscription.statuses[:completed]).order(:updated_at)
  end

  def premium?
    plus? || pro?
  end

end