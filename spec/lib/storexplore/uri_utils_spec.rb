# -*- encoding: utf-8 -*-
#
# uri_utils.rb
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

  describe "UriUtils" do

    it "should extract the domain of a domain only url" do
      expect(UriUtils.domain(URI.parse("http://mes-courses.fr"))).to eq "mes-courses.fr"
    end
    it "should extract the domain of an url with a subdomain" do
      expect(UriUtils.domain(URI.parse("http://www.yahoo.fr"))).to eq "yahoo.fr"
    end
    it "should extract the domain of an url with a directories" do
      expect(UriUtils.domain(URI.parse("http://www.amazon.com/books/science-fiction"))).to eq "amazon.com"
    end
    it "should get localhost domain for a file uri" do
      expect(UriUtils.domain(URI.parse("file:///home/user/documents/secret.txt"))).to eq "localhost"
    end

    it "should get a nil domain for a local path" do
      expect(UriUtils.domain(URI.parse("root/folder/and/file.txt"))).to be_nil
    end
    it "should get a nil domain for a mailto uri" do
      expect(UriUtils.domain(URI.parse("mailto:philou@mailinator.org"))).to be_nil
    end
    it "should get a nil domain for an url with an ip address" do
      expect(UriUtils.domain(URI.parse("http://192.168.0.101/index.html"))).to be_nil
    end
  end
end
