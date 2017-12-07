module TileUtils
  class Tile
    attr_reader :level, :tile, :message
    def initialize(level, tile, data: nil)
      @level = level
      @tile = tile
      @index = {}
      @message = load(data)
    end

    def load(data)
      if data
        message = decode(data)
      else
        message = Valhalla::Mjolnir::Transit.new
      end
      message.nodes.each { |node| @index[GraphID.new(value: node.graphid).index] = node.graphid }
      message
    end

    def decode(data)
      Valhalla::Mjolnir::Transit.decode(data)
    end

    def encode
      Valhalla::Mjolnir::Transit.encode(@message)
    end

    def next_index
      (@index.keys.max || 0) + 1
    end

    def bbox
      GraphID.level_tile_to_bbox(@level, @tile)
    end
  end
end
