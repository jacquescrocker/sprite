module Sprite
  module Styles
    # renders a yml file that is later parsed by a sass extension when generating the mixins
    class SassMixinGenerator
      def initialize(builder)
        @builder = builder
      end

      def write(path, sprite_files)
        # write the sass mixins to disk
        File.open(File.join(Sprite.root, path), 'w') do |f|

          f.puts "= sprite($group-name, $image-name, $offset: 0)"
          sprite_files.each do |sprite_file, sprites|
            background_url = @builder.background_url(sprite_file)
            sprites.each do |sprite|
              f << "  @"
              #{sprite[:x]}px #{sprite[:y]}px

              if sprite[:align] == 'horizontal'
                background_offset = "\#{#{sprite[:x]}+$offset}px #{sprite[:y]}px"
              else
                background_offset = "#{sprite[:x]}px \#{#{sprite[:y]}+$offset}px"
              end

              f.puts %{if $group-name == "#{sprite[:group]}" and $image-name == "#{sprite[:name]}"}
              f.puts "    background: #{background_url} no-repeat #{background_offset}"
              f.puts "    +sprite-dimensions($group-name, $image-name)"
            end
          end

          f.puts "\n= sprite-dimensions($group-name, $image-name)"
          sprite_files.each do |sprite_file, sprites|
            background_url = @builder.background_url(sprite_file)
            sprites.each do |sprite|
              f << "  @"
              f.puts %{if $group-name == "#{sprite[:group]}" and $image-name == "#{sprite[:name]}"}
              f.puts "    width: #{sprite[:width]}px"
              f.puts "    height: #{sprite[:height]}px"
            end
          end
        end
      end

      def extension
        "sass"
      end

    end
  end
end
