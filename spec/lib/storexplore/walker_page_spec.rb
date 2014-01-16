# -*- encoding: utf-8 -*-
#
# walker_page_spec.rb
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

  describe WalkerPage, slow: true do

    before :each do
      @uri = URI.parse("file://" + File.expand_path(File.join(File.dirname(__FILE__), 'store_walker_page_spec_fixture.html')))
      @page_getter = WalkerPage.open(@uri)
    end

    context "before actually getting the page" do
      it "nothing should throw if the uri is invalid" do
        expect(lambda { WalkerPage.open("http://impossible.file.name") }).not_to raise_error
      end

      it "knows the uri of the page" do
        expect(@page_getter.uri).to eq @uri
      end

      it "has text of the uri" do
        expect(@page_getter.text).to eq @uri.to_s
      end
    end

    context "after actually getting the page" do
      before :each do
        @page = @page_getter.get
      end

      it "delegates uri to the mechanize page" do
        expect(@page.uri).to eq @uri
      end

      it "finds an element by css" do
        element = @page.get_one("#unique")

        expect(element).not_to be_nil
        expect(element.attribute("id").value).to eq "unique"
      end

      it "finds only the first element by css" do
        expect(@page.get_one(".number").text).to eq "0"
      end

      it "throws if it cannot find the element by css" do
        expect(lambda { @page.get_one("#invalid_id") }).to raise_error(WalkerPageError)
      end

      it "finds the first element from a list of css" do
        expect(@page.get_one(".absent, #unique")).to be @page.get_one("#unique")
      end

      it "finds all elements by css" do
        expect(@page.get_all(".number", ', ')).to eq "0, 1"
      end

      it "throws if it cannot find at least one element by css" do
        expect(lambda{ @page.get_all('#invalid_id', ', ') }).to raise_error(WalkerPageError)
      end

      it "finds relative links sorted by uri" do
        links = @page.search_links("a.letter")

        uris = links.map { |link| link.uri.to_s }
        expect(uris).to eq ["a.html", "b.html"]
      end

      it "ignores links to other domains" do
        expect(@page.search_links("#outbound")).to be_empty
      end

      it "ignores duplicate links" do
        expect(@page.search_links("a.twin")).to have(1).link
      end

      it "links to other instances of WalkerPage" do
        expect(@page.search_links("#myself").map { |link| link.get }).to all_ {be_instance_of(WalkerPage)}
      end

      it "knows the text of the links" do
        @page.search_links("#myself").each do |link|
          expect(link.text).to eq "myself"
        end
      end

      it "finds an image by selector" do
        image = @page.get_image(".image")
        expect(image).to be_instance_of(Mechanize::Page::Image)
        expect(image.dom_class).to eq "image"
      end

      it "throws if it cannot find the image by selector" do
        expect(lambda { @page.get_image("#invalid_id") }).to raise_error(WalkerPageError)
      end
    end
  end
end
