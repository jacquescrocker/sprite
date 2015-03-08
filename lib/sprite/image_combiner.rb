module Sprite
  class ImageCombiner
    def initialize(image_config)
      begin
        # avoid loading rmagick till the last possible moment
        require "RMagick"
      rescue LoadError
        require 'rmagick'
      end

      @image_config = image_config
    end

    def composite_images(dest_image, src_image, x, y)
      width = [src_image.columns + x, dest_image.columns].max
      height = [src_image.rows + y, dest_image.rows].max
      image = Magick::Image.new(width, height)
      if @image_config.background_color
        image.opacity = 0
      else
        image.opacity = Magick::QuantumRange
      end

      image.composite!(dest_image, 0, 0, Magick::OverCompositeOp)
      image.composite!(src_image, x, y, Magick::OverCompositeOp)
      image
    end

    # Image Utility Methods

    def image_properties(image)
      {:name => File.basename(image.filename).split('.')[0], :width => image.columns, :height => image.rows}
    end

    # REMOVE RMAGICK AND USE IMAGEMAGICK FROM THE COMMAND LINE
    # identify => find properties for an image
    # composite => combine 2 images

  end
end
