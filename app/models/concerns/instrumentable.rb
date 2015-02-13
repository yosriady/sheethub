module Instrumentable
  extend ActiveSupport::Concern

  included do
    validates :instruments, presence: true
    attr_accessor :instruments_list # For form parsing
    bitmask :instruments, as: [:others, :guitar, :piano, :bass, :mandolin, :banjo,
                               :ukulele, :violin, :flute, :harmonica, :trombone,
                               :trumpet, :clarinet, :saxophone, :viola, :oboe,
                               :cello, :bassoon, :organ, :harp, :accordion, :lute,
                               :tuba, :ocarina], null: false
  end

  class_methods do
    def instruments_to_bitmask(instruments)
      (instruments & Sheet.values_for_instruments).map { |r| 2**Sheet.values_for_instruments.index(r) }.inject(0, :+)
    end
  end

end