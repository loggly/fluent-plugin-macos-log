
require_relative '../helper'
require 'fluent/test/driver/input'
require 'fluent/plugin/in_macoslog'

class MacOsLogInputTest < Test::Unit::TestCase
  SCRIPT_PATH = File.expand_path(File.join(File.dirname(__FILE__), '..', 'scripts', 'exec_script.rb'))
  TEST_TIME = "2011-01-02 13:14:15"
  TEST_UNIX_TIME = Time.parse(TEST_TIME)

  def setup
    Fluent::Test.setup
  end

  def create_driver(conf)
    Fluent::Test::Driver::Input.new(Fluent::Plugin::MacOsLogInput).configure(conf)
  end

  DEFAULT_CONFIG = %[
    command ruby #{SCRIPT_PATH} "#{TEST_TIME}" 0
    run_interval 0.3
    tag "my.test.data"
  ]

  data(
      'default' => [DEFAULT_CONFIG, "my.test.data",
                    [event_time("2020-12-08 14:36:12.236613+0100"),
                     event_time("2020-12-08 14:36:12.236773+0100"),
                     event_time("2020-12-08 14:36:12.236781+0100")],
                    [{"host"=>"localhost", "ident"=>"sharingd", "message"=> "[com.apple.sharing:Handoff] Request to advertise <a1072cb8bf1d9858f7> with options {SFActivityAdvertiserOptionFlagCopyPasteKey = 1;SFActivityAdvertiserOptionMinorVersionKey = 0;SFActivityAdvertiserOptionVersionKey = 0;}", "pid"=>"683"},
                     {"host"=>"localhost", "ident"=>"sharingd", "message"=>
                        "[com.apple.sharing:Handoff] Started advertising <a1072cb8bf1d9858f7> as <08915409f541712ad630460d1a2c> with options {\n" +
                          "    SFActivityAdvertiserOptionFlagCopyPasteKey = 1;\n" +
                          "    SFActivityAdvertiserOptionMinorVersionKey = 0;\n" +
                          "    SFActivityAdvertiserOptionVersionKey = 0;\n" +
                          "}", "pid"=>"683"},
                     {"host"=>"localhost", "ident"=>"sharingd", "message"=> "[com.apple.sharing:Handoff] Trying to grab power assertion while we already have one", "pid"=>"683"}]
      ]
  )
  test 'emit with formats' do |data|
    config, tag, times, records = data
    d = create_driver(config)

    d.run(expect_emits: 3, timeout: 10)

    assert{ d.events.length > 0 }
    d.events.each_with_index {|event, idx|
      assert_equal_event_time(times[idx], event[1])
      assert_equal [tag, times[idx], records[idx]], event
    }
  end

  test 'emit error message with read_with_stderr' do
    d = create_driver %[
      tag test
      command ruby #{File.join(File.dirname(SCRIPT_PATH), 'foo_bar_baz_no_existence.rb')}
      connect_mode read_with_stderr
      log_header_lines -1
      <parse>
        @type none
      </parse>
    ]
    d.run(expect_records: 1, timeout: 10)

    assert{ d.events.length > 0 }
    d.events.each do |event|
      assert_equal 'test', event[0]
      assert_match /LoadError/, event[2]['message']
    end
  end
end