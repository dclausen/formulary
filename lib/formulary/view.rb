require "htmlbeautifier"

module Formulary
  class View
    BOOLEAN_ATTRIBUTES = %w(disabled readonly multiple checked autobuffer
                         autoplay controls loop selected hidden scoped async
                         defer reversed ismap seamless muted required
                         autofocus novalidate formnovalidate open pubdate
                         itemscope allowfullscreen default inert sortable
                         truespeed typemustmatch).to_set

    BOOLEAN_ATTRIBUTES.merge(BOOLEAN_ATTRIBUTES.map {|attribute| attribute.to_sym })

    TAG_PREFIXES = ['aria', 'data', :aria, :data].to_set

    PRE_CONTENT_STRINGS = {
      :textarea => "\n"
    }

    attr_accessor :output_buffer

    def initialize(form)
      @form = form
      @output_buffer = ""
    end

    protected

    # ruthlessly stolen from rails actionview
    def concat(string)
      @output_buffer << string
    end

    def tag(name, options = nil, open = false)
      "<#{name}#{tag_options(options) if options}#{open ? ">" : " />"}"
    end

    def content_tag(name, content_or_options_with_block = nil, options = nil, escape = false, &block)
      if block_given?
        options = content_or_options_with_block if content_or_options_with_block.is_a?(Hash)
        content_tag_string(name, capture(&block), options, escape)
      else
        content_tag_string(name, content_or_options_with_block, options, escape)
      end
    end

    def content_tag_string(name, content, options, escape = false)
      tag_options = tag_options(options, escape) if options
      "<#{name}#{tag_options}>#{PRE_CONTENT_STRINGS[name.to_sym]}#{content}</#{name}>"
    end

    def tag_options(options, escape = false)
      return if options.blank?
      attrs = []
      options.each_pair do |key, value|
        if TAG_PREFIXES.include?(key) && value.is_a?(Hash)
          value.each_pair do |k, v|
            attrs << prefix_tag_option(key, k, v, escape)
          end
        elsif BOOLEAN_ATTRIBUTES.include?(key)
          attrs << boolean_tag_option(key) if value
        elsif !value.nil?
          attrs << tag_option(key, value, escape)
        end
      end
      " #{attrs * ' '}" unless attrs.empty?
    end

    def prefix_tag_option(prefix, key, value, escape)
      key = "#{prefix}-#{key.to_s.dasherize}"
      unless value.is_a?(String) || value.is_a?(Symbol) || value.is_a?(BigDecimal)
        value = value.to_json
      end
      tag_option(key, value, escape)
    end

    def boolean_tag_option(key)
      %(#{key}="#{key}")
    end

    def tag_option(key, value, escape)
      if value.is_a?(Array)
        value.join(" ")
      end
      %(#{key}="#{value}")
    end

    def capture(*args)
      value = nil
      buffer = with_output_buffer { value = yield(*args) }
      if string = buffer.presence || value and string.is_a?(String)
        string
      end
    end

    # Use an alternate output buffer for the duration of the block.
    # Defaults to a new empty string.
    def with_output_buffer(buf = nil) #:nodoc:
      unless buf
        buf = ""
        buf.force_encoding(output_buffer.encoding) if output_buffer
      end
      self.output_buffer, old_buffer = buf, output_buffer
      yield
      output_buffer
    ensure
      self.output_buffer = old_buffer
    end
  end
end
