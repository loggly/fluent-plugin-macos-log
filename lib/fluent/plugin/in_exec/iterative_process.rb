
require 'fluent/plugin_helper/child_process'

module Fluent
  module PluginHelper
    module ChildProcess
      include Fluent::PluginHelper::Thread
      include Fluent::PluginHelper::Timer

      def timer_process_execute(
        title, command, start_timestamp, interval, time_callback,
        arguments: nil, subprocess_name: nil, immediate: false, parallel: false,
        mode: [:read, :write], stderr: :discard, env: {}, unsetenv: false, chdir: nil,
        internal_encoding: 'utf-8', external_encoding: 'ascii-8bit', scrub: true, replace_string: nil,
        wait_timeout: nil, on_exit_callback: nil,
        &block
      )
        raise ArgumentError, "BUG: title must be a symbol" unless title.is_a? Symbol
        raise ArgumentError, "BUG: arguments required if subprocess name is replaced" if subprocess_name && !arguments

        mode ||= []
        mode = [] unless block
        raise ArgumentError, "BUG: invalid mode specification" unless mode.all?{|m| MODE_PARAMS.include?(m) }
        raise ArgumentError, "BUG: read_with_stderr is exclusive with :read and :stderr" if mode.include?(:read_with_stderr) && (mode.include?(:read) || mode.include?(:stderr))
        raise ArgumentError, "BUG: invalid stderr handling specification" unless STDERR_OPTIONS.include?(stderr)

        raise ArgumentError, "BUG: number of block arguments are different from size of mode" if block && block.arity != mode.size

        running = false
        callback = ->(*args) {
          running = true
          begin
            block && block.call(*args)
          ensure
            running = false
          end
        }

        execute_child_process = ->(cmd) {
          child_process_execute_once(
            title, cmd, arguments,
            subprocess_name, mode, stderr, env, unsetenv, chdir,
            internal_encoding, external_encoding, scrub, replace_string,
            wait_timeout, on_exit_callback,
            &callback
          )
        }

        now = Fluent::EventTime.now.to_int
        if immediate && start_timestamp.to_i < now
          execute_child_process.call(command % [start_timestamp, now])
          start_timestamp = now
          time_callback.call(start_timestamp)
        end

        timer_execute(:child_process_execute, interval, repeat: true) do
          if !parallel && running
            log.warn "previous child process is still running. skipped.", title: title, command: command, arguments: arguments, interval: interval
          else
            end_timestamp = Fluent::EventTime.now.to_s
            execute_child_process.call(command % [start_timestamp, end_timestamp])
            start_timestamp = end_timestamp
            time_callback.call(start_timestamp)
          end
        end

      end

    end
  end
end
