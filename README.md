# Gerrit CLI

[![Gem Version](https://badge.fury.io/rb/gerrit.svg)](http://badge.fury.io/rb/gerrit)

`gerrit` is Ruby-based tool to make the code review process of working with
[Gerrit](https://code.google.com/p/gerrit/) quicker.

* [Requirements](#requirements)
* [Installation](#installation)
* [License](#license)

## Requirements

* Ruby 2.0.0+

## Installation

```bash
gem install gerrit
```

Run `gerrit` from the command line to perform the initial setup. `gerrit` will
automatically detect if you have a configuration (`.gerrit.yaml`) in the
current working directory or your home directory and ask you a few questions
to create that file for you.

## License

This project is released under the [MIT license](MIT-LICENSE).
