require 'test/unit'
require File.join(File.dirname(__FILE__), "..", "lib", "default_order")

class DefaultOrderTest < Test::Unit::TestCase
  
  include DefaultOrder
  
  def test_build_order_string
    assert_equal "table_name.field_one,table_name.field-two ASC",
      self.class.build_order_string(['field_one', 'field-two']),
      "build without mode"

    assert_equal "table_name.field_one,table_name.field-two DESC",
      self.class.build_order_string(['field_one', 'field-two'], "DESC"),
      "build DESC"

    assert_equal "table_name.field_one,table_name.field-two ASC",
      self.class.build_order_string(['field_one', 'field-two'], "ASC"),
      "build ASC"
  end
  
  def test_build_order_string_from_hash
  
    assert_equal "table_name.field_one,table_name.field-two ASC",
      self.class.build_order_string_from_hash(:fields => ['field_one', 'field-two'])
      "build from hash without mode"
    
    assert_equal "table_name.field_one,table_name.field-two DESC",
      self.class.build_order_string_from_hash(:fields => ['field_one', 'field-two'], :mode => :desc),
      "build from hash with Symbol mode"
          
    assert_equal "table_name.field_one,table_name.field-two ASC",
      self.class.build_order_string_from_hash(:fields => ['field_one', 'field-two'], :mode => "ASC")
      "build from hash with String mode"
    
    assert_equal "table_name.field_one DESC",
      self.class.build_order_string_from_hash(:fields => 'field_one', :mode => :desc),
      "build from hash with string fields option"

    assert_equal "table_name.field_one,table_name.field-two ASC",
      self.class.build_order_string_from_hash(:fields => 'field_one, field-two', :mode => :asc),
      "build from hash with string fields option"      
  end
  
  def self.table_name
    "table_name"
  end
  

end
