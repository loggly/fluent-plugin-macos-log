# Fluent::Plugin::LogglySyslog

[![Gem Version](https://badge.fury.io/rb/fluent-plugin-macos-log.svg)](https://badge.fury.io/rb/fluent-plugin-macos-log) [![CircleCI](https://circleci.com/gh/solarwinds/fluent-plugin-macos-log/tree/master.svg?style=shield)](https://circleci.com/gh/solarwinds/fluent-plugin-macos-log/tree/master)

## Description

This repository contains the Fluentd MacOs unified logs input Plugin.

## Installation

Install this gem when setting up fluentd:
```ruby
gem install fluent-plugin-macos-log
```

## Usage

### Setup

This is a process execution input plugin for Fluentd that periodically executes external `log show` command and parses log events into Fluentd's core system.
Each execution alters `start` and `end` time input parameters of log utility to slowly iterates over log data. The iteration
interval can be configured by user, but cannot be lower than 1s. The process output is than parsed using `regexp` parser
and logic, which combines multiple lines together. The parameter `log_line_start` defines regular expresion, which matches to
beginning of line. Anything in between will be merged into single log entry. Although the parser is `regexp`, user can select any other supported parser.

To configure this in fluentd:
```xml
<source>
    @type macoslog
    command log show --style syslog --predicate 'process == "sharingd"' --start @%s --end @%s
    tag macos
    pos_file last-starttime.log
    run_interval 10s
</source>
```

The command should be `log show --style syslog --start @%s --end @%s` in order to combine multiple lines and iterate over
each period of time. Notice the `start` and `end` parameters use `@`, which is notation for unix timestamp format, used by plugin.

Optionally one can configure any `predicate` to filter required logs.

### Advanced Configuration
This plugin inherits Fluentd's standard input parameters.

* `command` - external command to be executed for each interval. The command's first parameter noted ruby's `%s` as start
unix timestamp and the second `%s` for end timestamp.
* `connect_mode` - Control target IO:
  * `read`: Read logs from stdio
  * `read_with_stderr`: Read logs from stdio and stderr (mainly for debug).
* `parser` section - Refer these for more details about parse section
* `tag` - The tag of the output events.
* `run_interval` - The interval time between periodic program runs.
* `pos_file` - Fluentd will record the position it last read from external command.
  Don't share pos_file between in_macoslog configurations. It causes unexpected behavior e.g. corrupt pos_file content.
* `log_line_start` - Regexp of start of the log to combine multiline logs.
* `log_header_lines` - Number of header lines to skip when parsing.

## Development

This plugin is targeting Ruby 2.6 and Fluentd v1.0, although it should work with older versions of both.

We have a [Makefile](Makefile) to wrap common functions and make life easier.

### Prepare development
To install fluentd on MacOs use following ruby environment.
```shell script
brew install rbenv ruby-build
echo 'if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi' >> ~/.zshrc
source ~/.zshrc
rbenv install 2.6.3
rbenv global 2.6.3

gem install fluentd --no-doc
```

Install latest bundler
```shell script
gem install bundler
```

### Install Dependencies
`make bundle`

### Test
`make test`

### Release in [RubyGems](https://rubygems.org/gems/fluent-plugin-macos-log)
To release a new version, update the version number in the [GemSpec](fluent-plugin-macos-log.gemspec) and then, run:

`make release`

## Contributing

Bug reports and pull requests are welcome on GitHub at: https://github.com/solarwinds/fluent-plugin-macos-log

# Questions/Comments?

Please [open an issue](https://github.com/solarwinds/fluent-plugin-macos-log/issues/new), we'd love to hear from you.
