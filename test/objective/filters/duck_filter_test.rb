# frozen_string_literal: true

require 'test_helper'

describe 'Objective::Filters::DuckFilter' do
  it 'allows objects that respond to a single specified method' do
    f = Objective::Filters::DuckFilter.new(:quack, methods: [:length])
    result = f.feed('test')
    assert_equal 'test', result.inputs
    assert_nil result.errors

    result = f.feed([1, 2])
    assert_equal [1, 2], result.inputs
    assert_nil result.errors
  end

  it 'does not allow objects that respond to a single specified method' do
    f = Objective::Filters::DuckFilter.new(:quack, methods: [:length])
    result = f.feed(true)
    assert_equal true, result.inputs
    assert_equal :duck, result.errors

    result = f.feed(12)
    assert_equal 12, result.inputs
    assert_equal :duck, result.errors
  end

  it 'considers nil to be invalid' do
    f = Objective::Filters::DuckFilter.new(:quack)
    result = f.feed(nil)
    assert_nil result.inputs
    assert_equal :nils, result.errors
  end

  it 'considers nil to be valid' do
    f = Objective::Filters::DuckFilter.new(:quack, nils: Objective::ALLOW)
    result = f.feed(nil)
    assert_nil result.inputs
    assert_nil result.errors
  end

  it 'Allows anything if no methods are specified' do
    f = Objective::Filters::DuckFilter.new
    [true, 'hi', 1, [1, 2, 3], { one: 1 }, 1..3].each do |v|
      result = f.feed(v)
      assert_equal v, result.inputs
      assert_nil result.errors
    end
  end
end
