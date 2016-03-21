require './lib/dont-overstay'
require 'minitest/autorun'
require 'date'
class TestInitializer < MiniTest::Unit::TestCase
  def setup
    @daytracker = Daytracker.new
  end

  def test_that_before_is_current_time
    current_time = Time.now.to_i
    result = @daytracker.query
    assert_equal current_time.to_i, result[:before].to_i
  end
  
  def test_that_after_is_one_year_ago
    three_sixty_five_days_ago = (Date.today - 365).to_time.to_i
    result = @daytracker.query
    assert_equal three_sixty_five_days_ago.to_i, result[:after].to_i
  end

  def test_default_padded_days
    result = @daytracker.query
    assert_equal result[:padded_days], 0
  end
end
