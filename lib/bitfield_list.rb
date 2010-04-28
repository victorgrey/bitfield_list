module  BitfieldList
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def bitfield(field, flaglist)
      instance_variable_set(:"@__#{field}__", Bitfld.new(flaglist))
      class_eval %(class << self; attr_accessor :__#{field}__ end)
      
      define_method(field) do
        bf_eval(:"__#{field}__", :bitfield_to_flags, read_attribute(field))
      end
      
      define_method(:"#{field}=") do |flags|
        bitfield_value = bf_eval(:"__#{field}__", :set_items, flags, 0)
        write_attribute(field, bitfield_value)
      end
      
      define_method(:"#{field}_add") do |flags|
        bitfield_value = bf_eval(:"__#{field}__", :set_items, flags, read_attribute(field))
        write_attribute(field, bitfield_value)
      end
      
      define_method(:"#{field}_remove") do |flags|
        bitfield_value = bf_eval(:"__#{field}__", :unset_items, flags, read_attribute(field))
        write_attribute(field, bitfield_value)
      end
      
      define_method(:"#{field}_set?") do |flag|
        bf_eval(:"__#{field}__", :item_set?, flag, read_attribute(field))
      end
      
      define_method(:"#{field}_flaglist") do 
        bf_eval(:"__#{field}__", :flaglist)
      end
    end
  end
  
  def bf_eval(bf, *args)
    self.class.send(bf).send(*args)
  end
  
  class Bitfld
    attr_reader :flaglist
    def initialize(flaglist)
      @flaglist = flaglist
    end
    ## does a given bitfield include a given access value or name?       
    def flag_to_value(flag)
      begin
        if String === flag || Symbol === flag
          if @flaglist.include? flag.to_s
            2 ** @flaglist.index(flag.to_s)
          else
            raise ArgumentError, "Invalid flag name"
          end
        else
          flag.to_i
        end
      end
    end  
  
    def item_set?(flag, bitfield)
      (flag_to_value(flag) & bitfield) != 0
    end
  

    def set_items(flags, bitfield)
      if Array === flags
        flags.inject(bitfield) {|memo, flag| memo | flag_to_value(flag)}
      else
        bitfield | flag_to_value(flags)
      end
    end
  
    def unset_items(flags, bitfield)
      if Array === flags
        flags.inject(bitfield) {|memo, flag| memo & ~flag_to_value(flag)}
      else
    	  bitfield & ~flag_to_value(flags)
    	end
    end
  
    ## returns array of item names
    def bitfield_to_flags(bitfield)
      result = Array.new
      if Integer === bitfield
        @flaglist.each {|flag| result << flag.to_s if item_set?(flag, bitfield)}
      else
        raise ArgumentError, "Bitfield must be an integer", caller
      end
      result
    end
  end
end