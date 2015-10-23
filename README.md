[![Build Status](https://travis-ci.org/philou/storexplore.svg?branch=master)](https://travis-ci.org/philou/storexplore) [![Test Coverage](https://codeclimate.com/github/philou/storexplore/badges/coverage.svg)](https://codeclimate.com/github/philou/storexplore) [![Code Climate](https://codeclimate.com/github/philou/storexplore/badges/gpa.svg)](https://codeclimate.com/github/philou/storexplore)

# Storexplore

Transform online stores into APIs !

## Why
Once upon a time, I wanted to create online groceries with great user experience ! That's how I started [mes-courses.fr](https://github.com/philou/mes-courses). Unfortunately, most online groceries don't have APIs, so I resorted to scrapping. Scrapping comes with its (long) list of problems aswell !

* Scrapping code is a mess
* The scrapped html can change at any time
* Scrappers are difficult to test

Refactoring by refactoring, I extracted this libary which defines scrappers for any online store in a straightforward way (check [auchandirect-scrAPI](https://github.com/philou/auchandirect-scrAPI) for my real world usage). A scrapper definition consists of :

* a scrapper definition file
* the selectors for the links
* the selectors for the content you want to capture

As a result of using storexplore for mes-courses, the scrapping code was split between the storexplore gem and my special scrapper definition :

* This made the whole overall code cleaner
* I could write simple and reliable tests
* Most importantly, I could easily keep pace with the changes in the online store html

## Installation

Add this line to your application's Gemfile:

    gem 'storexplore'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install storexplore

In order to be able to enumerate all items of a store in constant memory,
Storexplore requires ruby 2.0 for its lazy enumerators.

## Usage

Online stores are typicaly organized as hierarchies. For example [Ikea (US)](http://www.ikea.com/us/en) is organized as follows :

    Ikea
    |-> Living room
    |   |-> Sofas & armchairs
    |   |   |-> Fabric Sofas
    |   |   |   |-> Norsborg Sofa
    |   |   |   |-> Norborg Loveseat
    |   |   |   |-> ...
    |   |   |   |-> Pöang Footstool cushion
    |   |   |-> Leather Sofas
    |   |   |-> ...
    |   |   |-> Armchairs
    |   |-> TV & media funiture
    |   |-> ...
    |   |-> Living room textiles & rugs
    |-> Bedroom
    |-> ...
    |-> Dining

Storexplore builds hierarchical APIs on the following pattern :

    Store
    |-> Category 1
    |   |-> Sub Category 1
    |   |   |-> Item 1
    |   |   |-> ...
    |   |   |-> Item n
    |   |-> Sub Category 2
    |   |-> ...
    |   |-> Sub Category n
    |-> Category 2
    |-> ...
    |-> Category n

The store is like a root category. Any level of depth is allowed. Any category, at any depth level can have both children categories and items. Items cannot have children of any kind. Both categories and items can have attributes.

All searching of children and attributes is done through mechanize/nokogiri selectors (css or xpath).

Here is a sample store api declaration for [Ikea](http://www.ikea.com/us/en) again:

```ruby
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
```

This defines a hierarchical API on the IKEA store that will be used to browse any store which
uri contains 'ikea.com/us'.

Now here is how this API can be accessed to pretty print all its content:

```ruby
Storexplore::Api.browse('http://www.ikea.com/us/en').categories.each do |category|

  puts "category: #{category.title.strip}"
  puts "attributes: #{category.attributes}"

  category.categories.each do |sub_category|

    puts "  category: #{sub_category.title.strip}"
    puts "  attributes: #{sub_category.attributes}"

    sub_category.categories.each do |sub_sub_category|

      puts "    category: #{sub_sub_category.title.strip}"
      puts "    attributes: #{sub_sub_category.attributes}"

      sub_sub_category.items.each do |item|

        puts "      item: #{item.title.strip}"
        puts "      attributes: #{item.attributes}"

      end
    end
  end
end
```

(This sample can be found in samples/ikea.rb)

## Testing

NOTE : please keep in mind that these testing utilities have been extracted from my first real use case ([auchandirect-scrAPI](https://github.com/philou/auchandirect-scrAPI)) and might still rely on assumptions coming from there. Any help cleaning this up is welcome.

### Testing Code Relying On A Scrapped Thirdparty

This can be quite a challenge. Storeexplore can help you with that :

* it provides a customizable offline (disk) dummy store generator
* it provides an API for this store
* As long as your dummy store provides the same attributes than the real store, you can use it in your tests

Dummy stores can be generated to the file system using the Storexplore::Testing::DummyStore and Storexplore::Testing::DummyStoreGenerator classes.

To use it, add the following to your spec_helper.rb for example :

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

You can add custom elements with explicit values :

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

### Testing Your Own Scrapper

Storexplore also ships with an rspec shared examples macro. It guarantees basic scrapper well behaviour such as the presence of many categories, of item names and prices

```ruby
require 'storexplore/testing'

describe "MyStoreApi" do
  include Storexplore::Testing::ApiSpecMacros

  it_should_behave_like_any_store_items_api

  ...

end
```

### Summary Testing Files To Require

* To only get the api definition for a previously generated dummy store, it is enough to require 'storexplore/testing/dummy_store_api'
* To be able to generate and scrap dummy stores, it's needed to require 'storexplore/testing/dummy_store_generator'
* To do all the previous and to use rspec utilities, require 'storexplore/testing'

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
