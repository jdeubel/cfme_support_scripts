#

=begin rdoc
Copyright 2008 ManageIQ, Inc
$Id: application_global_regex_strings.rb 16597 2009-10-12 15:36:47Z thennessy $
=end
# this file is intended to capture all of the regular expression literals used in this application
# and to create a compiled regex object  from these.  since these are used so frequently I am expecting
# a significant performance boost by eliminating the use of regex literals in favor of the compiled expression

$La_000 = Regexp.new("Database Adapter")
$La_001 = Regexp.new("exceeded limit")
$La_002 = Regexp.new("takeover")
$La_003 = Regexp.new("power state")
$La_004 = Regexp.new("roles have changed")
$La_005 = Regexp.new("remove_snapshot_by_description")
$La_006 = Regexp.new("open")
$La_007 = Regexp.new("closed")
$La_008 = Regexp.new("ERROR --")
$La_009 = Regexp.new("WARN --")
$La_010 = Regexp.new("DEBUG --")
$La_011 = Regexp.new("FATAL --")
$La_000 = Regexp.new("")
$La_000 = Regexp.new("")
$La_000 = Regexp.new("")
$La_000 = Regexp.new("")
$La_000 = Regexp.new("")
$La_000 = Regexp.new("")
$La_000 = Regexp.new("")
$La_000 = Regexp.new("")

$La_0 = Regexp.new("MiqServer-status_update")
$La_1 = Regexp.new('\\* EVM License \\*')
$La_2 = Regexp.new("\\* EVM License END")
$La_3 = Regexp.new("\\[VMDB\\] started on \\[(.*)\\]")
$La_4 = Regexp.new("VMDB settings END")
$La_5 = Regexp.new("DATABASE settings\\:")
$La_6 = Regexp.new("DATABASE settings END")
$La_7 = Regexp.new("^\\s*:server\\:\\s*$")
$La_8 = Regexp.new("MIQ\\(config\\) Database Adapter\\:")
$La_9 = Regexp.new("Version\\:")
$La_10 = Regexp.new("RAILS")
$La_11 = Regexp.new("Build\\:")
$La_12 = Regexp.new("\\:role\\:")
$La_13 = Regexp.new("\\:role:\\s*(.*)")
$La_14 = Regexp.new("\\:zone\\:")
$La_15 = Regexp.new("\\:host\\:")
$La_16 = Regexp.new("\\:hostname\\:")
$La_17 = Regexp.new("\\:name\\:")
$La_18 = Regexp.new("\\:company\\:")
$La_19 = Regexp.new("\\:company:\\s*(.*)")
$La_20 = Regexp.new("\\:username\\:")
$La_21 = Regexp.new("\\:mode\\:")
$La_22 = Regexp.new("\\:adapter\\:")
$La_23 = Regexp.new("\\:database\\:")
$La_24 = Regexp.new("\\:dsn\\:")
$La_25 = Regexp.new("\\:dsn\\:\\s*(.*)")
$La_26 = Regexp.new("\\:max_connections\\:")
$La_27 = Regexp.new("^\\[\\S*\\]")
$La_28 = Regexp.new("\\[RuntimeError\\]")
$La_29 = Regexp.new("\\[(\\S*)\\]?\\s+message\\s+\\[(\\d*)\\]?\\s+delivered\\s*(.*)$")
$La_30 = Regexp.new("^Job")
$La_31 = Regexp.new("Job deleted")
$La_32 = Regexp.new("^JOB")
$La_33 = Regexp.new("JOB_payload")
$La_34 = Regexp.new("dispatch_start\\:")
$La_35 = Regexp.new("dispatch_finish\\:")
$La_36 = Regexp.new("job aborting")
$La_37 = Regexp.new("\\: Saving")
$La_38 = Regexp.new("\\: start")
$La_39 = Regexp.new("\\[Scanning\\]")
$La_40 = Regexp.new("[Ss]canning completed")
$La_41 = Regexp.new(" job finished")
$La_42 = Regexp.new(" finished$")
$La_43 = Regexp.new("action-process_finish:\\s*job")
$La_44 = Regexp.new(" Enter$")
$La_45 = Regexp.new("Agent state update\\:")
$La_46 = Regexp.new("\\[Initializing scan\\]")
$La_47 = Regexp.new("ERROR")
$La_48 = Regexp.new("^MIQ")
$La_49 = Regexp.new("^WorkerMonitor$")
$La_50 = Regexp.new("GUID\\s*\\[(.*)\\]\\s*being killed")
$La_51 = Regexp.new("with PID\\s*\\[(\\d*)\\].*, requesting worker to exit")
$La_52 = Regexp.new("config")
$La_53 = Regexp.new("Server-atStartup")
$La_54 = Regexp.new("Server Zone\\:\\s*(.*)")
$La_55 = Regexp.new("Server Role\\:\\s*(.*)")
$La_56 = Regexp.new("Configuration\.create_or_update")
$La_57 = Regexp.new("miq_server_id\\:\\s\\[(.*)\\]")
$La_58 = Regexp.new("MiqQueue.put")
$La_59 = Regexp.new("MiqQueue.Deliver")
$La_60 = Regexp.new("MiqExpression-apply_search_filter")
$La_61 = Regexp.new("MiqWorker-monitor")
$La_62 = Regexp.new("MiqWorker-status_update")
#    when /MiqWorkerMonitor|MiqVimBrokerWorker|MiqGenericWorker|MiqScheduleWorker|MiqPriorityWorker|MiqEventCatcher|MiqEventHandler|MiqWorker-status_update/ then
$La_62a = Regexp.new("MiqWorkerMonitor")
$La_62b = Regexp.new("MiqVimBrokerWorker")
$La_62c = Regexp.new("MiqGenericWorker")
$La_62d = Regexp.new("MiqScheduleWorker")
$La_62e = Regexp.new("MiqPriorityWorker")
$La_62f = Regexp.new("MiqEventCatcher")
$La_62g = Regexp.new("MiqEventHandler")
$La_62h = Regexp.new("MiqWorker-status_update")

