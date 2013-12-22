# -*- encoding: utf-8 -*-
#
# uri.rb
#
# Copyright (c) 2011, 2013 by Philippe Bourgau. All rights reserved.
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

  # Extra URI utilities
  class UriUtils

    # extracts the domain from an uri
    def self.domain(uri)

      return "localhost" if uri.scheme == "file"
      return nil if uri.host.nil?
      return nil if uri.host =~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/

      /([^\.]+\.[^\.]+)$/.match(uri.host)[0]
    end
  end
end
