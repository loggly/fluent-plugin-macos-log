# Fluent::Plugin::MacOsLogInput

[![Gem Version](https://badge.fury.io/rb/fluent-plugin-macos-log.svg)](https://badge.fury.io/rb/fluent-plugin-macos-log) [![CircleCI](https://circleci.com/gh/loggly/fluent-plugin-macos-log/tree/master.svg?style=shield)](https://circleci.com/gh/loggly/fluent-plugin-macos-log/tree/master)

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
interval can be configured by user, but cannot be lower than 1s.

There are multiple configurations one can use:

#### Simplified Output
Uses human-readable output of the command. The process output is parsed using `regexp` parser
and logic, which combines multiple lines together. The parameter `log_line_start` defines regular expresion, which matches the
beginning of line. Anything in between will be merged into single log entry. Although the parser is `regexp`, user can select any other supported parser.
To configure this in fluentd:
```xml
<source>
  @type macoslog
  tag macos
  pos_file /path/to/position/file
  run_interval 10s
</source>
```

#### Detail Output
Use when more detailed output is required. It uses `ndjson` style of `log` command, which is then parsed by json parser.
To configure this in fluentd:
```xml
<source>
  @type macoslog
  style ndjson
  tag macos
  pos_file last-starttime.log
  run_interval 10s
  <parse>
    @type json
    time_type string
    time_key timestamp
    time_format %Y-%m-%d %H:%M:%S.%L%z
  </parse>
</source>
```

### Advanced Configuration
This plugin inherits Fluentd's standard input parameters.

The command used by default is `log show --style default --start @%s --end @%s` in order to combine multiple lines and iterate over
each period of time. Notice the `start` and `end` parameters use `@`, which is notation for unix timestamp format, used by plugin.

Optionally the plugin uses position file, where it records last processed timestamp. Whenever the `fluentd` process
restarts the plugin picks up from the last position. When no position files is used the plugin starts from current time
and keeps last position only in memory.

Optionally one can configure any `predicate` to filter required logs.

* `command` - external command to be executed for each interval. The command's first parameter noted ruby's `%s` as start
unix timestamp and the second `%s` for end timestamp. Default: `log show --style default --start @%s --end @%s`
* `predicate` - log filter predicate as per Apple's documentation. Default: `nil`
* `levels` - Controls what logging levels will be shown. Supported by `log` command:
  * [no-]backtrace              Control whether backtraces are shown
  * [no-]debug                  Control whether "Debug" events are shown
  * [no-]info                   Control whether "Info" events are shown
  * [no-]loss                   Control whether message loss events are shown
  * [no-]signpost               Control whether signposts are shown
* `style` - Controls style of logging tool output.
  * `ndjson` - single lined json format output. When used, the json parser must be configured. 
* `connect_mode` - Control target IO:
  * `read`: Read logs from stdio
  * `read_with_stderr`: Read logs from stdio and stderr (mainly for debug).
* `parser` section - Refer these for more details about parse section. Default `regexp`
* `tag` - The tag of the output events.
* `run_interval` - The interval time between periodic program runs.
* `max_age` - The time base max age of logs to process. Default `3d`
* `pos_file` - Fluentd will record the position it last read from external command.
  Don't share pos_file between in_macoslog configurations. It causes unexpected behavior e.g. corrupt pos_file content.
* `log_line_start` - Regexp of start of the log to combine multiline logs. Default: `\d+-\d+-\d+\s+\d+:\d+:\d+[^ ]+`
* `log_header_lines` - Number of header lines to skip when parsing. When `ndjson` style used the parameter refers
  to number of footer lines to be skipped. Default: `1`

One can configure own parser:
```xml
<source>
  @type macoslog
  tag macos
  pos_file /path/to/position/file
  run_interval 10s
  <parse>
    @type tsv
    keys avg1,avg5,avg15
    delimiter " "
  </parse>
</source>
```

### Example
Example configuration for sending logs over to Loggly. The input plugin collects unified logs with filter `process == "sharingd"`
every `10s` while recording position in file `/path/to/position/file`.

It uses output [fluent-plugin-loggly](https://github.com/patant/fluent-plugin-loggly) configured in buffer mode.

```xml
<source>
  @type macoslog
  predicate process == "sharingd"
  tag macos
  pos_file /path/to/position/file
  run_interval 10s
</source>

<match macos>
  type loggly_buffered
  loggly_url https://logs-01.loggly.com/bulk/xxx-xxxx-xxxx-xxxxx-xxxxxxxxxx
  output_include_time true
  time_precision_digits 3
  buffer_type    file
  buffer_path    /path/to/buffer/file
  flush_interval 10s
</match>
```

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

Bug reports and pull requests are welcome on GitHub at: https://github.com/loggly/fluent-plugin-macos-log

# Questions/Comments?

Please [open an issue](https://github.com/loggly/fluent-plugin-macos-log/issues/new), we'd love to hear from you.
