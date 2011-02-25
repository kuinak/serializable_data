require "test/unit"
require "serializable_data"

class Dummy
  def self.serialize(ignored); end # stub
  def initialize(ignored = nil); end # stub
  include SerializableData # N.B. 'include' statement must follow
                           # definiion of Dummy#initialize, otherwise
                           # call to super will hit Object#initialize,
                           # which will blow up b/c that takes 0 args
  attr_accessor :serialized_data_column
  serialized_data :serialized_data_column, :a_string => :string,
                                           :a_boolean => :boolean,
                                           :an_array => :array
end

class SerializableDataTest < Test::Unit::TestCase

  def test_scalar
    dummy = Dummy.new
    hash = {:a_string => "hi"}
    dummy.a_string = "hi"
    assert_equal "hi", dummy.a_string
  end

  def test_scalar_missing
    dummy = Dummy.new
    hash = {}
    assert_nil dummy.a_string
  end

  def test_boolean_true
    dummy = Dummy.new
    hash = {:a_boolean => true}
    dummy.a_boolean = true
    assert_equal true, dummy.a_boolean
    assert_equal true, dummy.a_boolean?
    dummy.a_boolean = 1
    assert_equal true, dummy.a_boolean
    dummy.a_boolean = "1"
    assert_equal true, dummy.a_boolean
  end

  def test_boolean_false
    dummy = Dummy.new
    hash = {:a_boolean => false}
    dummy.a_boolean = false
    assert_equal false, dummy.a_boolean
    assert_equal false, dummy.a_boolean?
    dummy.a_boolean = 0
    assert_equal false, dummy.a_boolean
    dummy.a_boolean = "0"
    assert_equal false, dummy.a_boolean
  end

  def test_boolean_missing
    dummy = Dummy.new
    hash = {}
    assert_nil dummy.a_boolean
  end

  def test_array
    dummy = Dummy.new
    hash = {:an_array => ["a", "b"]}
    dummy.an_array = ["a", "b"]
    assert_equal ["a", "b"], dummy.an_array
  end

  def test_array_missing
    dummy = Dummy.new
    hash = {}
    assert_equal [], dummy.an_array
  end

end