$La_63 = Regexp.new("(.*)\\:\\s*\\[(.*)\\((\\d{1,5})\\)\\]\\s*(.*)Process Info:\\s*(.*)")
$La_64 = Regexp.new("Event Monitor")
$La_65 = Regexp.new("vCenter\\:")
$La_66 = Regexp.new("\\((.*)\\)")
$La_67 = Regexp.new("[Ee]vent")
$La_68 = Regexp.new("[Cc]atcher")
$La_69 = Regexp.new("[Hh]andler")
$La_70 = Regexp.new("Server-status_update")
$La_71 = Regexp.new("(\\[.*\\])\\s*Process info\\:\\s*(.*)$")
$La_72 = Regexp.new("\\[(.*)\\:(.*)\\((.*)\\) \\s*(.*)\\((\\d*)\\)\\]")
$La_73 = Regexp.new("\\[(.*)\\:(.*)\\((\\d*)\\)\\]")
$La_74 = Regexp.new(" Event ")
$La_75 = Regexp.new("\\[(.*)\\((.*)\\)\\]")
$La_76 = Regexp.new("\\[(.*)\\]")
$La_77 = Regexp.new("")
$La_78 = Regexp.new("")
$La_79 = Regexp.new("")
$La_80 = Regexp.new("")
$La_ = Regexp.new("")
$La_ = Regexp.new("")
$La_ = Regexp.new("")
$La_ = Regexp.new("")
$La_ = Regexp.new("")
$La_ = Regexp.new("")
$La_ = Regexp.new("")
$La_ = Regexp.new("")
$La_ = Regexp.new("")
$La_ = Regexp.new("")
$La_ = Regexp.new("")
$La_ = Regexp.new("")
$La_ = Regexp.new("")
$La_ = Regexp.new("")
$La_ = Regexp.new("")
$La_ = Regexp.new("")
$La_ = Regexp.new("")
$La_ = Regexp.new("")
$La_ = Regexp.new("")
$La_ = Regexp.new("")
$La_ = Regexp.new("")
$La_ = Regexp.new("")
$La_ = Regexp.new("")
$La_ = Regexp.new("")
$La_ = Regexp.new("")
$La_ = Regexp.new("")
$La_ = Regexp.new("")
$La_ = Regexp.new("")
$La_ = Regexp.new("")
$La_ = Regexp.new("")
$La_ = Regexp.new("")
$La_ = Regexp.new("")
$La_ = Regexp.new("")
$La_ = Regexp.new("")
$La_ = Regexp.new("")
$La_ = Regexp.new("")
$La_ = Regexp.new("")