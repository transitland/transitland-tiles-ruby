module TileUtils
  class TileSet
    def initialize(path)
      @path = path
    end

    def get_tile_by_lll(level, lat, lon)
      get_tile_by_graphid(GraphID.new(level: level, lat: lat, lon: lon))
    end

    def get_tile_by_graphid(graphid)
      read_tile(graphid.level, graphid.tile)
    end

    def write_tile(tile, ext: nil)
      fn = tile_path(tile.level, tile.tile, ext: ext)
      FileUtils.mkdir_p(File.dirname(fn))
      puts "writing tile: #{fn}"
      File.open(fn, 'wb') do |f|
        f.write(tile.encode)
      end
    end

    def new_tile(level, tile)
      Tile.new(level, tile)
    end

    def read_tile(level, tile)
      fn = tile_path(level, tile)
      if File.exists?(fn)
        Tile.new(level, tile, data: File.read(fn))
      else
        Tile.new(level, tile)
      end
    end

    def find_all_tiles
      all_tiles = []
      Find.find(@path) do |path|
        # Just use string methods
        next unless path.ends_with?('.pbf')
        path = path[0...-4].split("/")
        if path[-4].eql?('2')
          level = 2
          tile = path.last(3).join('').to_i
        else
          level = path[-3].to_i
          tile = path.last(2).join('').to_i
        end
        all_tiles << [level, tile]
      end
      all_tiles
    end

    private

    def tile_path(level, tile, ext: nil)
      # TODO: support multiple levels
      ext = ext.nil? ? '.pbf' : ".pbf.#{ext}"
      s = tile.to_s.rjust(9, "0")
      File.join(@path, level.to_s, s[0...3], s[3...6], s[6...9]+ext)
    end
  end
end
