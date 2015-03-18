class PayWhatYouWantByDefault < ActiveRecord::Migration
  def change
    change_column :sheets, :pay_what_you_want,  :boolean, default: true
  end
end
