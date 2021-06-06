# LiquidDynamicContext

This gem addresses a two common problem when dealing with applications that provide non-technical
users to customize system messages via liquid templates:

- **lack of structure** in how the context is generated, leading to a grab-bag class that does everything
- **poor performance** due to unnecessary computations to provide all variables for the context,
  no matter whether they are really used

## How this gem helps you solve the problem

This gem addresses the problems stated above with the introduction of one simple structuring technique,
that allows you to group common sets of attributes in a so called `BindingResolver` that takes
care of resolving the bindings to their actual values and can determine whether it actually
needs to run in order to successfully render the template.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'liquid_dynamic_context', github: 'timkaechele/liquid_dynamic_context'
```

And then execute:

```bash
$ bundle install
```

## Usage

After the installation of the gem in your application you are ready to rumble and can start
by implementing your first `BindingResolver`

### Your first resolver

For this example we are going to assume that your liquid templates sometimes need to provide
access to the currently logged in user

```ruby
require 'liquid_dynamic_context'

# /app/messages/resolvers/user_binding_resolver.rb
class UserBindingResolver < LiquidDynamicContext::BindingResolver
  # first we have state the bindings that this resolver can provide
  register_binding :email, :username

  protected

  # In this method we do the actual work of resolving the bindings to
  # their respective values
  def resolve(models, context)
    user = User.find(model[:current_user_id])

    context.email = user.email
    context.username = user.username
  end
end
```

### Using the resolver

Now that we have written the first resolver it's time to wire it all up
and use our new resolver to provide a context for our template.

To do so we use the TemplateContext class.

```ruby
require 'liquid_dynamic_context'

# First we need our message template for, this example we define it
# directly in the code, later you may want to dynamically load the
# liquid template e.g. from a database table
liquid_template_string = <<~LIQUID
  Hello {{ username }},

  your newly assigned email address is {{ email }}.
LIQUID

# To provide the context we need to construct a template context
# which knows about all our available resolvers
template_context = LiquidDynamicContext::TemplateContext.new([UserBindingResolver.new])

# Remember that we can pass dynamic attributes to the context to resolve data on
# the fly, in this example we are going to pass in the current_user_id via a hash
models = {
  current_user_id: 4902,
}


# Only the resolvers that are responsible for providing the variables mentioned
# in the template are actually run.
bindings = template_context.resolve(liquid_template_string, models)
# => { "username" => "Steve_Smith", "email" => "steve.smith123@example.com" }
```

Now that we have our bindings for the liquid template we can render our liquid template as usual.

```ruby
template = Liquid::Template.parse(liquid_template_string)
template.render(bindings)
# => "
#  Hello Steve_Smith,
#
#  your newly assigned email address is steve.smith123@example.com.
# "
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/timkaechele/liquid_dynamic_context. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/timkaechele/liquid_dynamic_context/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the LiquidDynamicContext project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/timkaechele/liquid_dynamic_context/blob/master/CODE_OF_CONDUCT.md).
