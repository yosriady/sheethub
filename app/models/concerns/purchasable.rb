module Purchasable
    extend ActiveSupport::Concern

    def owned_by?(user)
      return false unless user
      user.purchased?(id)
    end

    def completed_orders
      Order.where(sheet_id: id, status: Order.statuses[:completed])
    end

    def total_sales
      completed_orders.inject(0) { |total, order| total + order.amount }
    end

    def total_earnings
      completed_orders.inject(0) { |total, order| total + order.royalty }
    end

    def average_sales
      completed_orders.average(:amount_cents).to_f / 100
    end

    def maximum_sale
      completed_orders.maximum(:amount_cents).to_f / 100
    end

    def royalty
      (user.royalty_percentage * price).round(2)
    end

    def royalty_cents
      (user.royalty_percentage * price_cents).round(0)
    end

    def commission
      ((1 - user.royalty_percentage) * price).round(2)
    end

    def commission_cents
      ((1 - user.royalty_percentage) * price_cents).round(0)
    end
end