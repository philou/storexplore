# -*- encoding: utf-8 -*-
#
# walker.rb
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

module Storexplore

  class Walker

    attr_accessor :categories_digger, :items_digger, :scrap_attributes_block, :father, :index

    def initialize(getter)
      self.categories_digger = NullDigger.new
      self.items_digger = NullDigger.new
      self.scrap_attributes_block = proc do { } end
      @getter = getter
    end

    def title
      @getter.text
    end

    def uri
      page.uri
    end

    def attributes
      @attributes ||= scrap_attributes
    end

    def categories
      categories_digger.sub_walkers(page, self)
    end

    def items
      items_digger.sub_walkers(page, self)
    end

    def to_s
      "#{self.class} ##{index} @#{uri}"
    end

    def genealogy
      genealogy_prefix + to_s
    end

    private
    def page
      @page ||= @getter.get
    end

    def genealogy_prefix
      if father.nil?
        ""
      else
        father.genealogy + "\n"
      end
    end

    def scrap_attributes
      begin
        instance_eval(&@scrap_attributes_block)
      rescue WalkerPageError => e
        raise BrowsingError.new("#{e.message}\n#{genealogy}")
      end
    end
  end
end
