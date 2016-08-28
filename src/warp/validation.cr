module Warp::Validation
  # Validations

  @validations = {} of String => Array(String)
  @params = HTTP::Params.new({} of String => Array(String))

  def valid?
    return @validations.size <= 0
  end

  def validations(@params, &block)
    @validations = {} of String => Array(String)
    yield
    return @validations, valid?
  end

  def required(field = "", kind : T = String, &block)
    predicate = Predicate.new(@params, field, kind)
    yield predicate
    @validations.merge! predicate.validations
    @validations.each do |key, value|
      @validations.delete(key) if value.size <= 0
    end
  end

  class Predicate
    property validations = {} of String => Array(String)
    getter params = HTTP::Params.new({} of String => Array(String))
    property valid = true
    @value = ""

    def initialize(@params, @field = "", @field_name = "", @kind : T = String)
      validations[@field] = [] of String
      @value = params[field]?.try &.[0]?.try &.to_s || ""
    end

    def filled?
      _valid = @valid
      (@valid = (@value.try &.size || 0) > 0) if @valid
      # Saving error message
      validations[@field] << Messages.new.filled?(@field_name) if !@valid && _valid
      return self
    end

    def filled?(&block)
      yield filled?
    end

    def sized?(valid_size : NUMERIC_TYPES = 0)
      _valid = @valid
      if @valid
        case @kind
        when String.class
          (@valid = (@value.try &.size || 0.0) == valid_size.to_f)
        when Int32.class
          (@valid = (@value.try &.to_f || 0.0) == valid_size.to_f)
        end
      end
      # Saving error message
      validations[@field] << Messages.new.sized?(@field_name, valid_size, nil) if !@valid && _valid
      return self
    end

    def sized?(valid_size : NUMERIC_TYPES = 0, &block)
      yield sized?(valid_size)
    end

    def sized?(valid_size : Range(NUMERIC_TYPES, NUMERIC_TYPES) = 0..1)
      _valid = @valid
      if @valid
        case @kind
        when String.class
          (@valid = valid_size.includes?(@value.try &.size || 0.0))
        when Int32.class
          (@valid = valid_size.includes?(@value.try &.to_f || 0.0))
        end
      end
      # Saving error message
      validations[@field] << Messages.new.sized?(@field_name, valid_size.begin, valid_size.end) if !@valid && _valid
      return self
    end

    def sized?(valid_size : Range(NUMERIC_TYPES, NUMERIC_TYPES) = 0..1, &block)
      yield sized?(valid_size)
    end

    def format?(format_regex = //, format_message = "")
      _valid = @valid
      (@valid = (@value.try &.=~ format_regex) != nil) if @valid
      # Saving error message
      validations[@field] << Messages.new.format?(@field_name, format_message) if !@valid && _valid

      return self
    end

    def format?(format_regex = //, format_message = "", &block)
      yield format?(format_regex, format_message)
    end

    def custom(&block)
      yield self
    end
  end
end

# class Test
#   include Warp::Validation

#   def initialize
#     params = HTTP::Params.new({"user" => ["rayner"], "password" => [ "test" ] })

#     errors, valid = validations(params) do
#       required "user", "Usuario", &.filled?.sized?(1..5)
#       required "password", "Clave", &.filled?.sized?(1..30)
#     end

#   end
# end

# Test.new
