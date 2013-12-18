# -*- encoding: utf-8 -*-
#
# walker_page.rb
#
# Copyright (c) 2010, 2011, 2012, 2013 by Philippe Bourgau. All rights reserved.
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

require 'mechanize'

# monkey patch to avoid a regex uri encoding error when importing
#      incompatible encoding regexp match (ASCII-8BIT regexp with UTF-8 string) (Encoding::CompatibilityError)
#      /home/philou/.rbenv/versions/1.9.3-p194/lib/ruby/1.9.1/webrick/httputils.rb:353:in `gsub'
#      /home/philou/.rbenv/versions/1.9.3-p194/lib/ruby/1.9.1/webrick/httputils.rb:353:in `_escape'
#      /home/philou/.rbenv/versions/1.9.3-p194/lib/ruby/1.9.1/webrick/httputils.rb:363:in `escape'
#      from uri method
require "webrick/httputils"
module WEBrick::HTTPUtils
  def self.escape(s)
    URI.escape(s)
  end
end

module Storexplore

  class WalkerPage

    def self.open(uri)
      Getter.new(uri)
    end

    delegate :uri, :to => :@mechanize_page

    def search_links(selector)
      uri2links = {}
      search_all_links(selector).each do |link|
        target_uri = link.uri
        uri2links[target_uri.to_s] = link if same_domain? uri, target_uri
      end
      # enforcing deterministicity for testing and debugging
      uri2links.values.sort_by {|link| link.uri.to_s }
    end

    def get_one(selector)
      first_or_throw(@mechanize_page.search(selector), "elements", selector)
    end

    def get_all(selector, separator)
      elements = @mechanize_page.search(selector)
      throw_if_empty(elements, "elements", selector)

      (elements.map &:text).join(separator)
    end

    def get_image(selector)
      first_or_throw(@mechanize_page.images_with(search: selector), "images", selector)
    end

    private

    def initialize(mechanize_page)
      @mechanize_page = mechanize_page
    end

    def same_domain?(source_uri, target_uri)
      target_uri.relative? || (source_uri.domain == target_uri.domain)
    end

    def search_all_links(selector)
      @mechanize_page.links_with(search: selector).map { |link| Link.new(link) }
    end

    def first_or_throw(elements, name, selector)
      throw_if_empty(elements, name, selector)
      elements.first
    end

    def throw_if_empty(elements, name, selector)
      if elements.empty?
        raise WalkerPageError.new("Page \"#{uri}\" does not contain any #{name} like \"#{selector}\"")
      end
    end

    class Getter
      attr_reader :uri

      def initialize(uri)
        @uri = uri
      end
      def get
        @page ||= get_page
      end

      def text
        @uri.to_s
      end

      private

      def get_page
        agent = Mechanize.new do |it|
          # NOTE: by default Mechanize has infinite history, and causes memory leaks
          it.history.max_size = 0
        end

        WalkerPage.new(agent.get(@uri))
      end
    end

    class Link
      def initialize(mechanize_link)
        @mechanize_link = mechanize_link
      end

      delegate :uri, :to => :@mechanize_link

      def get
        WalkerPage.new(@mechanize_link.click)
      end

      def text
        @mechanize_link.text
      end
    end
  end
end
