# -*- encoding: utf-8 -*-
#
# walker_page.rb
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

module Storexplore

  # Wrapper around Mechanize::Page providing strict one liners to select
  # elements.
  class WalkerPage
    extend Forwardable

    # A new lazy proxy on the page.
    # (Internal Usage)
    def self.open(agent, uri)
      Getter.new(agent, uri)
    end

    # Uri of the page
    def_delegator :@mechanize_page, :uri

    # Collection of proxies on pages accessible through the matching links
    # (Internal Usage)
    def search_links(selector)
      uri2links = {}
      search_all_links(selector).each do |link|
        target_uri = link.uri
        uri2links[target_uri.to_s] = link if same_domain? uri, target_uri
      end
      # enforcing deterministicity for testing and debugging
      uri2links.values.sort_by {|link| link.uri.to_s }
    end

    # Unique element matching selector
    # Throws Storexplore::WalkerPageError if there is not exactly one matching
    # element
    def get_one(selector)
      first_or_throw(@mechanize_page.search(selector), "elements", selector)
    end

    # String with the text of all matching elements, separated by separator.
    def get_all(selector, separator)
      elements = @mechanize_page.search(selector)
      throw_if_empty(elements, "elements", selector)

      (elements.map &:text).join(separator)
    end

    # Unique image matching selector
    # Throws Storexplore::WalkerPageError if there is not exactly one matching
    # image
    def get_image(selector)
      first_or_throw(@mechanize_page.images_with(search: selector), "images", selector)
    end

    private

    def initialize(mechanize_page)
      @mechanize_page = mechanize_page
    end

    def same_domain?(source_uri, target_uri)
      target_uri.relative? || (UriUtils.domain(source_uri) == UriUtils.domain(target_uri))
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

      def initialize(agent, uri)
        @agent = agent
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
        WalkerPage.new(@agent.get(@uri))
      end
    end

    class Link
      extend Forwardable

      def initialize(mechanize_link)
        @mechanize_link = mechanize_link
      end

      def_delegator :@mechanize_link, :uri

      def get
        WalkerPage.new(@mechanize_link.click)
      end

      def text
        @mechanize_link.text
      end
    end
  end
end
