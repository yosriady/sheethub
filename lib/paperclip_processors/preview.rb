module Paperclip
  # Handles generating preview images of Sheet pdFs
  class Preview < Processor

    def initialize(file, options = {}, attachment = nil)
      super
      @file = file
      @instance = options[:instance]
      @current_format   = File.extname(@file.path)
      @basename         = File.basename(@file.path, @current_format)
    end

    def make
      dst = Tempfile.new([@basename, 'jpg'].compact.join("."))
      dst.binmode
      pdf = ::Magick::ImageList.new(File.expand_path(@file.path))
      image = pdf[0].append(false)
      image.format = 'JPG'
      image.write(File.expand_path(dst.path))
      dst.flush
      return dst
    end

  end
end