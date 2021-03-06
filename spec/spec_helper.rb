# -*- encoding: utf-8 -*-
#
# spec_helper.rb
#
# Copyright (c) 2013-2014, 2016 by Philippe Bourgau. All rights reserved.
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

require 'simplecov'
SimpleCov.start

require 'fakeweb'
require 'rspec/collection_matchers'
require 'storexplore'
require 'storexplore/testing'

# Dummy store generation
Storexplore::Testing.config do |config|
  config.dummy_store_generation_dir= File.join(File.dirname(__FILE__), '../tmp')
end

# Clean up fakeweb registry after every test
RSpec.configure do |config|
  config.before :each do
    FakeWeb.allow_net_connect = false
  end
  config.after(:each) do
    FakeWeb.clean_registry
    FakeWeb.allow_net_connect = true
  end
end
