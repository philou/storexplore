# -*- coding: utf-8 -*-
#
# dummy_store_generator.rb
#
# Copyright (c) 2012-2014 by Philippe Bourgau. All rights reserved.
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

    # Dummy store generation one liner. Forwards chains of method calls to a
    # collections of Storexplore::Testing::DummyStore instances.
    class DummyStoreGenerator

      # * pages : collection of Storexplore::Testing::DummyStore instances to
      #   which calls will be forwarded
      # * count : number of children (categories or items) that will be added
      #   with every generation call
      def initialize(pages, count = 1)
        @pages = pages
        @count = count
      end

      # Changes the number of generated children
      def and(count)
        @count = count
        self
      end

      # Generates @count categories on all @pages
      def categories
        dispatch(:category)
      end
      # See #categories
      alias_method :category, :categories

      # Generates @count items with attributes on all @pages
      def items
        dispatch(:item).attributes
      end
      # See #items
      alias_method :item, :items

      # generates attributes for all @pages. Explicit attributes can be
      # specified
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
