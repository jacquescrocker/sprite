module Sprite
  class ImageWriter
    def initialize(config)
      @config = config
    end

    def write(image, name, format, quality = nil, background_color = nil)
      # set up path
      path = image_output_path(name, format)
      FileUtils.mkdir_p(File.dirname(path))

      # write sprite image file to disk
      image.write(path) {
        self.quality = quality unless quality.nil?
        self.background_color = background_color unless background_color.nil?
      }
    end

    # get the disk path for a location within the image output folder
    def image_output_path(name, format, relative = false)
      path_parts = []
      path_parts << Config.chop_trailing_slash(@config['image_output_path']) if Config.path_present?(@config['image_output_path'])

      cache_buster = "-#{@config['cache_buster']}" if @config['cache_buster']
      path_parts << "#{name}#{cache_buster}.#{format}"
      Config.new(@config).public_path(File.join(*path_parts), relative)
    end
  end
end
