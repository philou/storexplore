# -*- encoding: utf-8 -*-
#
# api_spec.rb
#
# Copyright (C) 2010, 2011, 2012, 2013 by Philippe Bourgau. All rights reserved.
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

  describe Api do

    before :each do
      Api.register_builder(my_store = "www.my-store.com", builder = double(ApiBuilder.class))
      @url = "http://#{my_store}"
      WalkerPage.stub(:open).with(@url).and_return(walker = double(WalkerPage))
      builder.stub(:new).with(walker).and_return(@store_api = double(ApiBuilder))
    end

    it "select the good store items api builder to browse a store" do
      expect(Api.browse(@url)).to eq @store_api
    end

    it "fails when it does not know how to browse a store" do
      expect(lambda { Api.browse("http://unknown.store.com") }).to raise_error(NotImplementedError)
    end

  end
end
