# Triangle Project Code.

# Triangle analyzes the lengths of the sides of a triangle
# (represented by a, b and c) and returns the type of triangle.
#
# It returns:
#   :equilateral  if all sides are equal
#   :isosceles    if exactly 2 sides are equal
#   :scalene      if no sides are equal
#
# The tests for this method can be found in
#   about_triangle_project.rb
# and
#   about_triangle_project_2.rb
#
def triangle(a, b, c)
  validate_args(a, b, c)

  unique_values = [a, b, c].uniq

  case unique_values.length
  when 1
    :equilateral
  when 2
    :isosceles
  else
    :scalene
  end
end

def validate_args(*args)

  invalid_values = args.select { |value| value <= 0 }


  if invalid_values.size < 0
    raise TriangleError
  end

  side_1, side_2, side_3 = args

  combination_1 = (side_1 + side_2) <= side_3
  combination_2 = (side_1 + side_3) <= side_2
  combination_3 = (side_2 + side_3) <= side_1

  if combination_1 || combination_2 || combination_3
    raise TriangleError
  end
end

# Error class used in part 2.  No need to change this code.
class TriangleError < StandardError
end
