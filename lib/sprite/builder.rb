require 'fileutils'
module Sprite
  class Builder
    attr_reader :config
    attr_reader :images

    def self.from_config(path = nil)
      results = Config.read_config(path)
      new(results["config"], results["images"])
    end

    def initialize(config = nil, images = nil)
      @config = config || {}
      set_config_defaults

      @images = images || []
      if @images.empty?
        @images = default_images
      end
      expand_image_paths

      # initialize datestamp
      @datestamp_query = "?#{Time.now.to_i}" if @config["add_datestamps"]

      # initialize sprite files
      @sprite_files = {}
    end

    def build
      @sprite_files = {}

      if images.size > 0
        # create images
        images.each do |image|
          write_image(image)
        end

        if @sprite_files.values.length > 0
          # write css
          write_styles
        end
      end
    end

    # get the disk path for the style output file
    def style_output_path(relative = false)
      style = Styles.get(config["style"]).new(self)

      path = config['style_output_path']
      unless path.include?(".#{style.extension}")
        path = "#{path}.#{style.extension}"
      end
      Config.new(config).public_path(path, relative)
    end

    def image_path(group)
      image_info = images.detect{|image| image['name'] == group}
      image_config = ImageConfig.new(image_info, config)

      cache_buster = "-#{config['cache_buster']}" if config['cache_buster']
      sprite_file = "#{image_config.name}#{cache_buster}.#{image_config.format}"
      "#{config['css_image_path']}#{sprite_file}"
    end

    def background_url(name)
      if @config["url_formatter"]
        sprintf(@config["url_formatter"], name)
      else
        "url('#{@config['external_base']}#{@config['image_output_path']}#{name}')"
      end
    end

  protected

    def write_image(image)
      results = []
      image_config = ImageConfig.new(image, config)
      sources = image_config.sources.to_a.sort
      return unless sources.length > 0

      name = image_config.name
      resizer = ImageResizer.new(image_config.resize_to)
      combiner = ImageCombiner.new(image_config)

      # Let's get the sprite started with the first image
      first_image = ImageReader.read(sources.shift)
      resizer.resize(first_image)

      dest_image = first_image
      results << combiner.image_properties(dest_image).merge(:x => 0, :y => 0, :group => name)

      # Now let's add the rest of the images in turn
      sources.each do |source|
        source_image = ImageReader.read(source)
        resizer.resize(source_image)
        if image_config.horizontal_layout?
          x = dest_image.columns + image_config.spaced_by
          y = 0
          align = "horizontal"
        else
          x = 0
          y = dest_image.rows + image_config.spaced_by
          align = "vertical"
        end
        results << combiner.image_properties(source_image).merge(:x => -x, :y => -y, :group => name, :align => align)
        dest_image = combiner.composite_images(dest_image, source_image, x, y)
      end

      ImageWriter.new(config).write(dest_image, name, image_config.format, image_config.quality, image_config.background_color)

      @sprite_files["#{name}.#{image_config.format}#{@datestamp_query}"] = results
    end

    def write_styles
      # use the absolute style output path to make sure we have the directory set up
      path = style_output_path
      FileUtils.mkdir_p(File.dirname(path))

      # send the style the relative path
      style.write(style_output_path(true), @sprite_files)
    end

    def style
      @style ||= Styles.get(config["style"]).new(self)
    end

    # sets all the default values on the config
    def set_config_defaults
      @config['style']              ||= 'css'
      @config['style_output_path']  ||= 'stylesheets/sprites'
      @config['image_output_path']  ||= 'images/sprites/'
      @config['css_image_path']     ||= "/#{@config['image_output_path']}"
      @config['image_source_path']  ||= 'images/'
      @config['public_path']        ||= 'public/'
      @config['external_base']      ||= '/'
      @config['default_format']     ||= 'png'
      @config['class_separator']    ||= '-'
      @config["sprites_class"]      ||= 'sprites'
      @config["default_spacing"]    ||= 0

      unless @config.has_key?("add_datestamps")
        @config["add_datestamps"] = true
      end
    end

    # if no image configs are detected, set some intelligent defaults
    def default_images
      sprites_path = File.expand_path(image_source_path("sprites"))
      collection = []

      if File.exists?(sprites_path)
        Dir.glob(File.join(sprites_path, "*")) do |dir|
          next unless File.directory?(dir)
          source_name = File.basename(dir)

          # default to finding all png, gif, jpg, and jpegs within the directory
          collection << {
            "name" => source_name,
            "sources" => [
              File.join("sprites", source_name, "*.png"),
              File.join("sprites", source_name, "*.gif"),
              File.join("sprites", source_name, "*.jpg"),
              File.join("sprites", source_name, "*.jpeg"),
            ]
          }
        end
      end

      collection
    end

    # expands out sources, taking the Glob paths and turning them into separate entries in the array
    def expand_image_paths
      # cycle through image sources and expand out globs
      @images.each do |image|
        # expand out all the globs
        image['sources'] = image['sources'].to_a.map{ |source|
          Dir.glob(File.expand_path(image_source_path(source)))
        }.flatten.compact
      end
    end

    # get the disk path for an image source file
    def image_source_path(location, relative = false)
      path_parts = []
      path_parts << Config.chop_trailing_slash(config["image_source_path"]) if Config.path_present?(config['image_source_path'])
      path_parts << location
      Config.new(config).public_path(File.join(*path_parts), relative)
    end

    def style_template_source_path(image, relative = false)
      location = image["style_output_template"]
      path_parts = []
      path_parts << location
      Config.new(config).public_path(File.join(*path_parts), relative)
    end
  end
end
