# -*- coding: utf-8 -*-
#
# dummy_store_generator.rb
#
# Copyright (c) 2012, 2013 by Philippe Bourgau. All rights reserved.
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
  module Testing

    class DummyStoreGenerator
      def initialize(pages, count = 1)
        @pages = pages
        @count = count
      end

      def and(count)
        @count = count
        self
      end

      def categories
        dispatch(:category)
      end
      alias_method :category, :categories

      def items
        dispatch(:item).attributes
      end
      alias_method :item, :items

      def attributes(options = {})
        @pages.map do |page|
          attributes = DummyData.attributes(page.name, options)
          page.attributes(HashUtils.without(attributes, [:name]))
        end
      end

      private

      def dispatch(message)
        sub_pages = @pages.map do |page|
          @count.times.map do
            page.send(message, DummyData.name(message))
          end
        end
        DummyStoreGenerator.new(sub_pages.flatten)
      end
    end
  end
end
