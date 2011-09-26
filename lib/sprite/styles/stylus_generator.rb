module Sprite
  module Styles
    # renders a yml file that is later used by stylus when generating mixins
    class StylusGenerator
      def initialize(builder)
        @builder = builder
      end

      def write(path, sprite_files)
        # write the stylus mixins to disk
        File.open(File.join(Sprite.root, path), 'w') do |f|
          add_else = false

          f.puts "sprite(group_name, image_name, offset = 0)"
          sprite_files.each do |sprite_file, sprites|
            background_url = @builder.background_url(sprite_file)
            sprites.each do |sprite|
              f << "  "
              if add_else
                f << "else "
              end
              add_else = true
              if sprite[:align] == 'horizontal'
                background_offset = "#{sprite[:x]}px+offset #{sprite[:y]}px"
              else
                background_offset = "#{sprite[:x]}px #{sprite[:y]}px+offset"
              end

              f.puts %{if group_name == "#{sprite[:group]}" and image_name == "#{sprite[:name]}"}
              f.puts "    background: #{background_url} no-repeat #{background_offset}"
              f.puts "    width: #{sprite[:width]}px"
              f.puts "    height: #{sprite[:height]}px"
            end
          end
        end
      end

      def extension
        "styl"
      end

    end
  end
end