# Gerrit Changelog

## master (unreleased)

* Add `post_setup` configuration option allowing you to define a command to run
  after `gerrit clone` or `gerrit setup` to initialize a repository
* Don't dump stack trace when Gerrit server returns an error
* Treat `-h`/`--help` flags the same as `help` command
* Treat `-v`/`--version` flags the same as `version` command

## 0.7.1

* Fix confirmation for the number of reviewers to not push when user said "n"

## 0.7.0

* Add option to specify the minimum number of reviewers before asking to confirm

## 0.6.0

* Fix pushing of drafts
* Display all available commands in `help` command

## 0.5.0

* Add `submit` command
* Add `clone` command
