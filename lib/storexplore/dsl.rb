# -*- encoding: utf-8 -*-
#
# dsl.rb
#
# Copyright (c) 2011, 2012, 2013, 2014 by Philippe Bourgau. All rights reserved.
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

  class Dsl

    def self.walker_builder(&block)
      new.tap do |dsl|
        dsl.instance_eval(&block)
      end
    end

    def initialize()
      @scrap_attributes_block = lambda do |_| {} end
      @categories_digger = NullDigger.new
      @items_digger = NullDigger.new
    end

    def attributes(&block)
      @scrap_attributes_block = block
    end

    def categories(selector, &block)
      @categories_digger = Digger.new(selector, Dsl.walker_builder(&block))
    end

    def items(selector, &block)
      @items_digger = Digger.new(selector, Dsl.walker_builder(&block))
    end

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
