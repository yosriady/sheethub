module Paperclip
  class Watermark < Processor
    def initialize(file, options = {}, attachment = nil)
      super
      @file = file
      @watermark_path = options[:watermark_path]
      @current_format   = File.extname(@file.path)
      @basename         = File.basename(@file.path, @current_format)
    end

    def make
      pdf = MiniMagick::Image.open(File.expand_path(@file.path))
      watermark = MiniMagick::Image.open(File.expand_path(@watermark_path))
      composited = pdf.pages.inject([]) do |composited, page|
        composited << page.composite(watermark) do |c|
          c.compose "Over"
          c.gravity "SouthEast"
        end
      end
      MiniMagick::Tool::Convert.new do |b|
        composited.each { |page| b << page.path }
        b << pdf.path
      end
      return pdf
    end
  end
end