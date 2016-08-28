module Warp::Validation
  alias NUMERIC_TYPES = Int32 | Int64 | Float32 | Float64

  struct Messages
    @FIELD_PREFIX : String = "Field "
    @REQUIRED_SUFFIX : String = " is required "
    @SIZED_BETWEEN_SUFFIX : String = " should be between "
    @SIZED_BETWEEN_CONNECTOR : String = " and "
    @SIZED_EQUALS_SUFFIX : String = " should be equals to "
    @FORMAT_BETWEEN_SUFFIX : String = " has an invalid format. "

    def filled?(field_name : String)
      str = String.build do |str|
        str << @FIELD_PREFIX << field_name << @REQUIRED_SUFFIX
      end
      return str
    end

    def sized?(field_name : String, field_min_size : NUMERIC_TYPES, field_max_size : NUMERIC_TYPES?)
      str = String.build do |str|
        if field_max_size
          str << @FIELD_PREFIX << field_name << @SIZED_BETWEEN_SUFFIX << field_min_size << @SIZED_BETWEEN_CONNECTOR << field_max_size
        else
          str << @FIELD_PREFIX << field_name << @SIZED_EQUALS_SUFFIX << field_min_size
        end
      end

      return str
    end

    def format?(field_name : String, format_message : String)
      return str = String.build do |str|
        str << @FIELD_PREFIX << field_name << @FORMAT_BETWEEN_SUFFIX << format_message
      end
    end
  end
end
