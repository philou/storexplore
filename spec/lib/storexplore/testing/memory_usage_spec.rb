# -*- encoding: utf-8 -*-
#
# memory_usage_spec.rb
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

      DEFAULT_STORE_NAME = "www.spec-store.com"

      def generate_store(store_name = DEFAULT_STORE_NAME, item_count = 3)
        DummyStore.wipe_out_store(store_name)
        @store_generator = DummyStore.open(store_name)
        @store_generator.generate(3).categories.and(3).categories.and(item_count).items

        new_store(store_name)
      end

      def new_store(store_name = DEFAULT_STORE_NAME)
        Api.browse(DummyStore.uri(store_name))
      end

      it "should use constant memory" do
        FEW = 10
        MANY = 100
        RUNS = 2

        many_inputs_memory = memory_usage_for_items(MANY, RUNS)
        few_inputs_memory = memory_usage_for_items(FEW, RUNS)

        slope = (many_inputs_memory - few_inputs_memory) / (MANY - FEW)

        zero_inputs_memory = few_inputs_memory - FEW * slope

        expect(slope).to be_within(zero_inputs_memory * 0.05).of(0.0)
      end

      def memory_usage_for_items(item_count, runs)
        generate_store(store_name = "www.spec-perf-store.com", item_count)
        data = runs.times.map do
          memory_peak_of do
            walk_store(store_name)
          end
        end
        mean(data)
      end

      def memory_peak_of
        peak_usage = 0
        finished = false

        initial_usage = current_living_objects
        profiler = Thread.new do
          while not finished
            peak_usage = [peak_usage, current_living_objects].max
            sleep(0.01)
          end
        end

        yield

        finished = true
        profiler.join

        peak_usage - initial_usage
      end

      def current_living_objects
        object_counts = ObjectSpace.count_objects
        object_counts[:TOTAL] - object_counts[:FREE]
      end

      def walk_store(store_name)
        new_store(store_name).categories.each do |category|
          register(category)

          category.categories.each do |sub_category|
            register(sub_category)

            sub_category.items.each do |item|
              register(item)
            end
          end
        end
      end

      def register(store_node)
        @title = store_node.title
        @attributes = store_node.attributes

        # No GC is not explicitly done, because:
        #  - large inputs forces it anyway
        #  - it greatly slows tests
        #  - GCing should not change the complexity of the system
        # GC.start
      end

      def mean(data)
        data.reduce(:+)/data.size
      end
    end

  end
end
