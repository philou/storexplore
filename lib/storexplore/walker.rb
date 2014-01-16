# -*- encoding: utf-8 -*-
#
# walker.rb
#
# Copyright (c) 2010-2014 by Philippe Bourgau. All rights reserved.
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

  # Objects representing categories and items of the store. These are the instances manipulated when browsing a previously defined store
  class Walker

    # Internal usage
    attr_accessor :categories_digger, :items_digger, :scrap_attributes_block, :father, :index

    def initialize(getter)
      self.categories_digger = NullDigger.new
      self.items_digger = NullDigger.new
      self.scrap_attributes_block = proc do { } end
      @getter = getter
    end

    # Early title, accessible before the page is loaded.
    # * for the store root, this is the store uri
    # * for other pages, it's the caption of the link that brought to this
    def title
      @getter.text
    end

    # Full uri of the page being browsed
    def uri
      page.uri
    end

    # Scraped attributes of this page. Attributes are extracted with the
    # corresponding attributes blocks given in Storexplore::Dsl
    def attributes
      @attributes ||= scrap_attributes
    end

    # Sub categories Storexplore::Walker, as matched by the corresponding
    # categories selector in Storexplore::Dsl
    def categories
      categories_digger.sub_walkers(page, self)
    end

    # Sub items Storexplore::Walker, as matched by the corresponding
    # categories selector in Storexplore::Dsl
    def items
      items_digger.sub_walkers(page, self)
    end

    # String representation with uri and index among siblings.
    def to_s
      "#{self.class} ##{index} @#{uri}"
    end

    # Extended multiline string representation with parents.
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
