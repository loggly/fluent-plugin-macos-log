
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
    command ruby #{SCRIPT_PATH} default
    run_interval 0.3
    tag "my.test.data"
  ]

  JSON_CONFIG = %[
    command ruby #{SCRIPT_PATH} ndjson
    style ndjson
    tag macos
    run_interval 0.3
    <parse>
      @type json
      time_type string
      time_key timestamp
      time_format %Y-%m-%d %H:%M:%S.%L%z
    </parse>
  ]

  data(
      'default' => [DEFAULT_CONFIG, "my.test.data",
                    [event_time("2020-12-08 14:36:12.236613+0100"),
                     event_time("2020-12-08 14:36:12.236773+0100"),
                     event_time("2020-12-08 14:36:12.236781+0100")],
                    [{"thread"=>"0x13d4", "level"=>"Default", "activity"=>"0x0", "ttl"=>"3", "process"=>"sharingd", "message"=> "[com.apple.sharing:Handoff] Request to advertise <a1072cb8bf1d9858f7> with options {SFActivityAdvertiserOptionFlagCopyPasteKey = 1;SFActivityAdvertiserOptionMinorVersionKey = 0;SFActivityAdvertiserOptionVersionKey = 0;}", "pid"=>"683"},
                     {"thread"=>"0x13d4", "level"=>"Error", "activity"=>"0x0", "ttl"=>"2", "process"=>"sharingd", "message"=>
                        "[com.apple.sharing:Handoff] Started advertising <a1072cb8bf1d9858f7> as <08915409f541712ad630460d1a2c> with options {\n" +
                          "    SFActivityAdvertiserOptionFlagCopyPasteKey = 1;\n" +
                          "    SFActivityAdvertiserOptionMinorVersionKey = 0;\n" +
                          "    SFActivityAdvertiserOptionVersionKey = 0;\n" +
                          "}", "pid"=>"500"},
                     {"thread"=>"0x13d4", "level"=>"Info", "activity"=>"0x0", "ttl"=>"1", "process"=>"sharingd", "message"=> "[com.apple.sharing:Handoff] Trying to grab power assertion while we already have one", "pid"=>"404"}]
      ],
      'ndjson' => [JSON_CONFIG, "macos",
                    [event_time("2020-12-10 17:00:10.147707+0100"),
                     event_time("2020-12-10 17:00:10.150141+0100"),
                     event_time("2020-12-10 17:00:10.150159+0100")],
                   [{"traceID"=>762098997530628,"eventMessage"=>"Trying to grab power assertion while we already have one","eventType"=>"logEvent","source"=>nil,"formatString"=>"Sandbox: %s(%d) %s%s","activityIdentifier"=>0,"subsystem"=>"","category"=>"","threadID"=>7071609,"senderImageUUID"=>"EFCEFC07-848B-3EA7-87A0-E967111ABE77","backtrace"=>{"frames"=>[{"imageOffset"=>104220,"imageUUID"=>"EFCEFC07-848B-3EA7-87A0-E967111ABE77"}]},"bootUUID"=>"4044A0BF-330C-4FB9-8D90-D5BF55C7B63C","processImagePath"=>"/kernel","senderImagePath"=>"/System/Library/Extensions/Sandbox.kext/Contents/MacOS/Sandbox","machTimestamp"=>356419409889185,"messageType"=>"Error","processImageUUID"=>"9B5A7191-5B84-3990-8710-D9BD9273A8E5","processID"=>0,"senderProgramCounter"=>104220,"parentActivityIdentifier"=>0,"timezoneName"=>""},
                    {"traceID"=>762098997530628,"eventMessage"=>"(Sandbox) Sandbox: bluetoothd(171) deny(1) mach-lookup com.apple.server.bluetooth","eventType"=>"logEvent","source"=>nil,"formatString"=>"Sandbox: %s(%d) %s%s","activityIdentifier"=>0,"subsystem"=>"","category"=>"","threadID"=>7070658,"senderImageUUID"=>"EFCEFC07-848B-3EA7-87A0-E967111ABE77","backtrace"=>{"frames"=>[{"imageOffset"=>104220,"imageUUID"=>"EFCEFC07-848B-3EA7-87A0-E967111ABE77"}]},"bootUUID"=>"4044A0BF-330C-4FB9-8D90-D5BF55C7B63C","processImagePath"=>"/kernel","senderImagePath"=>"/System/Library/Extensions/Sandbox.kext/Contents/MacOS/Sandbox","machTimestamp"=>356419412323030,"messageType"=>"Error","processImageUUID"=>"9B5A7191-5B84-3990-8710-D9BD9273A8E5","processID"=>0,"senderProgramCounter"=>104220,"parentActivityIdentifier"=>0,"timezoneName"=>""},
                  {"traceID"=>762098997530628,"eventMessage"=>"Sandbox: routined(596) deny(1) file-read-data /Library/Managed Preferences/com.apple.SubmitDiagInfo.plist","eventType"=>"logEvent","source"=>nil,"formatString"=>"Sandbox: %s(%d) %s%s","activityIdentifier"=>0,"subsystem"=>"","category"=>"","threadID"=>7071609,"senderImageUUID"=>"EFCEFC07-848B-3EA7-87A0-E967111ABE77","backtrace"=>{"frames"=>[{"imageOffset"=>104220,"imageUUID"=>"EFCEFC07-848B-3EA7-87A0-E967111ABE77"}]},"bootUUID"=>"4044A0BF-330C-4FB9-8D90-D5BF55C7B63C","processImagePath"=>"/kernel","senderImagePath"=>"/System/Library/Extensions/Sandbox.kext/Contents/MacOS/Sandbox","machTimestamp"=>356419412341049,"messageType"=>"Error","processImageUUID"=>"9B5A7191-5B84-3990-8710-D9BD9273A8E5","processID"=>0,"senderProgramCounter"=>104220,"parentActivityIdentifier"=>0,"timezoneName"=>""}]
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