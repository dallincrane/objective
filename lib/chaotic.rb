# frozen_string_literal: true
require 'ostruct'
require 'date'
require 'time'
require 'bigdecimal'
require 'bigdecimal/util'

require 'active_support/concern'
require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/core_ext/object/try'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/hash/deep_merge'
require 'active_support/core_ext/array/wrap'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/integer/inflections'

require 'chaotic/errors/error_atom'
require 'chaotic/errors/error_hash'
require 'chaotic/errors/error_array'
require 'chaotic/errors/default_error_message_creator'

require 'chaotic/filter'
require 'chaotic/filters/array_filter'
require 'chaotic/filters/boolean_filter'
require 'chaotic/filters/date_filter'
require 'chaotic/filters/decimal_filter'
require 'chaotic/filters/duck_filter'
require 'chaotic/filters/file_filter'
require 'chaotic/filters/float_filter'
require 'chaotic/filters/hash_filter'
require 'chaotic/filters/input_filter'
require 'chaotic/filters/integer_filter'
require 'chaotic/filters/model_filter'
require 'chaotic/filters/string_filter'
require 'chaotic/filters/time_filter'

require 'chaotic/outcome'
require 'chaotic/command'

module Chaotic
  mattr_accessor :error_message_creator
  self.error_message_creator = Errors::DefaultErrorMessageCreator.new

  mattr_accessor :cache_constants
  self.cache_constants = true

  def self.config
    yield self
  end
end