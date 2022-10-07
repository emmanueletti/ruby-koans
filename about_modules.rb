require File.expand_path(File.dirname(__FILE__) + "/neo")

class AboutModules < Neo::Koan
  module Nameable
    def set_name(new_name)
      @name = new_name
    end

    def here
      :in_module
    end
  end

  def test_cant_instantiate_modules
    assert_raise(NoMethodError) { Nameable.new }
  end

  # ------------------------------------------------------------------

  class Dog
    # include vs extends -> look at example
    # https://www.geeksforgeeks.org/include-v-s-extend-in-ruby/#:~:text=In%20simple%20words%2C%20the%20difference,but%20not%20to%20its%20instance.
    include Nameable

    attr_reader :name

    def initialize
      @name = "Fido"
    end

    def bark
      "WOOF"
    end

    def here
      :in_object
    end
  end

  def test_normal_methods_are_available_in_the_object
    fido = Dog.new
    assert_equal "WOOF", fido.bark
  end

  def test_module_methods_are_also_available_in_the_object
    fido = Dog.new
    assert_nothing_raised { fido.set_name("Rover") }
  end

  # Modules are great at encapsulating beheviour that can be attached
  # to any object and change that objects internal data state and such
  def test_module_methods_can_affect_instance_variables_in_the_object
    fido = Dog.new
    assert_equal "Fido", fido.name
    fido.set_name("Rover")
    assert_equal "Rover", fido.name
  end

  def test_classes_can_override_module_methods
    fido = Dog.new
    assert_equal :in_object, fido.here
  end
end
