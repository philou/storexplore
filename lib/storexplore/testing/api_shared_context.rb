# -*- encoding: utf-8 -*-
#
# api_shared_context.rb
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
  module Testing

    shared_context "a scrapped store" do

      before :all do
        @range = 0..1

        expect(self).to(respond_to(:generate_store), "You should implement generate_store to include the scrapped store shared context")

        self.store = generate_store
        explore_store
      end

      def explore_store
        @sample_categories = dig([store], :categories)
        @all_sample_categories, @sample_items = dig_deep(@sample_categories)
        @valid_sample_items = valid_items(@sample_items)
        @sample_items_attributes = (valid_sample_items.map &:attributes).uniq
        @parseable_categories_attributes = all_sample_categories.map do |category|
          category.attributes rescue {}
        end
      end

      attr_accessor :store, :sample_categories, :all_sample_categories, :sample_items, :valid_sample_items, :sample_items_attributes, :parseable_categories_attributes

      def dig(categories, message)
        categories.map { |cat| cat.send(message).to_a[@range] }.flatten
      end

      def dig_deep(categories)
        all_categories = [categories]

        while (items = dig(categories, :items)).empty?
          categories = dig(categories, :categories)
          all_categories << categories
        end

        [all_categories.flatten, items]
      end

      def valid_items(items)
        result = []
        sample_items.each do |item|
          begin
            item.attributes
            result.push(item)
          rescue BrowsingError => e
            Testing.logger.debug e.message
          end
        end
        result
      end

      def logger
        Testing.config.logger
      end

    end

  end
end
