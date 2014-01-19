# -*- encoding: utf-8 -*-
#
# dummy_store_api_shared_context.rb
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

module Storexplore
  module Testing

    shared_context "a generated dummy store" do
      def default_store_name
        "www.spec-store.com"
      end

      def generate_store(store_name = default_store_name, item_count = 3)
        DummyStore.wipe_out_store(store_name)
        @store_generator = DummyStore.open(store_name)
        @store_generator.generate(3).categories.and(3).categories.and(item_count).items

        new_store(store_name)
      end

      def new_store(store_name = default_store_name)
        Api.browse(DummyStore.uri(store_name))
      end

    end

  end
end
