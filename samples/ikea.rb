# -*- encoding: utf-8 -*-
#
# ikea.rb
#
# Copyright (c) 2015 by Philippe Bourgau. All rights reserved.
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

# Please note that I don't intend to maintain this scrapper definition :)

require_relative "../lib/storexplore"

Storexplore::Api.define 'ikea.com/us' do

  categories '.departmentLinkBlock a' do
    attributes do
      { :name => page.get_one("#breadCrumbNew .activeLink a").content.strip }
    end

    categories '.departmentLinks a' do
      attributes do
        { :name => page.get_one("#breadCrumbNew .activeLink a").content.strip }
      end

      categories 'a.categoryName' do
        attributes do
          { :name => page.get_one("#breadCrumbNew .activeLink a").content.strip }
        end

        items '.productDetails > a' do
          attributes do
            {
              :name => page.get_one('#name').content.strip,
              :type => page.get_one('#type').content.strip,
              :price => page.get_one('#price1').content.strip.sub('$','').to_f,
              :salesArgs => page.get_one('#salesArg').content.strip,
              :image => page.get_one('#productImg').attributes['src'].content,
              :ikea_id => page.uri.to_s.match("^.*\/([0-9]+)\/?$").captures.first
            }
          end
        end
      end
    end
  end
end


Storexplore::Api.browse('http://www.ikea.com/us/en').categories.take(1).each do |category|

  puts "category: #{category.title.strip}"
  puts "attributes: #{category.attributes}"

  category.categories.take(2).each do |sub_category|

    puts "  category: #{sub_category.title.strip}"
    puts "  attributes: #{sub_category.attributes}"

    sub_category.categories.take(3).each do |sub_sub_category|

      puts "    category: #{sub_sub_category.title.strip}"
      puts "    attributes: #{sub_sub_category.attributes}"

      sub_sub_category.items.take(4).each do |item|

        puts "      item: #{item.title.strip}"
        puts "      attributes: #{item.attributes}"

      end
    end
  end
end
