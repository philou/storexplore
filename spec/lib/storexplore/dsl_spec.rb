# -*- encoding: utf-8 -*-
#
# dsl_spec.rb
#
# Copyright (C) 2012, 2013, 2014 by Philippe Bourgau. All rights reserved.
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

  describe 'Dsl' do

    def browse
      @walker = Storexplore::Api.browse("http://www.cats-surplus.com")
    end

    after :each do
      Storexplore::Api.undef 'cats'
    end

    context 'a simple store' do
      before :each do
        FakeWeb.register_uri(:get, "http://www.cats-surplus.com", content_type: 'text/html', body: <<-eos)
          <html>
            <body>
              <a href="category1.html" class="category">Cats with fur</a>
              <a href="category2.html" class="category">Naked cats</a>
              <a href="category3.html" class="category">Cats with feathers</a>

              <a href="item1.html" class="item">The first thing we sell</a>
              <a href="item2.html" class="item">The second thing we sell</a>
              <a href="legal.html" class="legal">How we sell it</a>
            </body>
          </html>
        eos
        FakeWeb.register_uri(:get, "http://www.cats-surplus.com/category1.html", content_type: 'text/html', body: <<-eos)
          <html>
            <body>
              <a href="category4.html" class="sub-category">Cats with red fur</a>
              <a href="category5.html" class="sub-category">Cats with green fur</a>

              <a href="item3.html" class="item">The first thing we sell</a>
              <a href="item4.html" class="item">The second thing we sell</a>
              <a href="item5.html" class="item">The second thing we sell</a>
            </body>
          </html>
        eos
        FakeWeb.register_uri(:get, "http://www.cats-surplus.com/category2.html", content_type: 'text/html', body: "")
        FakeWeb.register_uri(:get, "http://www.cats-surplus.com/category3.html", content_type: 'text/html', body: "")
        FakeWeb.register_uri(:get, "http://www.cats-surplus.com/category4.html", content_type: 'text/html', body: "")
        FakeWeb.register_uri(:get, "http://www.cats-surplus.com/category5.html", content_type: 'text/html', body: "")
        FakeWeb.register_uri(:get, "http://www.cats-surplus.com/item1.html", content_type: 'text/html', body: "")
        FakeWeb.register_uri(:get, "http://www.cats-surplus.com/item2.html", content_type: 'text/html', body: "")
        FakeWeb.register_uri(:get, "http://www.cats-surplus.com/item3.html", content_type: 'text/html', body: "")
        FakeWeb.register_uri(:get, "http://www.cats-surplus.com/item4.html", content_type: 'text/html', body: "")
        FakeWeb.register_uri(:get, "http://www.cats-surplus.com/item5.html", content_type: 'text/html', body: "")
        FakeWeb.register_uri(:get, "http://www.cats-surplus.com/legal.html", content_type: 'text/html', body: "")

        Storexplore::Api.define 'cats' do
          items 'a.item' do
            attributes do
              { page: page,
                this_is_the: :item}
            end
          end
          categories 'a.category' do
            categories 'a.sub-category' do
            end
            items 'a.item' do
            end
            attributes do
              { page: page,
                this_is_the: :category}
            end
          end
          attributes do
            { page: page,
              this_is_the: :root}
          end
        end

        browse
      end

      it "root walker has the uri of the home page" do
        expect(@walker.uri).to eq URI("http://www.cats-surplus.com")
      end

      it "sub walkers have the uri of their page" do
        expect(@walker.items.first.uri).to eq URI("http://www.cats-surplus.com/item1.html")
      end

      it "root walker title is the store uri" do
        expect(@walker.title).to eq "http://www.cats-surplus.com"
      end

      it "sub walkers title is the text of its origin link" do
        expect(@walker.items.first.title).to eq "The first thing we sell"
      end

      it "uses a selector to spot sub items" do
        expect(@walker.items).to have_exactly(2).items
      end
      it "uses a selector to spot sub categories" do
        expect(@walker.categories).to have_exactly(3).categories
      end
      it "root walker can have attributes" do
        expect(@walker.attributes[:this_is_the]).to eq :root
        expect(@walker.attributes[:page]).to be_instance_of(WalkerPage)
      end
      it "categories can have sub categories" do
        expect(@walker.categories.first.categories).to have_exactly(2).categories
      end
      it "categories can have sub items" do
        expect(@walker.categories.first.items).to have_exactly(3).items
      end
      it "categories can have attributes" do
        expect(@walker.categories.first.attributes[:this_is_the]).to eq :category
        expect(@walker.categories.first.attributes[:page]).to be_instance_of(WalkerPage)
      end
      it "items can have attributes" do
        expect(@walker.items.first.attributes[:this_is_the]).to eq :item
        expect(@walker.items.first.attributes[:page]).to be_instance_of(WalkerPage)
      end


      context "when troubleshooting" do

        before :each do
          @sub_walker = @walker.categories.first.items.drop(1).first
        end

        it "walkers have an index" do
          expect(@sub_walker.index).to eq 1
        end

        it "has a meaningfull string representation" do
          expect(@sub_walker.to_s).to include(Walker.to_s)
          expect(@sub_walker.to_s).to include("##{@sub_walker.index}")
          expect(@sub_walker.to_s).to include("@#{@sub_walker.uri}")
        end

        it "has a full genealogy" do
          genealogy = @sub_walker.genealogy.split("\n")

          expect(genealogy).to eq [@walker.to_s, @walker.categories.first.to_s, @sub_walker.to_s]
        end
      end

    end

    context 'a redirected home page' do
      before :each do
        FakeWeb.register_uri(:get, "http://www.cats-surplus.com", status: [301, "Moved Permanently"], location: "http://www.cats-surplus.com/index.html")
        FakeWeb.register_uri(:get, "http://www.cats-surplus.com/index.html", content_type: 'text/html', body: "")

        Storexplore::Api.define 'cats' do
        end

        browse
      end

      it "root walker has the uri of finaly page" do
        expect(@walker.uri).to eq URI("http://www.cats-surplus.com/index.html")
      end

      it "root walker title is the store uri" do
        expect(@walker.title).to eq "http://www.cats-surplus.com"
      end
    end

    context 'an empty store' do
      before :each do
        FakeWeb.register_uri(:get, "http://www.cats-surplus.com", content_type: 'text/html', body: "")

        Storexplore::Api.define 'cats' do
        end

        browse
      end

      it "has no items" do
        expect(@walker.items).to be_empty
      end
      it "has no sub categories" do
        expect(@walker.categories).to be_empty
      end
      it "has no sub attributes" do
        expect(@walker.attributes).to be_empty
      end
    end
  end
end
