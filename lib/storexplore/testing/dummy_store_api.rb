# -*- coding: utf-8 -*-
#
# dummy_store_api.rb
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

module Storexplore
  module Testing

    Storexplore::define_api DummyStore::NAME do

      categories 'a.category' do
        attributes do
          { :name => page.get_one("h1").content }
        end

        categories 'a.category' do
          attributes do
            { :name => page.get_one("h1").content }
          end

          items 'a.item' do
            attributes do
              {
                :name => page.get_one('h1').content,
                :brand => page.get_one('#brand').content,
                :price => page.get_one('#price').content.to_f,
                :image => page.get_one('#image').content,
                :remote_id => page.get_one('#remote_id').content
              }
            end
          end
        end
      end
    end
  end
end
