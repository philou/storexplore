# -*- encoding: utf-8 -*-
#
# api_shared_examples.rb
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

    module ApiSpecMacros

      def self.included(base)
        base.send :extend, ClassMethods
      end

      module ClassMethods

        def it_should_behave_like_any_store_items_api

          before :all do
            @range = 0..1

            generate_store
            explore_store
          end

          it "should have many item categories" do
            # TODO remove .first(3) once rspec handles lazy enums
            expect(@store.categories.first(3)).to have_at_least(3).items
          end

          it "should have many items" do
            expect(sample_items).to have_at_least(3).items
          end

          it "should have item categories with different names" do
            categories_attributes = sample_categories.map { |cat| cat.attributes }
            expect(categories_attributes).to mostly have_unique(:name).in(categories_attributes)
          end

          it "should have items with different names" do
            expect(sample_items_attributes).to mostly have_unique(:name).in(sample_items_attributes)
          end

          it "should have parseable item category attributes" do
            expect(parseable_categories_attributes).to mostly have_key(:name)
          end

          it "should have some valid item attributes" do
            expect(sample_items_attributes).not_to be_empty
          end

          it "should have items with a price" do
            expect(sample_items_attributes).to all_ { have_key(:price) }
          end

          it "should mostly have items with an image" do
            expect(sample_items_attributes).to mostly have_key(:image)
          end

          it "should mostly have items with a brand" do
            expect(sample_items_attributes).to mostly have_key(:brand)
          end

          it "should have items with unique remote id" do
            expect(sample_items_attributes).to all_ { have_unique(:remote_id).in(sample_items_attributes) }
          end

          it "should have items with unique uris" do
            expect(valid_sample_items).to mostly have_unique(:uri).in(valid_sample_items)
          end
        end
      end

      def generate_store
        # by default, the store already exists
      end

      def explore_store
        @sample_categories = dig([@store], :categories)
        @all_sample_categories, @sample_items = dig_deep(@sample_categories)
        @valid_sample_items = valid_items(@sample_items)
        @sample_items_attributes = (valid_sample_items.map &:attributes).uniq
        @parseable_categories_attributes = all_sample_categories.map do |category|
          category.attributes rescue {}
        end
      end

      attr_accessor :sample_categories, :all_sample_categories, :sample_items, :valid_sample_items, :sample_items_attributes, :parseable_categories_attributes

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
