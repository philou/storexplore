# -*- encoding: utf-8 -*-
#
# api.rb
#
# Copyright (c) 2010, 2011, 2012, 2013, 2014 by Philippe Bourgau. All rights reserved.
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

module Storexplore

  # Objects able to walk a store and discover available items
  class Api

    def self.define(name, &block)
      builder = Dsl.walker_builder(&block)

      register_builder(name, builder)
    end

    def self.browse(store_url)
      builder(store_url).new_walker(WalkerPage.open(store_url))
    end

    def self.undef(name)
      builders.delete(name)
    end

    # Uri of the main page of the store
    # def uri

    # Attributes of the page
    # def attributes

    # Walkers of the root categories of the store
    # def categories

    # Walkers of the root items in the store
    # def items

    private

    def self.register_builder(name, builder)
      builders[name] = builder
    end

    def self.builder(store_url)
      builders.each do |name, builder|
        if store_url.include?(name)
          return builder
        end
      end
      raise NotImplementedError.new("Could not find a store item api for '#{store_url}'")
    end

    def self.builders
      @builders ||= {}
    end
  end

end
