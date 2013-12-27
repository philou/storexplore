# -*- encoding: utf-8 -*-
#
# configuration.rb
#
# Copyright (c) 2010, 2011, 2012, 2013 by Philippe Bourgau. All rights reserved.
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
  module Testing

    def self.config
      @config ||= Configuration.new
      yield @config if block_given?
      @config
    end

    class Configuration

      def initialize
        @logger = Logger.new(STDOUT)
        @logger.level = Logger::INFO
      end

      # Generation directory where the dummy stores will be generated.
      # A sub folder with name DummyStore::NAME will be created there to hold all generated dummy stores,
      # the content of this directory will be deleted when the DummyStore.wipeout method is called
      def dummy_store_generation_dir
        raise StandardError.new('You need to configure a dummy store generation directory with Storexplore::Testing.config.dummy_store_generation_dir=') if @generation_dir.nil?
        @generation_dir
      end
      def dummy_store_generation_dir=(generation_dir)
        @generation_dir = generation_dir
      end

      # Logger for custom test messages
      attr_accessor :logger

    end
  end
end
