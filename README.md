# quick_totals

Totals/count caching for mongoid models using redis

## Dependencies

This gem requires [unique-identifier](https://github.com/patriotphoenix/unique-identifier) in order to operate properly.

## Installation

Add this line to your application's Gemfile:

    gem "quick-totals", github: 'patriotphoenix/quick-totals'

And then execute:

    $ bundle

## Usage

Whenever any model is created or saved that includes the `QuickTotals::Sync` the `:count` method is captured and then stored in a redis cache store accessible via this gem.

### Configuration

To configure this gem, please create a new file inside `config/initializers/quick-totals.rb` and consider the following template: 

```ruby
QuickTotals.configure do |config| 
  config.background_worker = :sidekiq # or nil (only valid option currently is :sidekiq)
  config.prefix = "myapp_" # or nil (only valid option is String)
  config.expire_in = T_1_WEEK # or nil, default T_1_WEEK (only valid option is an Integer representing seconds)
  config.redis_dsn = "redis://localhost:6379/5" # OPTIONAL: default value is "redis://localhost:6379/5"
  config.redis_database = 5 # integer value only, :redis_dsn overrides configuration
  config.hard_failure = false # do not throw exceptions for missing relationship lookup helper method definitions
  config.debug = Rails.env.development? # on if development, off if production or test
end #/def
```

### QuickTotals::Sync

This gem requires **one** method to be defined in _every_ model that includes the Rails Concern `QuickTotals::Sync` called `qt_relationships`. The `qt_lookups` method is optional and should only be used when needed.

```ruby
class Job
  include Mongoid::Document
  include UniqueIdentifier # dependency (see @patriotphoenix/unique-identifier)

  belongs_to :person, optional: true, index: true
end #/class

class Person 
  include Mongoid::Document
  include UniqueIdentifier # dependency (see @patriotphoenix/unique-identifier)
  include QuickTotals::Sync

  def qt_aka
    %w{people}
  end

  def qt_relationships
    %w{jobs nicknames}
  end #/def

  def qt_lookups
    {
      # relationship_name: "new_method_to_invoke_that_will_return_integer"
      nicknames: "qtr_nicknames"
    }
  end #/def

  has_many :jobs

  # Custom QT Methods
  def qtr_nicknames
    (self&.jobs&.count || 0)*12
  end #/def
end #/class

jill = Person.new
jill.save
# => #<Person identifier: "ABC123DEF", _id: BSON::ObjectId('')>
Person.qt
# => 1
accountant = Job.new
accountant.save
# => #<Job identifier: "ABC123DEF", _id: BSON::ObjectId('')>
Job.qt
# => 1
jill.jobs << accountant
jill.save

QuickTotals::Cache.get("people")
# => 1

QuickTotals::Cache.get("persons")
# => 1

QuickTotals::Cache.get("jobs")
# => 1

QuickTotals::Cache.get("<class_name>_<unique-identifier_identifier>_jobs")
# => Integer

QuickTotals::Cache.get("person_ABC123DEF_nicknames")
# => 12

QuickTotals::Cache.get("person_ABC123DEF_jobs")
# => 1

dentist = Job.new
jill.jobs << dentist
jill.save
# => #<Person job_ids: [BSON::ObjectId(''),BSON::ObjectId('')], identifier: "ABC123DEG", _id: BSON::ObjectId('')>

QuickTotals::Cache.get("person_ABC123DEF_jobs")
# => 2

QuickTotals::Cache.get("person_ABC123DEF_nicknames")
# => 24
```

Also, a shortcut for you if you don't like typing long words for the modules/classes here...

```ruby
Qtc.get("people")
# => 1
Qtc.get("person_ABC123DEF_jobs")
# => 2
```

To `get OR set` a value: 

```ruby
Qtc.gos("custom_underscore_label", Integer)
# => Integer
```

## How It Works

### 1. When `QuickTotals::Sync` is included as a Rails Model Concern

A redis key value pair is created where the key is the `#{Qtc.config.prefix}_#{self.class.name.to_s.downcase}` that contains the `self.count` as the value. If an expiration is specified, the key will expire in the amount of seconds you provide. By default, keys will expire in 1 week.

### 2. When `qt_relationships` is defined...

Additional cached key value pairs in redis are added that include each `%w{} [Array]` of extras such as: 

```ruby
slug = Qtc.slug_for_class self.class
@redis.set slug, self.count, Qtc.config.expire_in
self.qt_relationships.each do |r|
  if defined?(self.send(:"#{r}"))
    @redis.set slug, self.send(:"#{r}")
  elsif defined?(self.send(:"qt_#{r}"))
    @redis.set slug, self.send(:"qt_#{r}")
  else
    if Qtc.config.hard_failure
      raise NoMethodError, "#{self.class.to_s} ##{self.identifier} missing :qt_#{r}"
    end #if

    ( defined?(ap) ? ap(self) : puts(self.inspect) ) if Qtc.config.debug
  end #/if-elsif-else
end #/each
```

### 3. When `qt_relationships` is missing...

TBD

### 4. When `qt_lookups` is needed...

TBD

### 5. When `qt_aka` is defined...

TBD




