# -*- encoding: utf-8 -*-
#
# dsl.rb
#
# Copyright (c) 2011-2014 by Philippe Bourgau. All rights reserved.
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

  # Implementation of the DSL used to define new APIs on real web stores.
  # See README for examples
  class Dsl

    # Starts the definition of the API. Evaluates the block with the
    # context of an instance of Storexplore::Dsl
    def self.walker_builder(&block)
      new.tap do |dsl|
        dsl.instance_eval(&block)
      end
    end

    # Initializes a new instance with no special categories, items or
    # attributes definition. (Internal usage)
    def initialize
      @scrap_attributes_block = lambda do |_| {} end
      @categories_digger = NullDigger.new
      @items_digger = NullDigger.new
    end

    # Registers the block to be used to extract attributes from a store page.
    # Block will be evaluated within the context of a Storexplore::WalkerPage
    def attributes(&block)
      @scrap_attributes_block = block
    end

    # Defines how to find child categories.
    # * selector is the nokogiri selector to match links to these categories
    # * the block defines how to scrap these children categories, will
    #   be evaluated within the context of the child Storexplore::Dsl instance
    def categories(selector, &block)
      @categories_digger = Digger.new(selector, Dsl.walker_builder(&block))
    end

    # Same as #categories, but for child items
    def items(selector, &block)
      @items_digger = Digger.new(selector, Dsl.walker_builder(&block))
    end

    # Initializes a new Storexplore::Walker instance based on specified custom
    # definitions from the instance.
    # * page_getter : proxy to the page that we want to explore
    # * father : parent Storexplore::Walker instance (troubleshouting)
    # * index : index of the page within its brothers
    # (Internal usage)
    def new_walker(page_getter, father = nil, index = nil)
      Walker.new(page_getter).tap do |walker|
        walker.categories_digger = @categories_digger
        walker.items_digger = @items_digger
        walker.scrap_attributes_block = @scrap_attributes_block
        walker.father = father
        walker.index = index
      end
    end
  end

end
