module Payable
  extend ActiveSupport::Concern

  included do
    BASIC_ROYALTY_PERCENTAGE = 0.85
    PLUS_ROYALTY_PERCENTAGE = 0.85
    PRO_ROYALTY_PERCENTAGE = 0.90

    validates_email_format_of :paypal_email, message: 'You have an invalid paypal account email address', if: :paypal_email?
  end

  def royalty_percentage
    return BASIC_ROYALTY_PERCENTAGE if basic?
    return PLUS_ROYALTY_PERCENTAGE if plus?
    return PRO_ROYALTY_PERCENTAGE if pro?
  end

  def contributors
    User.find(sales.pluck(:user_id))
  end

  def max_contribution_to(author)
    Order.where(user_id: self.id, sheet_id: author.sheets.ids, status: Order.statuses[:completed]).maximum(:amount_cents)
  end

  def sales
    Order.includes(:user).includes(:sheet).where(sheet_id: sheets.ids, status: Order.statuses[:completed])
  end

  def csv_sales_data
    require 'csv'
    headers = [:date, :title, :price, :amount, :earnings, :email,
     :ip_address, :billing_full_name, :billing_address_line_1,
     :billing_address_line_2, :billing_city,
     :billing_state_province, :billing_country, :billing_zipcode]
    CSV.generate do |csv|
      csv << headers
      sales.each { |sale| csv << sale.csv_data }
    end
  end

  def all_time_sales
    result = {}
    sheets.find_each do |sheet|
      total_sales = sheet.total_sales
      result[sheet.title] = total_sales if total_sales > 0
    end
    result
  end

  def all_time_earnings
    sheets.inject(0) { |total, sheet| total + sheet.total_earnings }
  end

  def sales_past_month
    sales.where('purchased_at >= ?', 1.month.ago.utc)
  end

  def sales_past_month_by_country
    sales_past_month.group(:billing_country).count.map {|k, v| [ISO3166::Country[k].name, v] if ISO3166::Country[k] }
  end

  def earnings_past_month
    sales_past_month.inject(0) { |total, order| total + order.royalty }
  end
end