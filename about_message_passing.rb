require File.expand_path(File.dirname(__FILE__) + "/neo")

class AboutMessagePassing < Neo::Koan
  class MessageCatcher
    def caught?
      true
    end
  end

  def test_methods_can_be_called_directly
    mc = MessageCatcher.new

    assert mc.caught?
  end

  def test_methods_can_be_invoked_by_sending_the_message
    mc = MessageCatcher.new

    assert mc.send(:caught?)
  end

  def test_methods_can_be_invoked_more_dynamically
    mc = MessageCatcher.new

    assert mc.send(:caught?)
    assert mc.send("caught" + "?") # What do you need to add to the first string?
    assert mc.send("CAUGHT?".downcase) # What would you need to do to the string?
  end

  def test_send_with_underscores_will_also_send_messages
    mc = MessageCatcher.new

    assert_equal true, mc.__send__(:caught?)

    # THINK ABOUT IT:
    #
    # Why does Ruby provide both send and __send__ ?
    # you can overwrite "send" while still keeping the functionality with __send__
    # https://stackoverflow.com/questions/4658269/ruby-send-vs-send
  end

  def test_classes_can_be_asked_if_they_know_how_to_respond
    mc = MessageCatcher.new

    assert_equal true, mc.respond_to?(:caught?)
    assert_equal false, mc.respond_to?(:does_not_exist)
  end

  # ------------------------------------------------------------------

  class MessageCatcher
    def add_a_payload(*args)
      args
    end
  end

  def test_sending_a_message_with_arguments
    mc = MessageCatcher.new

    assert_equal [], mc.add_a_payload
    assert_equal [], mc.send(:add_a_payload)

    assert_equal [3, 4, nil, 6], mc.add_a_payload(3, 4, nil, 6)
    assert_equal [3, 4, nil, 6], mc.send(:add_a_payload, 3, 4, nil, 6)
  end

  # NOTE:
  #
  # Both obj.msg and obj.send(:msg) sends the message named :msg to
  # the object. We use "send" when the name of the message can vary
  # dynamically (e.g. calculated at run time), but by far the most
  # common way of sending a message is just to say: obj.msg.

  # ------------------------------------------------------------------

  class TypicalObject
  end

  def test_sending_undefined_messages_to_a_typical_object_results_in_errors
    typical = TypicalObject.new

    exception = assert_raise(NoMethodError) { typical.foobar }
    assert_match(/foobar/, exception.message)
  end

  def test_calling_method_missing_causes_the_no_method_error
    typical = TypicalObject.new

    exception = assert_raise(NoMethodError) { typical.method_missing(:foobar) }
    assert_match(/foobar/, exception.message)

    # THINK ABOUT IT:
    #
    # If the method :method_missing causes the NoMethodError, then
    # what would happen if we redefine method_missing?
    # we can make it do whatever we want
    # NOTE:
    #
    # In Ruby 1.8 the method_missing method is public and can be
    # called as shown above. However, in Ruby 1.9 (and later versions)
    # the method_missing method is private. We explicitly made it
    # public in the testing framework so this example works in both
    # versions of Ruby. Just keep in mind you can't call
    # method_missing like that after Ruby 1.9 normally.
    #
    # Thanks.  We now return you to your regularly scheduled Ruby
    # Koans.
  end

  # ------------------------------------------------------------------

  class AllMessageCatcher
    def method_missing(method_name, *args)
      "Someone called #{method_name} with <#{args.join(", ")}>"
    end

    # instead of method_missing being called on ancestors like the built in ruby Object class, it is being redefined and
    # answerered here

    # it seems that what happens is that, first the message sent is passed from the object up to the very top of the
    # inheritance chain. Then if no was able to answer it, "method_missing" is sent from the same object and all the way
    # up to the top of the inheritance chain. If it did not get "caught", the root ruby Object will respond by returning
    # a NoMethodError exception
  end

  def test_all_messages_are_caught
    catcher = AllMessageCatcher.new

    assert_equal "Someone called foobar with <>", catcher.foobar
    assert_equal "Someone called foobaz with <1>", catcher.foobaz(1)
    assert_equal "Someone called sum with <1, 2, 3, 4, 5, 6>", catcher.sum(1, 2, 3, 4, 5, 6)
  end

  def test_catching_messages_makes_respond_to_lie
    catcher = AllMessageCatcher.new

    assert_nothing_raised { catcher.any_method }
    assert_equal false, catcher.respond_to?(:any_method)
    # any_method is being caught and so catcher is able to respond to it
    # BUT "respond_to?"is looking for an explicit definition of "any_method" which it cannot find
    # When overriding "method_missing" on an object, very very important to also override "respond_to_missing?"
    # UPDATE (19-0CT-2022) -> do not override / specialize "respond_to?", override / specialize "respond_to_missing?"
    # BUT when trying to see if an object that you havent overriden a method_missing on can respond to a method, then
    # use "respond_to?"
    # reason seems to be that "respond_to_missing?" covers some bases that "respong_to" doesnt
    # https://blog.marc-andre.ca/2010/11/15/methodmissing-politely/
    # https://thoughtbot.com/blog/always-define-respond-to-missing-when-overriding
  end

  # ------------------------------------------------------------------

  class WellBehavedFooCatcher
    def method_missing(method_name, *args, &block)
      if method_name.to_s[0, 3] == "foo"
        "Foo to you too"
      else
        super(method_name, *args, &block)
      end
    end
  end

  def test_foo_method_are_caught
    catcher = WellBehavedFooCatcher.new

    assert_equal "Foo to you too", catcher.foo_bar
    assert_equal "Foo to you too", catcher.foo_baz
  end

  def test_non_foo_messages_are_treated_normally
    catcher = WellBehavedFooCatcher.new

    assert_raise(NoMethodError) { catcher.normal_undefined_method }
  end

  # ------------------------------------------------------------------

  # (note: just reopening class from above)
  class WellBehavedFooCatcher
    def respond_to?(method_name)
      if method_name.to_s[0, 3] == "foo"
        true
      else
        super(method_name)
      end
    end
  end

  # since we are catching methods that begin with "foo" we also have to define respond_to? to tell the program that
  # methods beginning with "foo" are able to be responded to
  # UPDATE (19-0CT-2022) -> do not override / specialize "respond_to?", override / specialize "respond_to_missing?"
  # see above UPDATE comment for more details

  def test_explicitly_implementing_respond_to_lets_objects_tell_the_truth
    catcher = WellBehavedFooCatcher.new

    assert_equal true, catcher.respond_to?(:foo_bar)

    assert_equal false, catcher.respond_to?(:something_else)
  end
end

# seems that the combination of "send" and "method_missing" is what allows Rails to perform some of its magic
# - with "send" you can send messages to an object that are dynamically created at runtime - even based on user input
# - with careful redefinitions of "method_missing" and some regex pattern matching you can have objects react to the
# dynamic send messages and do stuff with it
