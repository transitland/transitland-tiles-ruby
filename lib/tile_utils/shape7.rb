module TileUtils
  # https://github.com/valhalla/valhalla/blob/master/valhalla/midgard/encoded.h
  class Shape7
    def self.encode(coordinates)
      output = []
      last_lat = 0
      last_lon = 0
      coordinates.each do |lat, lon|
        lat = (lat * 1e6).floor
        lon = (lon * 1e6).floor
        # puts "last_lat: #{lat - last_lat} last_lon: #{lon - last_lon}"
        output += encode_int(lat - last_lat)
        output += encode_int(lon - last_lon)
        last_lat = lat
        last_lon = lon
      end
      output.join('')
    end

    def self.decode(value)
      last_lat = 0
      last_lon = 0
      decode_ints(value).each_slice(2).map do |lat,lon|
        lat /= 1e6
        lon /= 1e6
        last_lat += lat
        last_lon += lon
        [last_lat, last_lon]
      end
    end

    private

    def self.encode_int(number)
      ret = []
      number = number < 0 ? ~(number << 1) : number << 1
      while (number > 0x7f) do
        # Take 7 bits
        nextValue = (0x80 | (number & 0x7f))
        ret << nextValue.chr
        number >>= 7
      end
      # Last 7 bits
      ret << (number & 0x7f).chr
      ret
    end

    def self.decode_ints(value)
      ret = []
      index = 0
      while (index < value.size) do
        shift = 0
        result = 0
        nextValue = value[index].ord
        while (nextValue > 0x7f) do
          # Next 7 bits
          result |= (nextValue & 0x7f) << shift
          shift += 7
          index += 1
          nextValue = value[index].ord
        end
        # Last 7 bits
        result |= (nextValue & 0x7f) << shift
        # One's complement if msb is 1
        result = (result & 1 == 1 ? ~result : result) >> 1
        # Add to output
        ret << result
        index += 1
      end
      ret
    end
  end
end
