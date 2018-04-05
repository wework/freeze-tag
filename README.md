# FreezeTag

Howdy,

The de facto tagging library for almost every Ruby on Rails project has been [Acts As Taggable On Gem](https://github.com/mbleigh/acts-as-taggable-on) which provides a simple interface for polymorphic tagging of your models. 

As excellent and useful as ActsAsTaggable is, this library is attempt to reconcile some shortcomings:

1. Freeze tag allows for a more "stateless" approach to tagging. 

Tags are never deleted, instead they have an "ended_at" column, which can be updated to make them active or inactive.

2. The associations are more simple.

Tags are held in a single table which holds the content of the tag (its name) and the association back to the model instance its attached to.
This has some advantages including simpler querying, joining, etc., but obviously drawbacks as well.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'freeze_tag'
```

And then execute:

    $ bundle

Create the tables:

1. Run the installer:


    $ rails g freeze_tag:install

This will create a migration to create your "freeze_tags" table

2. Confirm your implementation.

Since Freeze tags creates a polymorphic association between tags and models, its necessary to confirm the type of primary keys the models in your application use. Open the migration and choose the correct option for you. 

3. Run the migration


    $ rake db:migrate

4. Add:
```ruby
include FreezeTag::Taggable
```
to the top of any model you'd like to start tagging.

5. Case sensitivity, add:
```ruby
def self.freeze_tag_case_sensitive
  true
end
```
To your model and all tags will be saved as lowercase

#### Tagging a record:

A single tag:

```ruby
my_model_instance.freeze_tag(as: "Fancy")
```

Or apply multiple tags:

```ruby
my_model_instance.freeze_tag(as: ["Fancy", "Schmancy"])
```

Or apply multiple tags and expire all other ones:

```ruby
my_model_instance.freeze_tag(as: ["Fancy", "Schmancy"], expire_others: true)
```

##### Tagging a record, with list:
There may be times you want multiple lists of tags, i.e. users with skills, AND hobbies

All the same methods above work, simple pass a list as an argument.

```ruby
my_model_instance.freeze_tag(as: "Web Design", list: "Skills")
```

#### Accessing tags:

All the current "active" tags as a simple array of strings.

```ruby
my_model_instance.freeze_tag_list
["Happy", "Go", "Lucky"]
```

All the tags as a simple array of strings.

```ruby
my_model_instance.freeze_tag_list(only_active: false)
["Happy", "Go", "Lucky", "Sad"]
```

All the tags, in a list, as a simple array of strings.

```ruby
my_model_instance.freeze_tag_list(list: "Skills")
["Web Design", "Illustration"]
```

Active Record association of all tags

```ruby
my_model_instance.freeze_tags
```

Active Record association of all "active" tags
```ruby
my_model_instance.active_freeze_tags
```

You can change queries to the above to filter by anything.
```ruby
my_model_instance.freeze_tags.where(list: "Skills")
my_model_instance.active_freeze_tags.where(list: "Skills")
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

All the above methods work with a "list" argument as well
```ruby
MyModel.ever_freeze_tagged(as: "Fancy", list: "Skills")
```

#### Accessing the model directly.

```ruby
FreezeTag::Tag
```

Will give you direct access to the freeze tags table in a very standard way. 

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/wework/freeze-tag. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the FreezeTag project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/freeze_tag/blob/master/CODE_OF_CONDUCT.md).
