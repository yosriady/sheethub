module Upgradable
  extend ActiveSupport::Concern

  included do
    BASIC_FREE_SHEET_QUOTA = 15
    PLUS_FREE_SHEET_QUOTA = 75
    PRO_FREE_SHEET_QUOTA = 125
    INVALID_MEMBERSHIP_TYPE_MESSAGE = 'Membership type does not exist'
    MISSING_SUBSCRIPTION_OBJECT_MESSAGE = 'Error: Subscription object missing. Contact support.'

    enum membership_type: %w( basic plus pro staff )
    has_one :subscription
  end

  class_methods do
    def free_sheet_quota_of(membership_type)
      m = membership_type.to_s.downcase
      raise INVALID_MEMBERSHIP_TYPE_MESSAGE unless m.in? User.membership_types.keys
      return BASIC_FREE_SHEET_QUOTA if m == 'basic'
      return PLUS_FREE_SHEET_QUOTA if m == 'plus'
      return PRO_FREE_SHEET_QUOTA if m == 'pro'
    end
  end

  def update_membership_to(membership_type)
    m = membership_type.to_s.downcase
    raise INVALID_MEMBERSHIP_TYPE_MESSAGE unless m.in? User.membership_types.keys
    update(membership_type: m, sheet_quota: User.free_sheet_quota_of(m))
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

  def remaining_sheet_quota
    sheet_quota - free_sheets.size
  end

  def hit_sheet_quota?
    free_sheets.size >= sheet_quota
  end

  def hit_sheet_quota_for_basic?
    free_sheets.size >= BASIC_FREE_SHEET_QUOTA
  end

end