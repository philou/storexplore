# -*- coding: utf-8 -*-
#
# dummy_data.rb
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

    class DummyData

      def self.name(kind)
        "#{kind.capitalize}-#{new_int}"
      end

      def self.attributes(name, options)
        {
          name: name,
          brand: brand(name),
          image: image(name),
          remote_id: remote_id,
          price: price(name)
        }.merge(options)
      end

      private

      def self.brand(name)
        "#{name} Inc."
      end
      def self.image(name)
        "http://www.photofabric.com/#{name}"
      end
      def self.remote_id
        new_int.to_s
      end
      def self.price(name)
        hash = name.hash.abs
        digits = Math.log(hash, 10).round
        (hash/10.0**(digits-2)).round(2)
      end

      def self.new_int
        @last_int ||= 0
        result = @last_int
        @last_int = @last_int + 1
        result
      end
    end

  end
end
