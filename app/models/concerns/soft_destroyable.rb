module SoftDestroyable
  # requires Taggable module to be included
  extend ActiveSupport::Concern

  included do
    acts_as_paranoid
  end

  # Override Soft Destroy
  def destroy
    clear_tags
    super
    SheetMailer.sheet_deleted_email(self).deliver
  end

  # Override Hard Destroy
  def really_destroy!
    super
    SheetMailer.sheet_really_deleted_email(self).deliver
  end

  def restore
    restore_tags
    Sheet.restore(self, recursive: true)
  end

end