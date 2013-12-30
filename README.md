# Storexplore

A declarative scrapping DSL that lets one define directory like apis to an online store

## Installation

Add this line to your application's Gemfile:

    gem 'storexplore'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install storexplore

## Usage

The library builds hierarchical APIs on online stores. Stores are typicaly
organized in the following way :

    Store > Categories > ... > Sub Categories > Items

The store is like a root category. Any category, at any depth level can have
both children categories and items. Items cannot have children of any kind.
Both categories and items can have attributes.

All searching of children and attributes is done through mechanize/nokogiri
selectors (css or xpath).

Here is a sample store api declaration :

```ruby
Storexplore::define_api 'dummy-store.com' do

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
```

This build a hierarchical API on the 'dummy-store.com' online store. This
registers a new api definition that will be used to browse any store which
uri contains 'dummy-store.com'.

Now here is how this API can be accessed to pretty print all its content:

```ruby
Api.browse('http://www.dummy-store.com').categories.each do |category|

  puts "category: #{category.title}"
  puts "attributes: #{category.attributes}"

  category.categories.each do |sub_category|

    puts "  category: #{sub_category.title}"
    puts "  attributes: #{sub_category.attributes}"

    sub_category.items.each do |item|

      puts "    item: #{item.title}"
      puts "    attributes: #{item.attributes}"

    end
  end
end
```

### Testing

Storexplore ships with some dummy store generation utilities. Dummy stores can
be generated to the file system using the Storexplore::Testing::DummyStore and
Storexplore::Testing::DummyStoreGenerator classes. This is particularly useful
while testing.

To use it, add the following, to your spec_helper.rb for example :

```ruby
require 'storexplore/testing'

Storexplore::Testing.config do |config|
  config.dummy_store_generation_dir= File.join(Rails.root, '../tmp')
end
```

It is then possible to generate a store with the following :

```ruby
DummyStore.wipe_out_store(store_name)
@store_generator = DummyStore.open(store_name)
@store_generator.generate(3).categories.and(3).categories.and(item_count).items
```

It is also possibe to add elements with explicit values :

```ruby
@store_generator.
  category(cat_name = "extra long category name").
  category(sub_cat_name = "extra long sub category name").
  item(item_name = "super extra long item name").generate().
    attributes(price: 12.3)
```

Storexplore provides an api definition for dummy stores in
'storexplore/testing/dummy_store_api'. It can be required independently if
needed.

### RSpec shared examples

Storexplore also ships with an rspec shared examples macro. It can be used for
any custom store API definition.

```ruby
require 'storexplore/testing'

describe "MyStoreApi" do
  include Storexplore::Testing::ApiSpecMacros

  it_should_behave_like_any_store_items_api

  ...

end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
