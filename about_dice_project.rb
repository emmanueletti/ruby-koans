require File.expand_path(File.dirname(__FILE__) + "/neo")

# Implement a DiceSet Class here:
#
class DiceSet
  attr_reader :values

  NUM_OF_DICE_SIDES = 6

  def roll(num_of_dice)
    # remember: everything in ruby is an object that can be instantiated and
    # configured in that instantiation
    # javascript would have had us create and assign an empty array and then
    # iterate between a range of values to push into the empty array at each
    # iteration stop
    # ruby is wayyyy from focused on developer experience
    @values = Array.new(num_of_dice) { |_i| rand(1..NUM_OF_DICE_SIDES) }
  end
end

class AboutDiceProject < Neo::Koan
  def test_can_create_a_dice_set
    dice = DiceSet.new
    assert_not_nil dice
  end

  def test_rolling_the_dice_returns_a_set_of_integers_between_1_and_6
    dice = DiceSet.new

    dice.roll(5)
    assert dice.values.is_a?(Array), "should be an array"
    assert_equal 5, dice.values.size
    dice.values.each do |value|
      assert value >= 1 && value <= 6, "value #{value} must be between 1 and 6"
    end
  end

  def test_dice_values_do_not_change_unless_explicitly_rolled
    dice = DiceSet.new
    dice.roll(5)
    first_time = dice.values
    second_time = dice.values
    assert_equal first_time, second_time
  end

  def test_dice_values_should_change_between_rolls
    dice = DiceSet.new

    dice.roll(5)
    first_time = dice.values

    dice.roll(5)
    second_time = dice.values

    # Remember equality assertions don't compare if the contents of Arrays
    # are equal - they compare if the identity in memory are the same
    assert_not_equal first_time, second_time, "Two rolls should not be equal"

    # THINK ABOUT IT:
    #
    # If the rolls are random, then it is possible (although not
    # likely) that two consecutive rolls are equal.  What would be a
    # better way to test this?
  end

  def test_you_can_roll_different_numbers_of_dice
    dice = DiceSet.new

    dice.roll(3)
    assert_equal 3, dice.values.size

    dice.roll(1)
    assert_equal 1, dice.values.size
  end
end
