# -*- encoding: utf-8 -*-
#
# digger_spec.rb
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

  describe Digger do

    before :each do
      @digger = Digger.new(@selector = "a.items", @factory = double("Sub walker factory"))
      @page = double(WalkerPage)
      @page.stub(:search_links).with(@selector).and_return(@links = [double("Link"),double("Link")])
    end

    it "creates sub walkers for each link it finds" do
      @links.each do |link|
        expect(@factory).to receive(:new).with(link, anything, anything)
      end

      @digger.sub_walkers(@page, nil).to_a
    end

    it "for debugging purpose, provides father walker and link index to sub walkers" do
      father = double("Father walker")

      @links.each_with_index do |link, index|
        expect(@factory).to receive(:new).with(link, father, index)
      end

      @digger.sub_walkers(@page, father).to_a
    end

  end
end
