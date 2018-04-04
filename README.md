# FreezeTag

The defacto tagging library for almost every Ruby on Rails project is the excellent [Acts As Taggable On Gem](https://github.com/mbleigh/acts-as-taggable-on) which provides a simple interface for polymorphic tagging of your models. 

This library has some drawbacks, though, namely an object is either tagged as something or not. 

This library will preserve tags in perpetuity, allowing you to observe what objects were previously tagged as and review the tagging events to derive any current tags.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'freeze_tag'
```

And then execute:

    $ bundle

Create the tables:

1. Run the installer: ```rails g freeze_tag:install```
This will create a migration to create your "freeze_tags" table

2. Confirm your implementation.
Since Freeze tags creates a polymorphic association between tags and models, its necessary to confirm the type of primary keys the models in your application use. Open the migration and choose the correct option for you. 

3. Run the migration

#### Add this:
```ruby
include FreezeTag::Taggable
```
to the top of any model you'd like to start tagging.

#### Tagging a record:

A single tag:

```ruby
my_model_instance.freeze_tag(as: "Fancy")
```

Or apply multiple tags:

```ruby
my_model_instance.freeze_tag(as: ["Fancy", "Schmancy"])
```

Or apply multiple tags and expire all ones not in your list:

```ruby
my_model_instance.freeze_tag(as: ["Fancy", "Schmancy"], expire_others: true)
```

#### Accessing tags:

A list of all the current tags

```ruby
my_model_instance.freeze_tag_list
```

Active Record association of all tags
```ruby
my_model_instance.freeze_tags
```

Active Record association of all "active" tags
```ruby
my_model_instance.active_freeze_tags
```

#### Retrieving records that have been tagged:

Currently tagged with (only unexpired)
```ruby
MyModel.freeze_tagged(as: "Fancy")
```

Previously tagged with (only expired)
```ruby
MyModel.previously_freeze_tagged(as: "Fancy")
```

Ever tagged with (expired and unexpired)
```ruby
MyModel.ever_freeze_tagged(as: "Fancy")
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/freeze_tag. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the FreezeTag project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/freeze_tag/blob/master/CODE_OF_CONDUCT.md).
