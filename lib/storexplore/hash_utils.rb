# -*- coding: utf-8 -*-
#
# hash_utils.rb
#
# Copyright (c) 2012-2014 by Philippe Bourgau. All rights reserved.
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

require "fileutils"

module Storexplore

  class HashUtils

    def self.contains?(hash,other)
      other.all? do |key, value|
        hash.include?(key) && hash[key] == value
      end
    end

    def self.without(hash,keys)
      hash.reject do |key, value|
        keys.include?(key)
      end
    end

    def self.stringify_keys(hash)
      result = {}
      hash.each do |key, value|
        result[key.to_s] = value
      end
      result
    end

    def self.internalize_keys(hash)
      result = {}
      hash.each do |key, value|
        result[key.intern] = value
      end
      result
    end
  end
end
