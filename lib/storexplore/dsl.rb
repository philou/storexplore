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

    def self.define(api_class, digger_class, &block)
      new(api_class, digger_class).tap do |result|
        result.instance_eval(&block)
      end
    end

    def initialize(api_class, digger_class)
      @api_class = api_class
      @digger_class = digger_class
      @scrap_attributes_block = lambda do |_| {} end
      @categories_digger = NullDigger.new
      @items_digger = NullDigger.new
    end

    def attributes(&block)
      @scrap_attributes_block = block
    end

    def categories(selector, &block)
      @categories_digger = @digger_class.new(selector, Dsl.define(@api_class, @digger_class, &block))
    end

    def items(selector, &block)
      @items_digger = @digger_class.new(selector, Dsl.define(@api_class, @digger_class, &block))
    end

    def new(page_getter, father = nil, index = nil)
      @api_class.new(page_getter).tap do |result|
        result.categories_digger = @categories_digger
        result.items_digger = @items_digger
        result.scrap_attributes_block = @scrap_attributes_block
        result.father = father
        result.index = index
      end
    end
  end

end
