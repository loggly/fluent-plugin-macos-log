
case ARGV.first
when "ndjson"
  puts '{"traceID":762098997530628,"eventMessage":"Trying to grab power assertion while we already have one","eventType":"logEvent","source":null,"formatString":"Sandbox: %s(%d) %s%s","activityIdentifier":0,"subsystem":"","category":"","threadID":7071609,"senderImageUUID":"EFCEFC07-848B-3EA7-87A0-E967111ABE77","backtrace":{"frames":[{"imageOffset":104220,"imageUUID":"EFCEFC07-848B-3EA7-87A0-E967111ABE77"}]},"bootUUID":"4044A0BF-330C-4FB9-8D90-D5BF55C7B63C","processImagePath":"\/kernel","timestamp":"2020-12-10 17:00:10.147707+0100","senderImagePath":"\/System\/Library\/Extensions\/Sandbox.kext\/Contents\/MacOS\/Sandbox","machTimestamp":356419409889185,"messageType":"Error","processImageUUID":"9B5A7191-5B84-3990-8710-D9BD9273A8E5","processID":0,"senderProgramCounter":104220,"parentActivityIdentifier":0,"timezoneName":""}
{"traceID":762098997530628,"eventMessage":"(Sandbox) Sandbox: bluetoothd(171) deny(1) mach-lookup com.apple.server.bluetooth","eventType":"logEvent","source":null,"formatString":"Sandbox: %s(%d) %s%s","activityIdentifier":0,"subsystem":"","category":"","threadID":7070658,"senderImageUUID":"EFCEFC07-848B-3EA7-87A0-E967111ABE77","backtrace":{"frames":[{"imageOffset":104220,"imageUUID":"EFCEFC07-848B-3EA7-87A0-E967111ABE77"}]},"bootUUID":"4044A0BF-330C-4FB9-8D90-D5BF55C7B63C","processImagePath":"\/kernel","timestamp":"2020-12-10 17:00:10.150141+0100","senderImagePath":"\/System\/Library\/Extensions\/Sandbox.kext\/Contents\/MacOS\/Sandbox","machTimestamp":356419412323030,"messageType":"Error","processImageUUID":"9B5A7191-5B84-3990-8710-D9BD9273A8E5","processID":0,"senderProgramCounter":104220,"parentActivityIdentifier":0,"timezoneName":""}
{"traceID":762098997530628,"eventMessage":"Sandbox: routined(596) deny(1) file-read-data \/Library\/Managed Preferences\/com.apple.SubmitDiagInfo.plist","eventType":"logEvent","source":null,"formatString":"Sandbox: %s(%d) %s%s","activityIdentifier":0,"subsystem":"","category":"","threadID":7071609,"senderImageUUID":"EFCEFC07-848B-3EA7-87A0-E967111ABE77","backtrace":{"frames":[{"imageOffset":104220,"imageUUID":"EFCEFC07-848B-3EA7-87A0-E967111ABE77"}]},"bootUUID":"4044A0BF-330C-4FB9-8D90-D5BF55C7B63C","processImagePath":"\/kernel","timestamp":"2020-12-10 17:00:10.150159+0100","senderImagePath":"\/System\/Library\/Extensions\/Sandbox.kext\/Contents\/MacOS\/Sandbox","machTimestamp":356419412341049,"messageType":"Error","processImageUUID":"9B5A7191-5B84-3990-8710-D9BD9273A8E5","processID":0,"senderProgramCounter":104220,"parentActivityIdentifier":0,"timezoneName":""}
{"count":4,"finished":1}'

else
  puts "Timestamp                       Thread     Type        Activity             PID    TTL
2020-12-08 14:36:12.236613+0100 0x13d4     Default     0x0                  683    3    sharingd: [com.apple.sharing:Handoff] Request to advertise <a1072cb8bf1d9858f7> with options {SFActivityAdvertiserOptionFlagCopyPasteKey = 1;SFActivityAdvertiserOptionMinorVersionKey = 0;SFActivityAdvertiserOptionVersionKey = 0;}
2020-12-08 14:36:12.236773+0100 0x13d4     Error       0x0                  500    2    sharingd: [com.apple.sharing:Handoff] Started advertising <a1072cb8bf1d9858f7> as <08915409f541712ad630460d1a2c> with options {
    SFActivityAdvertiserOptionFlagCopyPasteKey = 1;
    SFActivityAdvertiserOptionMinorVersionKey = 0;
    SFActivityAdvertiserOptionVersionKey = 0;
}
2020-12-08 14:36:12.236781+0100 0x13d4     Info        0x0                  404    1    sharingd: [com.apple.sharing:Handoff] Trying to grab power assertion while we already have one"
end