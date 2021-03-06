module Warp
  abstract class View(T)
    getter props : Hash(Symbol, T)
    # getter params = Params.new(HTTP::Params.new({} of String => Array(String)), HTTP::Params.new({} of String => Array(String)))
    @content = String::Builder.new

    def to_s
      @content.to_s
    end

    def attributes_to_s(attributes = {} of Symbol => String)
      attributes.map { |key, value| "#{key}=\"#{value}\"" }.join " "
      # %key_value = {{list}}.map do |key, value|
      #   "#{key}=\"#{value}\""
      # end
      # %key_value.join " "
    end

    macro legalize_tag(name)
      "#{ "{{name}}".gsub(/_/, '-') }"
    end

    macro tag(name)
      def {{name}}
        @content << "<#{ legalize_tag {{name.id}} } />"
      end
      def {{name}}(attrs : Hash)
        @content << "<#{ legalize_tag {{name.id}} } #{attributes_to_s attrs} />"
      end
      def {{name}}(content : Type)
        @content << "<#{ legalize_tag {{name.id}} }>#{content}</#{ legalize_tag {{name.id}} }>"
      end
      def {{name}}(attrs : Hash, content : Type)
        @content << "<#{ legalize_tag {{name.id}} }  #{attributes_to_s attrs} >#{content}</#{ legalize_tag {{name.id}} }>"
      end

      # Block Based DSL
      def {{name}}(&block)
        @content << "<#{ legalize_tag {{name.id}} }>"
        yield
        @content << "</#{ legalize_tag {{name.id}} }>"
      end
      def {{name}}(attrs : Hash, &block)
        @content << "<#{ legalize_tag {{name.id}} } #{attributes_to_s attrs}>"
        yield
        @content << "</#{ legalize_tag {{name.id}} }>"
      end

    end

    {% for html_tag in %w(a abbr address area article aside audio b base bdi bdo blockquote body br button canvas caption cite code col colgroup command datalist dd del details dfn div dl dt em embed fieldset figcaption figure footer form h1 h2 h3 h4 h5 h6 head header hgroup hr html i iframe img input ins kbd keygen label legend li link map mark menu meta meter nav noscript object ol optgroup option output p param pre progress q rp rt ruby s samp script section small source span strong style sub summary sup table tbody td textarea tfoot th thead time title tr track u ul var video wbr) %}
    tag {{html_tag.id}}
    {% end %}

    def select!
      @content << "<select/>"
    end

    def select!(attrs : Hash)
      @content << "<select #{attributes_to_s attrs} />"
    end

    def select!(content : Type)
      @content << "<select>#{content}</select>"
    end

    def select!(attrs : Hash, content : Type)
      @content << "<select #{attributes_to_s attrs} >#{content}</select>"
    end

    # Block Based DSL
    def select!(&block)
      @content << "<select>"
      yield
      @content << "</select>"
    end

    def select!(attrs : Hash, &block)
      @content << "<select #{attributes_to_s attrs}>"
      yield
      @content << "</select>"
    end

    def initialize(@props : Hash(Symbol, T), @content = String::Builder.new)
    end

    abstract def render

    # class Params
    #   getter query = HTTP::Params.new({} of String => Array(String))
    #   getter form = HTTP::Params.new({} of String => Array(String))

    #   def initialize(@query, @form)
    #   end
    # end
  end

  module View::Form::Helper
    def text_field_tag(name = "", value = "", placeholder = "", attributes = {} of Symbol => String, type = "text")
      value = props[:query]?.try &.as?(HTTP::Params).try &.[name]? || props[:form]?.try &.as?(HTTP::Params).try &.[name]? || value
      attributes.merge!({:name => name, :id => (name.gsub /\./, "_"), :placeholder => placeholder, :type => type, :value => value})
      input(attributes)
    end

    def hidden_field_tag(name = "", value = "", attributes = {} of Symbol => String)
      value = props[:query]?.try &.as?(HTTP::Params).try &.[name]? || props[:form]?.try &.as?(HTTP::Params).try &.[name]? || value
      attributes.merge!({:name => name, :id => (name.gsub /\./, "_"), :type => "hidden", :value => value})
      input(attributes)
    end

    def select_field_tag(name = "", value = "", data : T = [] of Tuple(String, String), attributes = {} of Symbol => String) forall T
      data_array = data.try &.as?(Array(Tuple(String, String))) || [] of Tuple(String, String)
      value = props[:query]?.try &.as?(HTTP::Params).try &.[name]? || props[:form]?.try &.as?(HTTP::Params).try &.[name]? || value
      attributes.merge!({:name => name, :id => (name.gsub /\./, "_")})
      select!(attributes) do
        data_array.each do |option_data|
          option_attributes = {:value => option_data[0]}
          option_attributes.merge!({:selected => "true"}) if (option_data[0] == value)
          option(option_attributes, option_data[1])
        end
      end
    end
  end
end
