# Sequel::MysqlJson

Sequel extension and plugin that adds better support for MySQL JSON columns and
functions (added first on MySQL 5.7.8).

### `mysql_json` plugin

`mysql_json` detects MySQL json columns on models and automatically adds column
accessors that deserializes JSON values. Uses Sequel's builtin Serialization
plugin for this purpose.

### `mysql_json_op` extension

`mysql_json_op` extension adds support to Sequel's DSL to make it easier to
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

TODO: Write usage instructions here


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake test` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

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
