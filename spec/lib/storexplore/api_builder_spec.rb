# -*- encoding: utf-8 -*-
#
# api_builder_spec.rb
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

require "spec_helper"

module Storexplore

  describe ApiBuilder do

    before :each do
      @url = "http://www.mega-store.com"
      @api = double("Store api").as_null_object
      @api_class = double("Store api class")
      @api_class.stub(:new).with(@url).and_return(@api)

      @selector = "a.child"
      @digger = double("Digger")
      @digger_class = double("Digger class")
    end

    context "using define method" do
      it "creates new store api" do
        @builder = ApiBuilder.define(@api_class, Digger) { }

        expect(@builder.new(@url)).to eq @api
      end

      it "initializes nested definition through its block" do
        ApiBuilder.stub(:new).and_return(builder = double(ApiBuilder))

        expect(builder).to receive(:complex_builder_initialization)

        ApiBuilder.define(@api_class, Digger) do
          complex_builder_initialization
        end
      end
    end

    context "when nesting definitions" do

      before :each do
        @builder = ApiBuilder.new(@api_class, @digger_class)
      end

      after :each do
        @builder.new(@url)
      end

      [:categories, :items].each do |sub_definition|

        before :each do
          ApiBuilder.stub(:new).and_return(@sub_builder = double(ApiBuilder))
          @digger_class.stub(:new).with(@selector, @sub_builder).and_return(@digger)
        end

        it "tells the store api how to find sub #{sub_definition}" do
          expect(@api).to receive("#{sub_definition}_digger=").with(@digger)

          @builder.send(sub_definition, @selector) do end
        end

        it "initialises the sub #{sub_definition} builder" do
          expect(@sub_builder).to receive(:sub_builder_initialization)

          @builder.send(sub_definition, @selector) do
            sub_builder_initialization
          end
        end
      end

      it "tells the store api how to parse attributes" do
        scrap_attributes_block = Proc.new { |page| @scrap_attributes_block_is_unique = true }

        expect(@api).to receive(:scrap_attributes_block=).with(scrap_attributes_block)

        @builder.attributes(&scrap_attributes_block)
      end

    end
  end
end
