module Warp
  abstract class View
    property outbox = {} of Symbol => JSON::Type 
    
    @content = String::Builder.new

    def to_s
      @content.to_s
    end

    macro attributes(list)
      %key_value = {{list}}.map do |key, value|
        "#{key}=\"#{value}\""
      end
      %key_value.join " "
    end

    macro legalize_tag(name)
      "#{ "{{name}}".gsub(/_/, '-') }"
    end

    macro tag(name)
      def {{name}}
        @content << "<#{ legalize_tag {{name.id}} } />"
      end
      def {{name}}(attrs : Hash)
        @content << "<#{ legalize_tag {{name.id}} } #{attributes attrs} />"
      end
      def {{name}}(content : String|Int)
        @content << "<#{ legalize_tag {{name.id}} }>#{content}</#{ legalize_tag {{name.id}} }>"
      end
      def {{name}}(attrs : Hash, content : String|Int)
        @content << "<#{ legalize_tag {{name.id}} }  #{attributes attrs} >#{content}</#{ legalize_tag {{name.id}} }>"
      end

      # Block Based DSL
      def {{name}}(&block)
        @content << "<#{ legalize_tag {{name.id}} }>"
        yield
        @content << "</#{ legalize_tag {{name.id}} }>"
      end
      def {{name}}(attrs : Hash, &block)
        @content << "<#{ legalize_tag {{name.id}} } #{attributes attrs}>"
        yield
        @content << "</#{ legalize_tag {{name.id}} }>"
      end

    end

    {% for html_tag in %w(a abbr address area article aside audio b base bdi bdo blockquote body br button canvas caption cite code col colgroup command datalist dd del details dfn div dl dt em embed fieldset figcaption figure footer form h1 h2 h3 h4 h5 h6 head header hgroup hr html i iframe img input ins kbd keygen label legend li link map mark menu meta meter nav noscript object ol optgroup option output p param pre progress q rp rt ruby s samp script section select small source span strong style sub summary sup table tbody td textarea tfoot th thead time title tr track u ul var video wbr) %}
    tag {{html_tag.id}}
    {% end %}

    abstract def render
  end
end
