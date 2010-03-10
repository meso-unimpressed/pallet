# Copyright (c) 2007 Antonin Amand (a.amand AT gwikzone DOT org )
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

module DefaultOrder
  
  VERSION = "0.2"
  
  def self.append_features(base) # :nodoc:
    super
    base.extend ClassMethods
  end
  
  module ClassMethods # :nodoc:
    
    # sanitize the string adding the table name before each field
    # to prevent failing with using joins.
    def sanitize_order_string(string)
      s = string.gsub(/\s*,\s*/, ',')
      s = s.gsub(/[\w-]+/) { |m| "#{self.table_name}.#{m}" }
    end
    
    # build the order string from an array of fields.
    def build_order_string(fields, mode="ASC")
      fields.collect{ |f| "#{self.table_name}.#{f}" }.join(",") + " " + mode
    end
    
    # build the order string from hash argument options.
    def build_order_string_from_hash(options)
      
      raise InvalidArgument.new('invalid hash :fields key not found') unless options[:fields]
      
      mode = "ASC"
      
      if options[:mode]
        mode = case options[:mode]
        when String
          options[:mode]
        when Symbol
          options[:mode].to_s.upcase
        else
          raise TypeError.new('invalid options :mode, must be either String (ASC, DESC) or a Symbol(:asc, :desc)')
        end
      end
      
      order_string = case options[:fields]
      when String
        return self.sanitize_order_string(options[:fields]) + " " + mode
      when Array
        return self.build_order_string(options[:fields], mode)
      else
        raise TypeError.new('invalid options :fields, must be either Array or a String')
      end
      
      order_string
      
    end
    
    # Use the following method in ActiveRecord::Base inherited class.
    # 
    # example : order_by :fields => "myfield", :mode => "ASC"
    # example2 : order_by :fields => ["field1", "field2"], :mode => :desc
    # example3 : order_by "mytable.myfield DESC"
    #
    # When using the Hash form the :mode option defaults to "ASC".
    # When using the String form don't forget to prefix with the table_name
    # or joins may not work
    def order_by(arg)
      
      order_string = ""
      
      case arg
      when String
        order_string = arg
      when Hash
        order_string = build_order_string_from_hash(arg)
      else
        raise TypeError('invalid arguments for order_by method')
      end
      
      self.class_eval %{
        class << self
          
          def find_with_order(*args)
            if args[1] 
              args[1][:order] = "#{order_string}" if args[1].is_a?(Hash) && !args[1][:order]
            else
              args[1] = {:order => "#{order_string}"}
            end
            find_without_order(*args)
          end
          
          alias_method :find_without_order, :find
          alias_method :find, :find_with_order
          
        end
      }
      
    end
    
  end
end
