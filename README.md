# Formulary

When writing HTML for forms across different projects, it's often
tedious and error prone to remember the differences between versions of
frameworks such as Bootstrap and Foundation. Formulary addresses this
problem by describing a form using a Ruby class and methods (no
crazy DSLs here!) to take advantage of all the goodness of inheritance
and composability. When you want to update the HTML framework to a new
version, just create a new subclass of View and implement the necessary
methods. Easy peasy!

## Roadmap
  * Serialize/deserialize form structure from database using JSON
  * Bootstrap V1 and V2 views

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'formulary'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install formulary

## Usage

Create a class like so:

```ruby
class TestForm
  include Formulary::Form

  def initialize
    attribute :first_name, :text, presence: true
    attribute :last_name, :text, presence: true
  end

  def action
    "/test"
  end

  def method
    "POST"
  end
end
```

and then tell it to render itself:

```ruby
TestForm.new.render
```

Want to change the HTML output format? Use a different subclass of View
in the renderer method on the form you created. Note: only Bootstrap V3
is currently supported but more to come.

## Contributing

1. Fork it ( https://github.com/dclausen/formulary/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
