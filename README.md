# Gerrit CLI

[![Gem Version](https://badge.fury.io/rb/gerrit.svg)](http://badge.fury.io/rb/gerrit)

`gerrit` is Ruby-based tool to make the process of working with
[Gerrit](https://code.google.com/p/gerrit/) from the command line more
pleasant.

It is not intended to be used in scripts. Rather, it is intended to reduce the
number of occasions you need to visit Gerrit in a browser by providing powerful
CLI shortcuts.

* [Requirements](#requirements)
* [Installation](#installation)
* [Configuration](#configuration)
* [Usage](#usage)
* [License](#license)

## Requirements

* Ruby 2.0.0+

## Installation

```bash
gem install gerrit
```

Run `gerrit setup` from the command line to perform the initial setup. `gerrit`
will automatically detect if you have a configuration ([`.gerrit.yaml`](#configuration))
in the current working directory or any of its ancestors, taking the first one
it finds.

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
    push: HEAD:refs/heads/master
  # Used for pushing commits out for review.
  # While you should use `gerrit push`, this allows you to run `git push gerrit`.
  gerrit:
    url: ssh://%{user}@%{host}:%{port}/%{project}.git
    push: HEAD:refs/publish/master
  # Used to pull down from a repo mirror--in this example GitHub.
  # This is mostly to check that replication from Gerrit to the mirror is working.
  # You should not be pushing to this directly (hence why it has no push spec).
  github:
    url: git@github.com:my-organization/%{project}.git

# Use this remote (from the list above) to push commits out for review
push_remote: gerrit

# Groups to get users from when searching for "all" users. This is necessary
# when a user could potentially be in many groups, since the tool will check
# the memberships of all that user's groups in order to find potential matches.
user_search_groups:
  - 'Registered Users'
```

## Usage

All commands are of the form `gerrit command`, where `command` is from the list
below:

### `checkout [change]`

Checks out the latest patchset of a change locally.

```
> gerrit checkout 1337

Finding latest patchset...
Fetching patchset...
You have checked out refs/changes/37/1337/2
```

`change` can be a Change-Id or a change number (i.e. the value in the URL). If
you don't specify on the command line you'll be asked for one.

### `groups`

Lists all groups visible to you.

```
> gerrit groups

Backend Team
Engineering
Web Team
```

### `help`

Displays usage information.

```
> gerrit help

Usage: gerrit [command]
...
```

### `members [regex]`

Lists all members in the specified group, including their username, full name,
and email.

```
> gerrit members eng

┌──┬─────────────┬─────────────┬─────────────────────────┐
│ID│Username     │Name         │Email                    │
├──┼─────────────┼─────────────┼─────────────────────────┤
│8 │john.doe     │John Doe     │john.doe@example.com     │
│1 │joe.smith    │Joe Smith    │joe.smith@example.com    │
│12│dave.michaels│Dave Michaels│dave.michaels@example.com│
└──┴─────────────┴─────────────┴─────────────────────────┘
```

### `projects`

Lists all projects visible to you.

```
> gerrit projects

All-Users
helper-scripts
my-application
```

This is a light wrapper around the underlying `ls-projects` Gerrit SSH command.
See its [documentation](https://gerrit-review.googlesource.com/Documentation/cmd-ls-projects.html)
for examples of additional flags you can specify.

### `push [ref] [reviewer reviewer ...]`

Pushes one or more commits for review.

```
> gerrit push

Target branch (default master):
master
Are you pushing this as a draft? (y/n)[n] n
Topic name (optional; enter * to autofill with your current branch):
my-topic-branch
Enter users/groups you would like to review your changes:
backend dave
```

When entering users/groups, the `push` command will split by spaces and treat
each chunk as a regex. It will then first see if that regex matches any groups,
and if it does return add all users from those groups as reviewers.
Otherwise, it will pull users from the groups specified in your
`user_search_groups` configuration option, and return any users that match the
regex.

This ultimately makes it very easy to add reviewers without having to type
their full username, and allows you to tag entire teams for pariticularly
important changes.

Specifying a `ref` and one or more `reviewer`s on the command line will bypass
the prompts, accepting defaults.

### `setup [project-name]`

Configures the repository's remotes to push/pull to/from the Gerrit server
specified in your `~/.gerrit.yaml` configuration.

```
> gerrit setup

The following remotes already exist and will be replaced:
origin

Replace them? (y/n)[n] y
Added origin ssh://john.doe@gerrit.example.com:29418/helper-scripts.git
Added gerrit ssh://john.doe@gerrit.example.com:29418/helper-scripts.git
Added github git@github.com:example-org/helper-scripts.git

You can now push commits for review by running: gerrit push
```

Specifying the `project-name` allows you to explicitly name the Gerrit
project. By default, this will be the name of the git repo itself, so you
usually won't need to specify this.

### `version`

Displays the version of this client.

```
> gerrit version
```

## License

This project is released under the [MIT license](LICENSE.md).
