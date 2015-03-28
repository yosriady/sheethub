# Methods to find related objects (sheets and tags)
module Licensable
  extend ActiveSupport::Concern

  included do
    enum license: %w( all_rights_reserved creative_commons cc0 public_domain licensed_arrangement )
  end

  def verbose_license
    return 'All rights reserved' if all_rights_reserved?
    return 'Creative Commons' if creative_commons?
    return 'Creative Commons Zero' if cc0?
    return 'Public Domain' if public_domain?
    return 'Licensed' if licensed_arrangement?
  end

end
