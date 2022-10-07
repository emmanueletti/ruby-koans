require File.expand_path(File.dirname(__FILE__) + "/neo")

class AboutScope < Neo::Koan
  # NOTE: modules are great ways to package up behaviour to "include" into instance objects or "extend" in Classes
  # But also great for namespacing classes/constants/enums etc aka creating
  # names partitions so names don't clash -> like a folder directory
  module Jims
    class Dog
      def identify
        :jims_dog
      end
    end
  end

  module Joes
    class Dog
      def identify
        :joes_dog
      end
    end
  end

  def test_dog_is_not_available_in_the_current_scope
    # the current scope of "class AboutScope"
    assert_raise(NameError) { Dog.new }
  end

  def test_you_can_reference_nested_classes_using_the_scope_operator
    # scope operator = ::
    fido = Jims::Dog.new
    rover = Joes::Dog.new
    assert_equal :jims_dog, fido.identify
    assert_equal :joes_dog, rover.identify

    # even though they share the same name, they are different objects in
    # memory because of the scope / namespacing
    # if they were in the same scope, then they would be be the same object
    # in memory, thus any definitions would be opening up and working with
    # the same class
    assert_equal true, fido.class != rover.class
    assert_equal true, Jims::Dog != Joes::Dog
  end

  # ------------------------------------------------------------------

  class String
  end

  def test_bare_bones_class_names_assume_the_current_scope
    assert_equal true, AboutScope::String == String
  end

  def test_nested_string_is_not_the_same_as_the_system_string
    assert_equal false, String == "HI".class
  end

  def test_use_the_prefix_scope_operator_to_force_the_global_scope
    # the :: in front signifies the root scope which is the global scope
    assert_equal true, ::String == "HI".class
  end

  # ------------------------------------------------------------------

  # this is a constant inside "class AboutScope"
  PI = 3.1416

  def test_constants_are_defined_with_an_initial_uppercase_letter
    assert_equal 3.1416, PI
  end

  # ------------------------------------------------------------------

  # this is a constant inside "class AboutScope"
  MyString = ::String

  def test_class_names_are_just_constants
    assert_equal __, MyString == ::String
    assert_equal __, MyString == "HI".class
  end

  def test_constants_can_be_looked_up_explicitly
    assert_equal __, PI == AboutScope.const_get("PI")
    assert_equal __, MyString == AboutScope.const_get("MyString")
  end

  def test_you_can_get_a_list_of_constants_for_any_class_or_module
    assert_equal __, Jims.constants
    assert Object.constants.size > _n_
  end
end
