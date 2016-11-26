# frozen_string_literal: true
require 'spec_helper'

describe 'Chaotic - errors' do
  class GivesErrors
    include Chaotic::Command
    filter do
      string :str1
      string :str2, in: %w(opt1 opt2 opt3)
      integer :int1, discard_nils: true

      hash :hash1, discard_nils: true do
        boolean :bool1
        boolean :bool2
      end

      array :arr1, discard_nils: true do
        integer
      end
    end

    def execute
      inputs
    end
  end

  it 'returns an ErrorHash as the top level error object, and ErrorAtom\'s inside' do
    o = GivesErrors.run(hash1: 1, arr1: 'bob')
    assert !o.success
    assert o.errors.is_a?(Chaotic::Errors::ErrorHash)
    assert o.errors[:str1].is_a?(Chaotic::Errors::ErrorAtom)
    assert o.errors[:str2].is_a?(Chaotic::Errors::ErrorAtom)
    assert_nil o.errors[:int1]
    assert o.errors[:hash1].is_a?(Chaotic::Errors::ErrorAtom)
    assert o.errors[:arr1].is_a?(Chaotic::Errors::ErrorAtom)
  end

  it 'returns an ErrorHash for nested hashes' do
    o = GivesErrors.run(hash1: { bool1: 'ooooo' })

    assert !o.success
    assert o.errors.is_a?(Chaotic::Errors::ErrorHash)
    assert o.errors[:hash1].is_a?(Chaotic::Errors::ErrorHash)
    assert o.errors[:hash1][:bool1].is_a?(Chaotic::Errors::ErrorAtom)
    assert o.errors[:hash1][:bool2].is_a?(Chaotic::Errors::ErrorAtom)
  end

  it 'returns an ErrorArray for errors in arrays' do
    o = GivesErrors.run(str1: 'a', str2: 'opt1', arr1: ['bob', 1, 'sally'])

    assert !o.success
    assert o.errors.is_a?(Chaotic::Errors::ErrorHash)
    assert o.errors[:arr1].is_a?(Chaotic::Errors::ErrorArray)
    assert o.errors[:arr1][0].is_a?(Chaotic::Errors::ErrorAtom)
    assert_nil o.errors[:arr1][1]
    assert o.errors[:arr1][2].is_a?(Chaotic::Errors::ErrorAtom)
  end

  it 'titleizes keys' do
    atom = Chaotic::Errors::ErrorAtom.new(:newsletter_subscription, :boolean)
    assert_equal 'Newsletter Subscription must be a boolean', atom.message
  end

  describe 'Bunch o errors' do
    before do
      @outcome = GivesErrors.run(
        str1: '', str2: 'opt9', int1: 'zero', hash1: { bool1: 'bob' }, arr1: ['bob', 1, 'sally']
      )
    end

    it 'gives symbolic errors' do
      expected = {
        'str1' => :empty,
        'str2' => :in,
        'int1' => :integer,
        'hash1' => { 'bool1' => :boolean, 'bool2' => :required },
        'arr1' => [:integer, nil, :integer]
      }

      assert_equal expected, @outcome.errors.symbolic
    end

    it 'gives messages' do
      expected = {
        'str1' => 'Str1 cannot be empty',
        'str2' => 'Str2 is not an available option',
        'int1' => 'Int1 must be an integer',
        'hash1' => {
          'bool1' => 'Bool1 must be a boolean',
          'bool2' => 'Bool2 is required'
        },
        'arr1' => ['1st Arr1 must be an integer', nil, '3rd Arr1 must be an integer']
      }

      assert_equal expected, @outcome.errors.message
    end

    it 'can flatten those messages' do
      expected = [
        'Str1 cannot be empty',
        'Str2 is not an available option',
        'Int1 must be an integer',
        'Bool1 must be a boolean',
        'Bool2 is required',
        '1st Arr1 must be an integer',
        '3rd Arr1 must be an integer'
      ]

      assert_equal expected.size, @outcome.errors.message_list.size
      expected.each { |e| assert @outcome.errors.message_list.include?(e) }
    end
  end
end
