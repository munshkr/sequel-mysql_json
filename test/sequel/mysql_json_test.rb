require 'test_helper'

class Sequel::MysqlJsonTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Sequel::MysqlJson::VERSION
  end

  def test_it_does_something_useful
    assert false
  end
end
