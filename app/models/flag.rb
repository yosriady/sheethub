class Flag < ActiveRecord::Base
  belongs_to :sheet
  belongs_to :user

end
