class AddPayWhatYouWantBooleanToSheets < ActiveRecord::Migration
  def change
    add_column :sheets, :pay_what_you_want, :boolean, default: false
  end
end
