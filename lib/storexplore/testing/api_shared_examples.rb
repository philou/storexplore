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

    shared_examples "an API" do

      it "should have many item categories" do
        # TODO remove .first(3) once rspec handles lazy enums
        expect(store.categories.first(3)).to have_at_least(3).items
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
end
