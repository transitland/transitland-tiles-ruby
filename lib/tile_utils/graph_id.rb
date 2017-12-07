module TileUtils
  class GraphID
    SIZES = [4.0, 1.0, 0.25]
    LEVEL_BITS = 3
    TILE_INDEX_BITS = 22
    ID_INDEX_BITS = 21
    LEVEL_MASK = (2**LEVEL_BITS) - 1
    TILE_INDEX_MASK = (2**TILE_INDEX_BITS) - 1
    ID_INDEX_MASK = (2**ID_INDEX_BITS) - 1
    INVALID_ID = (ID_INDEX_MASK << (TILE_INDEX_BITS + LEVEL_BITS)) | (TILE_INDEX_MASK << LEVEL_BITS) | LEVEL_MASK

    attr_accessor :value
    def initialize(value: nil, **kwargs)
      @value = value || (self.class.make_id(**kwargs))
    end

    def self.make_id(level: 0, tile: 0, index: 0, lat: nil, lon: nil)
      if lat && lon
        tile = lll_to_tile(level, lat, lon)
      end
      level | tile << LEVEL_BITS | index << (LEVEL_BITS + TILE_INDEX_BITS)
    end

    def self.lll_to_tile(tile_level, lat, lon)
      size = SIZES[tile_level]
      width = int(360 / size)
      int((lat + 90) / size) * width + int((lon + 180 ) / size)
    end

    def self.level_tile_to_bbox(level, tile)
      size = SIZES[level]
      width = int(360 / size)
      height = int(180 / size)
      ymin = int(tile / width) * size - 90
      xmin = (tile % width) * size - 180
      xmax = xmin + size
      ymax = ymin + size
      [xmin, ymin, xmax, ymax]
    end

    def self.bbox_to_level_tiles(ymin, xmin, ymax, xmax)
      # if this is crossing the anti meridian split it up and combine
      left, bottom, right, top = ymin, xmin, ymax, xmax
      if left > right
        east = tiles_for_bbox(left, bottom, 180.0, top)
        west = tiles_for_bbox(-180.0, bottom, right, top)
        return east + west
      end
      #move these so we can compute percentages
      left += 180
      right += 180
      bottom += 90
      top += 90
      tiles = []
      SIZES.each_index do |level|
        size = SIZES[level]
        (int(left/size)..(int(right/size))).each do |x|
          (int(bottom/size)..(int(top/size))).each do |y|
            tile = int(y * (360.0 / size) + x)
            tiles << [level, tile]
          end
        end
      end
      tiles
    end

    def bbox
      self.class.level_tile_to_bbox(level, tile)
    end

    def level
      @value & LEVEL_MASK
    end

    def tile
      (@value >> LEVEL_BITS )& TILE_INDEX_MASK
    end

    def index
      (@value >> LEVEL_BITS + TILE_INDEX_BITS) & ID_INDEX_MASK
    end

    def self.int(value)
      # Simplify porting
      value.to_i
    end
  end
end
