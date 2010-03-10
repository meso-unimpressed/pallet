module AdvancedStrings end

class String
  # replaces all tokens from replacement_list and returns changed text
  # expects array like [ ['a', 'AA'], ['b', 'BB'] ]
  # this will replace  a -> AA and  b -> BB
  # direction can be set to 'backward' to rereplace all tokens
  def multi_gsub!(replacement_list, direction = 'forward')
    return unless replacement_list
    
    unless direction == 'backward'
      to_be_replaced_pos = 0
      replace_pos = 1
    else
      to_be_replaced_pos = 1
      replace_pos = 0
    end
    
    for replacement in replacement_list
      self.gsub!(replacement[to_be_replaced_pos], replacement[replace_pos]) \
        if replacement[to_be_replaced_pos] and replacement[replace_pos]
    end
  end

  # Pluralizes string by amount.
  # For amounts not equal zero an 's' will be appended.
  # A plural word can be defined for use instead of appending the 's'.
  # If number is set to true, the amount will be appended to the string
  # by default in front, if append is set to true the amount will be appended
  # at the end
  # 'house'.pluralize_by(1) #=> "house" 
  # 'house'.pluralize_by(2) #=> "houses" 
  # 'man'.pluralize_by(30, :number => true, :plural => 'men') #=> "30 men" 
  def pluralize_by(amount = 1, options = {})
    default_options = { :number => false, 
                        :append => false, 
                        :plural => nil }
    options = default_options.merge(options)

    unless options[:plural]
      pluralized = self + (amount == 1 ? '' : 's')
    else
      pluralized = amount != 1 ? options[:plural] : self
    end

    if options[:number]
      return options[:append] ? pluralized + ' ' + amount.to_s : 
                                amount.to_s + ' ' + pluralized
    else
      return pluralized
    end
  end

  # simple email address format validation
  def valid_email_address?
    return false if self.nil? or self.empty?
    before_at = self.index('@').to_i - 1
    return false if self.index('.').nil? or self.index('@').nil? or # at least one dot and one at
                    self.rindex('.') < self.index('@') or           # last dot has to sit behind the at
                    self.rindex('.') + 3 > self.size or             # at least two chars after last dot
                    self[before_at..before_at] == '.'               # no dot directly in front of at
    return true
  end
end

class NilClass
  def valid_email_address?
    false
  end
end