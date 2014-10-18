module Paperclip
  class Preview < Processor

    def initialize(file, options = {}, attachment = nil)
      super
      @file = file
      @instance = options[:instance]
      @current_format   = File.extname(@file.path)
      @basename         = File.basename(@file.path, @current_format)
    end

    def make
      dst = Tempfile.new([@basename, 'png'].compact.join("."))
      dst.binmode
      image= MiniMagick::Image.open(File.expand_path(@file.path))
      image.format('png')
      image.write(File.expand_path(dst.path))
      dst.flush
      return dst
    end
  end
end