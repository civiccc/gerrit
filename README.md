# Gerrit CLI

[![Gem Version](https://badge.fury.io/rb/gerrit.svg)](http://badge.fury.io/rb/gerrit)

`gerrit` is Ruby-based tool to make the code review process of working with
[Gerrit](https://code.google.com/p/gerrit/) quicker.

* [Requirements](#requirements)
* [Installation](#installation)
* [Configuration](#configuration)
* [License](#license)

## Requirements

* Ruby 2.0.0+

## Installation

```bash
gem install gerrit
```

Run `gerrit setup` from the command line to perform the initial setup. `gerrit`
will automatically detect if you have a configuration (`.gerrit.yaml`) in the
current working directory or any of its ancestors, taking the first one it
finds.

## Configuration

`gerrit` is configured by creating a `.gerrit.yaml` in your home directory.
You can also create separate `.gerrit.yaml` files in each of your repositories,
but this shouldn't be necessary unless you are trying to interact with
different Gerrit users or hosts for each of your repositories.

Here's a commented example configuration that should work for most
organizations.

```yaml
user: john.doe            # Username of your Gerrit user
host: gerrit.example.com  # Host where your Gerrit instance is located
port: 29418               # Port the custom Gerrit SSH daemon is listening on

# Remotes to add when running `gerrit setup`. Note that %{...} values are
# interpolated using the values above--you do not need to fill them in yourself.
remotes:
  # When updating your local repo, all commits are pulled down from this remote.
  # This is also used when force-pushing commits or seeding a Gerrit repo
  # initially (though you'll need to give the respective user force-push permissions)
  origin:
    url: ssh://%{user}@%{host}:%{port}/%{project}.git
    fetch: +refs/heads/*:refs/remotes/origin/*
    push: HEAD:refs/heads/master
  # Used for pushing commits out for review.
  # While you should use `gerrit push`, this allows you to run `git push gerrit`.
  gerrit:
    url: ssh://%{user}@%{host}:%{port}/%{project}.git
    fetch: +refs/heads/*:refs/remotes/gerrit/*
    push: HEAD:refs/publish/master
  # Used to pull down from a repo mirror--in this example GitHub.
  # This is mostly to check that replication from Gerrit to the mirror is working.
  # You should not be pushing to this directly (hence why it has no push spec).
  github:
    url: git@github.com:brigade/%{project}.git
    fetch: +refs/heads/*:refs/remotes/github/*

# Use this remote (from the list above) to push commits out for review
push_remote: gerrit

# Groups to get users from when searching for "all" users. This is necessary
# when a user could potentially be in many groups, since the tool will check
# the memberships of all that user's groups in order to find potential matches.
user_search_groups:
  - 'Registered Users'
```

## License

This project is released under the [MIT license](LICENSE.md).
