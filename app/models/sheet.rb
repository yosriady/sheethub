class Sheet < ActiveRecord::Base

  # Difficulty integer: 0=> beginner, 1=> intermediate, 2=>advanced
  DIFFICULTY = %w{ beginner intermediate advanced }
  DIFFICULTY.each_with_index do |meth, index|
    define_method("#{meth}?") { difficulty == index }
  end

  bitmask :instruments, :as => [:guitar, :piano, :bass, :mandolin, :banjo, :ukulele, :violin, :flute, :harmonica, :trombone, :trumpet, :clarinet, :saxophone, :others]
end