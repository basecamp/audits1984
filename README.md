![example workflow](https://github.com/basecamp/audits1984/actions/workflows/build.yml/badge.svg)

# Audits1984

A simple auditing tool for [`console1984`](https://github.com/basecamp/console1984).

## Installation

Add it to your `Gemfile`:

```ruby
gem 'audits1984'
```

Create tables to store audits in the database:

```ruby
rails audits1984:install:migrations
rails db:migrate
```

Mount the engine in your `routes.rb`:

```ruby
mount Audits1984::Engine => "/console"
```

### Authenticate auditors

By default, `audits1984` will inherit from the host application's `ApplicationController`. To authenticate auditors, you need to implement a method `#find_current_auditor` in your `ApplicationController`. This method must return a record representing the auditing user. It can be any model but it has to respond to `#name`.

For example, Imagine all the staff in your company can audit console sessions:

```ruby
def find_current_auditor
  Current.user if Current.user&.staff?
end
```

## Configuration

These config options are namespaced in `config.audits1984`:

| Name                  | Description                                                  |
| --------------------- | ------------------------------------------------------------ |
| auditor_class         | The name of the auditor class. By default it's `::User.`     |
| base_controller_class | The host application base class that will be the parent of `audit1984` controllers. By default it's `::ApplicationController`. |

