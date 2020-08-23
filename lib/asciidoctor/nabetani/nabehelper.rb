module Asciidoctor
  module NabeHelper
    module_function 
    def get_node_attriute_float node, name, fallback
      t = node.attributes[name]
      return fallback unless t

      begin
        return Float(t)
      rescue ArgumentError => e
        raise ArgumentError, "#{name} value should be float value, but it is #{t.inspect} (#{e.inspect})"
      end
    end

    def three_state(v0, key)
      v = v0.is_a?(String) ? v0.downcase.strip : v0
      case v
      when true, 1, 'true', '1', 'yes', 'on'
        true
      when false, 0, 'false', '0', 'no', 'off'
        false
      when nil, 'nil', 'null', 'default', '~'
        nil
      else
        raise ArgumentError, "#{key} should be true, false, or nil, but it is #{v0.inspect}"
      end
    end

    def get_node_attriute_float_array node, name, fallback
      t = node.attributes[name]
      return fallback unless t

      begin
        return t.split(",").map{ |e| Float(e.strip) }
      rescue ArgumentError => e
        raise ArgumentError, "#{name} value should be array of float value, but it is #{t.inspect} (#{e.inspect})"
      end
    end
  end
end
