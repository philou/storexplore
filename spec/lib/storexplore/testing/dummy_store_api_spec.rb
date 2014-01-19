# -*- encoding: utf-8 -*-
#
# dummy_store_api_spec.rb
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

require 'spec_helper'
require_relative 'dummy_store_api_shared_context'

module Storexplore
  module Testing

    describe "DummyStoreApi", slow: true do
      include_context "a generated dummy store"
      include_context "a scrapped store"
      it_should_behave_like "an API"

      it "should not truncate long item names" do
        @store_generator.
          category(cat_name = "extra long category name").
          category(sub_cat_name = "extra long sub category name").
          item(item_name = "super extra long item name").generate().attributes

        category = new_store.categories.find {|cat| cat_name.start_with?(cat.title)}
        expect(category.attributes[:name]).to eq cat_name

        sub_category = category.categories.find {|sub_cat| sub_cat_name.start_with?(sub_cat.title)}
        expect(sub_category.attributes[:name]).to eq sub_cat_name

        item = sub_category.items.find {|it| item_name.start_with?(it.title)}
        expect(item.attributes[:name]).to eq item_name
      end

    end

  end
end
