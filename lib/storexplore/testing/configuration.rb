# -*- encoding: utf-8 -*-
#
# configuration.rb
#
# Copyright (c) 2013-2014 by Philippe Bourgau. All rights reserved.
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 3.0 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
# MA 02110-1301  USA

require 'logger'

module Storexplore

  # Extra facilities to ease testing custom store APIs.
  module Testing

    # Call this with a block to initialize Storexplore::Testing. The given
    # block receives the Storexplore::Testing::Configuration as argument.
    def self.config
      @config ||= Configuration.new
      yield @config if block_given?
      @config
    end

    class Configuration

      def initialize
        @logger = Logger.new(STDOUT)
        @logger.level = Logger::INFO
        @explore_store_items_timeout = 5*60
      end

      # Sets the generation directory where the dummy stores will be generated.
      # A sub folder with name Storexplore::DummyStoreConstants#NAME will be
      # created there to holdvall generated dummy stores, the content of this
      # directory will be deleted when the Storexplore::DummyStore#wipeout
      # method is called.
      # This setup is required to use Storexplore::Testing.
      def dummy_store_generation_dir=(generation_dir)
        @generation_dir = generation_dir
      end
      # See #dummy_store_generation_dir=.
      # Throws if no generation dir was previously set
      def dummy_store_generation_dir
        raise StandardError.new('You need to configure a dummy store generation directory with Storexplore::Testing.config.dummy_store_generation_dir=') if @generation_dir.nil?
        @generation_dir
      end

      # Logger for custom test messages. By default, it logs to STDOUT with
      # info level.
      attr_accessor :logger

      # Timeout for a the initial test exploration of the items of a store. By default,
      # 5 minutes
      attr_accessor :explore_store_items_timeout

    end
  end
end
