# -*- encoding: utf-8 -*-
#
# have_unique_matcher.rb
#
# Copyright (c) 2010-2014 by Philippe Bourgau. All rights reserved.
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


# Matcher to verify that a hash's key is unique in a collection of other hashes
# a full class is required to implement the in method
# Use like: expect(hash).to have_unique(:id).in(hashes)
class HaveUnique

  def initialize(key)
    @key = key
  end

  def in(collection)
    @collection = collection
    @index = Hash.new(0)
    collection.each do |item|
      @index[value(item)] += 1
    end
    self
  end

  def matches?(actual)
    @actual = actual
    @index[value(actual)] == 1
  end

  def failure_message_for_should
    "expected #{value_expression(actual)} (=#{value(actual)}) to be unique in #{@collection}"
  end

  def description
    "expected an hash or object with a unique #{@key} in #{@collection}"
  end

  private
  def value(actual)
    if actual.instance_of?(Hash)
      actual[@key]
    else
      actual.send(@key)
    end
  end
  def value_expression(actual)
    if actual.instance_of?(Hash)
      "#{actual}[#{@key}]"
    else
      "#{actual}.#{@key}"
    end
  end
end

def have_unique(key)
  HaveUnique.new(key)
end

