# -*- encoding: utf-8 -*-
#
# digger.rb
#
# Copyright (c) 2010, 2011, 2012, 2013, 2014 by Philippe Bourgau. All rights reserved.
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
  class Digger
    def initialize(selector, sub_walker_builder)
      @selector = selector
      @sub_walker_builder = sub_walker_builder
    end

    def sub_walkers(page, father)
      page.search_links(@selector).each_with_index.to_a.lazy.map do |link, i|
        @sub_walker_builder.new_walker(link, father, i)
      end
    end
  end
end
