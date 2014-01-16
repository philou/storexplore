# -*- coding: utf-8 -*-
#
# dummy_store.rb
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
  module Testing

    # Read / Write model for a disk html store page. Every modification is
    # directly saved to the disk, nothing remains in memory.
    # All stores are generated in a specific subdirectory of
    # Storexplore::Testing::Configuration #dummy_store_generation_dir /
    # Storexplore::Testing::DummyStoreConstants #NAME
    class DummyStore

      # Initializes or opens a dummy store in the 'store_name' subdirectory
      def self.open(store_name)
        new(root_path(store_name), store_name)
      end

      # file:// uri for the place where the 'store_name' store would be
      # created
      def self.uri(store_name)
        "file://#{root_path(store_name)}"
      end

      # Deletes from disk all generated dummy stores
      def self.wipe_out
        FileUtils.rm_rf(root_dir)
      end
      # Deletes from disk the 'store_name' dummy store
      def self.wipe_out_store(store_name)
        FileUtils.rm_rf(root_path(store_name))
      end

      # file:// uri of the page
      def uri
        "file://#{@path}"
      end

      # Name of the page
      attr_reader :name

      # Child Storexplore::Testing::DummyStore instances for existing sub
      # categories
      def categories
        _name, categories, _items, _attributes = read
        categories.map do |category_name|
          DummyStore.new("#{absolute_category_dir(category_name)}/index.html", category_name)
        end
      end
      # Child category Storexplore::Testing::DummyStore instance with the
      # specified name. Creates it if it does not yet exist
      def category(category_name)
        short_category_name = short_name(category_name)
        add([short_category_name], [], {})
        DummyStore.new("#{absolute_category_dir(short_category_name)}/index.html", category_name)
      end
      # Deletes the specified child category.
      def remove_category(category_name)
        short_category_name = short_name(category_name)
        remove([short_category_name], [], [])
        FileUtils.rm_rf(absolute_category_dir(short_category_name))
      end

      # Child Storexplore::Testing::DummyStore instances for existing sub
      # items
      def items
        _name, _categories, items, _attributes = read
        items.map do |item_name|
          DummyStore.new(absolute_item_file(item_name), item_name)
        end
      end
      # Child item Storexplore::Testing::DummyStore instance with the
      # specified name. Creates it if it does not yet exist
      def item(item_name)
        short_item_name = short_name(item_name)
        add([], [short_item_name], {})
        DummyStore.new(absolute_item_file(short_item_name), item_name)
      end
      # Deletes the specified child item.
      def remove_item(item_name)
        short_item_name = short_name(item_name)
        remove([], [short_item_name], [])
        FileUtils.rm_rf(absolute_item_file(short_item_name))
      end

      # Hash of the current attributes
      def attributes(*args)
        return add_attributes(args[0]) if args.size == 1

        _name, _categories, _items, attributes = read
        HashUtils.internalize_keys(attributes)
      end
      # Adds the specified attributes
      def add_attributes(values)
        add([], [], HashUtils.stringify_keys(values))
      end
      # Removes the specified attriutes
      def remove_attributes(*attribute_names)
        remove([], [], ArrayUtils.stringify(attribute_names))
      end

      # New Storexplore::Testing::DummyStoreGenerator instance for this
      def generate(count = 1)
        DummyStoreGenerator.new([self], count)
      end

      private

      def self.root_dir
        File.join(Testing.config.dummy_store_generation_dir, DummyStoreConstants::NAME)
      end

      def self.root_path(store_name)
        "#{root_dir}/#{store_name}/index.html"
      end

      def initialize(path, name)
        @path = path
        @name = name
        if !File.exists?(path)
          write(name, [], [], {})
        end
      end

      def short_name(full_name)
        full_name[0..20]
      end

      def absolute_category_dir(category_name)
        "#{File.dirname(@path)}/#{relative_category_dir(category_name)}"
      end
      def relative_category_dir(category_name)
        category_name
      end

      def absolute_item_file(item_name)
        "#{File.dirname(@path)}/#{relative_item_file(item_name)}"
      end
      def relative_item_file(item_name)
        "#{item_name}.html"
      end

      def add(extra_categories, extra_items, extra_attributes)
        name, categories, items, attributes = read

        if !ArrayUtils.contains?(categories, extra_categories) || !ArrayUtils.contains?(items, extra_items) || !HashUtils.contains?(attributes,extra_attributes)
          write(name, categories + extra_categories, items + extra_items, attributes.merge(extra_attributes))
        end
      end
      def remove(wrong_categories, wrong_items, wrong_attributes)
        name, categories, items, attributes = read
        write(name, categories - wrong_categories, items - wrong_items, HashUtils.without(attributes,wrong_attributes))
      end

      def write(name, categories, items, attributes)
        FileUtils.mkdir_p(File.dirname(@path))
        IO.write(@path, content(name, categories, items, attributes))
      end

      def content(name, categories, items, attributes)
        (["<!DOCTYPE html>",
          "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" /></head>",
          "<body><h1>#{name}</h1><div id=\"categories\"><h2>Categories</h2><ul>"] +
         categories.map {|cat|  "<li><a class=\"category\" href=\"#{relative_category_dir(cat)}/index.html\">#{cat}</a></li>" } +
         ['</ul></div><div id="items"><h2>Items</h2><ul>']+
         items.map      {|item| "<li><a class=\"item\" href=\"#{relative_item_file(item)}\">#{item}</a></li>" } +
         ['</ul></div><div id="attributes"><h2>Attributes</h2><ul>']+
         attributes.map {|key, value| "<li><span id=\"#{key}\">#{value}</span></li>" } +
         ["</ul></div></body></html>"]).join("\n")
      end

      def read
        parse(IO.readlines(@path))
      end

      def parse(lines)
        name = ""
        categories = []
        items = []
        attributes = {}
        lines.each do |line|
          name_match = /<h1>([^<]+)<\/h1>/.match(line)
          sub_match = /<li><a class=\"([^\"]+)\" href=\"[^\"]+.html\">([^<]+)<\/a><\/li>/.match(line)
          attr_match = /<li><span id=\"([^\"]+)\">([^<]+)<\/span><\/li>/.match(line)

          if !!name_match
            name = name_match[1]
          elsif !!sub_match
            case sub_match[1]
            when "category" then categories << sub_match[2]
            when "item" then items << sub_match[2]
            end
          elsif !!attr_match
            attributes[attr_match[1]] = attr_match[2]
          end
        end
        [name, categories, items, attributes]
      end
    end
  end
end
