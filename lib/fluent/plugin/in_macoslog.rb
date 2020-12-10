
require 'fluent/plugin/input'
require 'fluent/plugin/in_exec/iterative_process'
require 'yajl'

module Fluent::Plugin
  class MacOsLogInput < Fluent::Plugin::Input
    Fluent::Plugin.register_input('macoslog', self)

    helpers :compat_parameters, :extract, :parser, :child_process

    def initialize
      super
      @pf_file = nil
      @log_start_regex = nil
      @compiled_command = nil
    end

    desc 'The command (program) to execute.'
    config_param :command, :string, default: 'log show --start @%s --end @%s'
    desc 'The unified log filter predicate as per Apple\'s documentation'
    config_param :predicate, :string, default: nil
    desc 'Specify connect mode to executed process'
    config_param :connect_mode, :enum, list: [:read, :read_with_stderr], default: :read
    desc 'Logging levels supported by Unified Logging ([no-]backtrace, [no-]debug, [no-]info, [no-]loss, [no-]signpost)'
    config_param :levels, :array, default: [], value_type: :string
    desc 'Output formatting of events from logging tool'
    config_param :style, :enum, list: [:default, :syslog, :json, :ndjson, :compact], default: :default

    config_section :parse do
      config_set_default :@type, 'regexp'
      config_set_default :expression, /^(?<logtime>[\d\-]+\s*[\d\.:\+]+)\s+(?<thread>[^ ]*)\s+(?<level>[^ ]+)\s+(?<activity>[^ ]*)\s+(?<pid>[0-9]+)\s+(?<ttl>[0-9]+)\s+(?<process>[^:]*)(?:[^\:]*\:)\s*(?<message>.*)$/m
      config_set_default :time_key, 'logtime'
      config_set_default :time_format, '%Y-%m-%d %H:%M:%S.%L%z'
    end

    desc 'Tag of the output events.'
    config_param :tag, :string, default: nil
    desc 'The interval time between periodic program runs.'
    config_param :run_interval, :time, default: nil
    desc 'Fluentd will record the time it last read into this file.'
    config_param :pos_file, :string, default: nil
    desc 'The identifier of log line beginning used to split output by.'
    config_param :log_line_start, :string, default: '\d+-\d+-\d+\s+\d+:\d+:\d+[^ ]+'
    desc 'Number of header lines to be skipped. Use negative value if no header'
    config_param :log_header_lines, :integer, default: 1

    attr_reader :parser

    def configure(conf)
      compat_parameters_convert(conf, :parser)

      super

      unless @tag
        raise Fluent::ConfigError, "'tag' option is required on macoslog input"
      end

      @compiled_command = "#{@command} --style #{@style}"

      if conf["predicate"]
        @compiled_command += " --predicate '#{conf['predicate']}'"
      end

      if @levels.length > 0
        compiled_level = @levels.map { |level| "--#{level}" }.join(" ")
        @compiled_command += " #{compiled_level}"
      end

      $log.info "MacOs log command '#{@compiled_command}'"

      @parser = parser_create

      unless @pos_file
        $log.warn "'pos_file PATH' parameter is not set to a 'macoslog' source."
        $log.warn "this parameter is highly recommended to save the position to resume from."
      end

      @log_start_regex = Regexp.compile("\\A#{@log_line_start}")
    end

    def multi_workers_ready?
      true
    end

    def start
      super

      if @pos_file
        pos_file_dir = File.dirname(@pos_file)
        FileUtils.mkdir_p(pos_file_dir, mode: @dir_perm) unless Dir.exist?(pos_file_dir)
        @pf_file = File.open(@pos_file, File::RDWR|File::CREAT|File::BINARY, @file_perm)
        @pf_file.sync = true

        start = @pf_file.read.to_i
        if start == 0
          start = Fluent::EventTime.now.to_s
          @pf_file.write(start)
        end
      else
        start = Fluent::EventTime.now.to_s
        @pf_file.write(start) if @pf_file
      end

      time_callback = -> (timestamp) {
        if @pf_file
          @pf_file.rewind
          @pf_file.write(timestamp)
        end
      }

      timer_process_execute(:exec_input,
                            @compiled_command,
                            start, @run_interval,
                            time_callback,
                            immediate: true, mode: [@connect_mode], &method(:run))
    end

    def shutdown
      @pf_file.close if @pf_file

      super
    end

    def run(io)
      unless io.eof
        if @style == :ndjson
          parse_line_json(io)
        else
          parse_timestamp_base(io)
        end
      end
    end

    def parse_line_json(io)
      logs = Queue.new
      io.each_line.with_index do |line,index|
        logs.push(line.chomp("\n"))
        if index >= @log_header_lines
          @parser.parse(logs.pop, &method(:on_record))
        end
      end
    end

    def parse_timestamp_base(io)
      log = ""
      io.each_line.with_index do |line,index|
        # Skips log header
        if index >= @log_header_lines
          if line =~ @log_start_regex
            if log.empty?
              log = line
            else
              @parser.parse(log.chomp("\n"), &method(:on_record))
              log = line
            end
          else
            log += line
          end
        end
      end

      unless log.empty?
        @parser.parse(log.chomp("\n"), &method(:on_record))
      end
    end

    def on_record(time, record)
      tag = extract_tag_from_record(record)
      tag ||= @tag
      time ||= extract_time_from_record(record) || Fluent::EventTime.now
      router.emit(tag, time, record)
    rescue => e
      log.error "macoslog failed to emit", tag: tag, record: Yajl.dump(record), error: e
      router.emit_error_event(tag, time, record, e) if tag && time && record
    end
  end
end