# sequel-mysql_json [![Build Status](https://travis-ci.org/munshkr/sequel-mysql_json.svg?branch=master)](https://travis-ci.org/munshkr/sequel-mysql_json)

Sequel extension and plugin that adds better support for MySQL JSON columns and
functions (added first on MySQL 5.7.8).

### `mysql_json` plugin

`mysql_json` detects MySQL json columns on models and automatically adds column
accessors that deserializes JSON values. Uses Sequel's builtin Serialization
plugin for this purpose.

### `mysql_json_ops` extension

`mysql_json_ops` extension adds support to Sequel's DSL to make it easier to
call MySQL JSON functions and operators.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sequel-mysql_json'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sequel-mysql_json


## Usage

To enable plugin for all models, call `Sequel::Model.plugin :mysql_json`.
To enable extension, call `Sequel.extension :mysql_json_ops`.

For example, suppose you have a model with a json column `metadata`, like this:

```ruby
class Thing < Sequel::Model
  set_schema do
    primary_key :id
    json :metadata
  end
end

Thing.create_table!
```

Because plugin uses the
[Serialization](http://sequel.jeremyevans.net/rdoc-plugins/classes/Sequel/Plugins/Serialization.html)
plugin, we can pass serializable Ruby objects, like a hash when setting the
`metadata` column accessor.

```ruby
Thing.create(metadata: { foo: 1, bar: 2 })
# => #<Thing @values={:id=>1, :metadata=>"{\"bar\": 2, \"foo\": 1}"}>

Thing.first.metadata['foo']
# => 1
```

To construct queries using JSON related functions, first build a `JSONOp`
object:

```ruby
Sequel.mysql_json_op(:metadata)
# => #<Sequel::Mysql::JSONOp @value=>:metadata>

Thing.select_map(Sequel.mysql_json_op(:metadata).extract('.foo'))
# SELECT JSON_EXTRACT(`metadata`, '$.foo') AS `v` FROM `things`
# => ["1"]
```

As you can see the `$` prefix is appended automatically to the path selector.

If you are using Sequel `core_extension` or `core_refinements`, you can also:

```ruby
Thing.select_map(:metadata.mysql_json_op.extract('.foo'))
# SELECT JSON_EXTRACT(`metadata`, '$.foo') AS `v` FROM `things`
# => ["1"]
```

`#[]` and `#get` are aliases of `#extract`. Also, when providing a Symbol,
selector is converted to a path that extracts a field from a JSON object.
Likewise, when using an Integer, path selector extracts a value from a JSON
array:

```ruby
Thing.select_map(:metadata.mysql_json_op[:foo])
# SELECT JSON_EXTRACT(`metadata`, '$.foo') AS `v` FROM `things`
# => ["1"]

Thing.select_map(:metadata.mysql_json_op[42])
# SELECT JSON_EXTRACT(`metadata`, '$[1]') AS `v` FROM `things`
# => [nil]
```

JSONOp will merge nested `#extract` calls into a single one:

```ruby
Thing.create(metadata: 5.times.map { |id| { id: id, value: "id#{id}" } })

Thing.select_map(:metadata.mysql_json_op['[*]'][:value])
# SELECT JSON_EXTRACT(`metadata`, '$[*].value') AS `v` FROM `posts`
# => ["id0", "id1", "id2", "id3", "id4"]
```

## Development

After checking out the repo, install `bundler` with `gem install bundler`, and
run `bundle install` to install dependencies. Then, run `rake test` to run the
tests.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).


## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/munshkr/sequel-mysql_json.


## License

MIT License

Copyright (c) 2016 Damián Silvani

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
