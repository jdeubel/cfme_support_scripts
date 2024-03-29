=begin rdoc
Copyright 2008 ManageIQ, Inc
$Id: job_payload_class.rb 21179 2010-05-24 11:26:54Z thennessy $
=end

class JOB_payload
  attr_reader  :job_cmd, :job_uuid, :job_modifiers_cnt, :job_modifiers, :trace_line
  attr_reader  :job_miq_cmd, :job_miq_cmd_text, :job_modifiers_cnt, :job_action
  attr_accessor :job_cmd, :job_vm_name, :job_userid, :job_description, :job_target_class
  attr_accessor :job_target_id, :job_process_type, :job_agent_class, :job_agent_id
  attr_accessor :jobstep_created, :job_created_flag, :job_ended_flag, :job_zone
  attr_accessor :job_buildid
  @@jobs_created_cnt = 0
  @@jobs_completed_cnt = 0
  @@jobs_abended_cnt = 0
  def JOB_payload.increment_created     #class method to increment jobs created
    @@jobs_created_cnt += 1
  end
  def JOB_payload.increment_completed   # class method to increment jobs completed successfully
    @@jobs_completed_cnt += 1
  end
  def JOB_payload.increment_abended     # class method to increment jobs terminated for any reason
    @@jobs_abended_cnt += 1
  end
  def JOB_payload.get_created_cnt       # class method to return count of jobs created
    @@jobs_created_cnt
  end
  def JOB_payload.get_completed_cnt     # class method to return count of jobs completed
    @@jobs_completed_cnt
  end
  def JOB_payload.get_abended_cnt       # class method to return count of jobs terminated in error
    @@jobs_abended_cnt\
  end

  def initialize(payload)
#    if /proxy-call_ws/ =~ payload then
#      puts "#{__FILE__}:#{__LINE__}-> proxy-call_ws"
#    end
    @job_modifiers_cnt = nil
    @job_modifiers = nil
    @job_miq_cmd = nil
    @job_miq_cmd_text = nil
    @job_vm_name = nil
    @job_userid = nil
    @job_description = nil 
    @job_target_class = nil
    @job_target_id = nil
    @job_process_type = nil
    @job_agent_class = nil
    @job_agent_id = nil
    @job_uuid = nil
    @job_action = nil
    @job_cmd = nil
    @job_zone = nil
    @jobstep_created = nil
    @job_create_flag = nil    # this is only set when the job is created
    @job_ended_flag = nil     # this is set when the job ends, terminaters before starting or abends
    @job_startup_cnt = $startup_cnt    # inject the value of the current evm startup
    @job_buildid = $Startups[$startup_cnt]["build"]

#    if /Scanning/ =~ payload && /completed/ =~ payload then
#        puts "#{__FILE__}:#{__LINE__}=> payload contains 'Scanning completed'"
#    end
    
#    if /action-abort/ =~ payload
#      puts ""
#    end  
#    if /11e76174-c93d-11dd-8342-000c295a4baa/ =~ payload then
#      puts "#{__FILE__}:#{__LINE__}-> #{payload.inspect}"
#    end
    _payload_array = payload.split
    if /JOB\(\[(.*?)\]/ =~ _payload_array[0] then
      @job_uuid = $1
    end
    case payload
    when /Q-task_id\(\[(.*?)\]\)\s*VdlConnection\.getDisk\:\s*(.*)\s*open disks\s*\=\s*(\d*)/ then
 #[----] I, [2009-06-24T15:36:44.286065 #28075]  INFO -- :
#Q-task_id([d29bdd5e-60d3-11de-91fa-005056ac7674]) VdlConnection.getDisk: 30.5.160.50 open disks = 1
      @job_uuid = $1
#      work_string1 = $2
#      work_string2 = $3
      @job_miq_cmd = "opening disk"
      @job_action = @job_miq_cmd + " " + $2.to_s.strip + " "+ $3.to_s.strip
      @job_miq_cmd_text = payload
    when /Q-task_id\(\[(.*?)\]\)\s*Scanning\s*\[(.*)\]\s*information ran for\s*\[(.*)\]\s*seconds\./ then
      @job_uuid = $1
      @job_miq_cmd = "Scanning " + $2
      @job_action = @job_miq_cmd + " " + $3
      @job_miq_cmd_text = payload

    when /Q-task_id\(\[(.*?)\]\)\s*MIQ\((.*?)\)/ then
      @job_uuid = $1
      @job_miq_cmd = $2
      @job_miq_cmd_text = $POSTMATCH
      @job_action = $2
      if /proxy-call_ws/ =~ @job_miq_cmd  and /Calling\:/ =~ @job_miq_cmd_text then
      _tmp_str = parse_proxy_call_ws_parms(@job_miq_cmd_text)
      @job_action = @job_miq_cmd + " " + _tmp_str

      end
#    when /JOB\(\[(.*)\](.*)/ then
#      puts "#{__FILE__}:#{__LINE__}-> payload is #{payload}"
    when /Q-Task_id\(\[(.*)\]\)\s*Job created\:\s*(.*)/ then
      # job is created from a schedule perhaps
      # lets just process it
      _temp1 = $1
      @job_cmd = "Q-Task_id([" + _temp1 + "])"
      _temp2 = $2
#      if @job_create_flag == nil   then       # if this is a create record
#        @job_create_flag = true
#      end
      _work_array = _temp2.split(",")
      _work_array.each do |x|
        case x
        when /guid:\s*\[(.*?)\]/ then
          @job_uuid = $1
        when /userid:\s*\[(.*)\]/ then
          @job_userid = $1
        when /name:\s*\[(.*)\]/ then
          @job_description = $1
          if /Scan from VM\s*(.*)/ =~ @job_description then
            @job_vm_name = $1
          end
          
        when /process type:\s*\[(.*)\]/ then
          @job_process_type = $1
        when /target class:/ then
          if /\[(.*)\]/ =~ x then @job_target_class = $1 end
        when /target id:/ then
          if /\[(.*)\]/ =~ x then @job_target_id = $1 end   
        when /agent class:/ then
          if /\[(.*)\]/ =~ x then @job_agent_class = $1 end
        when /agent id:/ then
          if /\[(.*)\]/ =~ x then @job_agent_id = $1 end
          
        end
        
      end
      @job_cmd = "Job Created:" + @job_description  + "("  + @job_target_class + "=" + @job_target_id + ")"
#Q-Task_id([vc-refresher]) Job created: guid: [19fdf4ba-59e2-11dd-a75a-005056bd5e0e], 
#userid: [system], name: [Scan from Vm Refresh Test 1], target class: [Vm], 
#target id: [130], process type: [VmScan], agent class: [], agent id: []      
    when /JOB\(\[(.*?)\]\s*vm_scan_context(.*)/ then
      @job_uuid = $1
      @job_cmd = "vm_scan_context" if @job_cmd == nil
      _temp = $2
#      if /snapshot_delete/ =~ _temp then
#        puts "#{__FILE__}:#{__LINE__}"
#      end
      case _temp
      when /snapshot_delete\, message\:(.*)/ then
        @job_action = "snapshot_delete message"
        @job_miq_cmd_text = $1
      when /action-(\S*)\:\s*(.*)/  then
        _tmp_action = $1
        @job_action = "action-" + _tmp_action
        if /call/ =~ _temp then               # if the action includes "call" then it is small and include
          @job_action = _temp                 # the entire text
        end
        if _tmp_action == "process_data" && /Summary XML/ !~ _temp then  # if process_data type then take the whole section into job action
          @job_action = _temp
        end
        if /Summary XML\s*\[(.*)\/>\]/ =~ _temp then
          @job_modifiers = $1.split
          @job_modifiers_cnt = @job_modifiers.size
          @job_modifiers.each do |x|
             @job_action = @job_action + " Summary XML <" + x + "/>"  if /original_filename/ =~ x 
          end
        
        else
          @job_modifiers =  _temp.split(",")          
        end


        @job_modifiers_cnt = @job_modifiers.size
      when /action-(\S*)\s*$/ then
        @job_action = "action-" + $1
        @job_modifiers = nil
        @job_modifiers_cnt = 0
      when /MIQ\((\S*)\)(.*)/ then
#        @job_action = "MIQ(" + $1 + ")" + $2
         @job_modifiers =  _temp.split(",")
        @job_action = @job_modifiers[0]
        @job_modifiers_cnt = @job_modifiers.size           
#        @job_modifiers_cnt = 0
      when /Creating snapshot/ then
        @job_action = "Creating snapshot"
         @job_modifiers =  _temp.split(",")
        @job_action = @job_modifiers[0]
        @job_modifiers_cnt = @job_modifiers.size
      when /Deleting snapshot\:/ then
        @job_action = "deleting snapshot"
#      when /snapshot_delete, message\:/
#        @job_action = "snapshot_delete message"
      when /Created snapshot/ then
        @job_action = "Created snapshot"
        @job_modifiers =  _temp.split(",")
        @job_action = @job_modifiers[0]
        @job_modifiers_cnt = @job_modifiers.size  
      when /Agent state update\:\s*(.*)/         then
        @job_action = $1
        @job_modifiers =  _temp.split(",")
#        @job_action = @job_modifiers[0]
        @job_modifiers_cnt = @job_modifiers.size
      when /dispatch_start\:\s*(.*)/ then
        @job_action = "dispatch_start"
        @job_modifiers = _temp.split(",")
        @job_modifiers_cnt = @job_modifiers.size
      when /dispatch_finish\:\s*(.*)/ then
        @job_action = "dispatch_finish"
        @job_modifiers = _temp.split(",")
        @job_modifiers_cnt = @job_modifiers.size
        
      end

    when /JOB\(\[(.*?)\]\s*storage_dispatcher_context(\S*)\)\s*(.*)$/ then
      @job_uuid = $1
      @job_cmd = "storage_dispatcher_context" if @job_cmd == nil
      _temp = $2
      _modifiers = $3
      _working_array = _modifiers.split(",")
        @job_modifiers_cnt = _working_array.size
        @job_modifiers = _working_array
#        if /action-process_finish: job/ =~ _modifiers then
#          puts ""
#        end
        if /TRACE/ !~ _temp
          if _working_array[0].class == "NilClass" then
            puts "#{__FILE__}:#{__LINE__} - #{$Parsed_log_line}"
          end
          case _working_array[0]
          when /action-process_start:\s*Error job\s*\[(.*?)\]: No eligible proxies for vm\s*:\[(.*)\]$/ then
            @job_cmd = "Job Terminated"
            @job_action = "Action-process_start: Error Job- No Eligible Proxy for " + $2
            @job_uuid = $1
            @job_vm_name = $2



          when /action-process_start/ then
            @job_action = "action-process_start"
            if /job\s*\[(.*?)\]/ =~ _working_array[0]  then
              # if the target job is buried in the payload of the JOB command
              # then we can excise it by the experssion above and inject
              # as real job_uuid
              @job_uuid = $1
            end
          when /Processing/ then
            puts "#{__FILE__}:#{__LINE__}"
          when /action-dispatch_init/ then
          when /action-process_finish: job\s*\[(.*?)\]\s*update:/ then
            # this log line can be used to reconstruct job information if
            # we didn't catch the job creation in this log so we will parse it
            # here and make it available if needed.
#sample line:
#JOB([52a05096-6d5c-11dd-a0a4-005056a13b8c] storage_dispatcher_context) 
#action-process_finish: job [4cbebe00-6da3-11dd-941d-005056a13b8c] update: userid: [admin],
# name: [Scan from Vm WIN2K3TMPLATE], target class: [Vm], target id: [42],
#  process type: [VmScan], agent class: [Host], agent id: [7] 
            @job_uuid = $1
            _working_array.each {|key_value_text|
              case key_value_text
              when /name:\s*\[(.*)\]/ then
                @job_description = $1
                @job_vm_name = $1
              when /process type:\s*\[(\S*)\]/ then
                @job_process_type = $1
              when /userid:\s*\[(\S*)\]/ then
                @job_userid = $1
              when /target class:\s*\[(\S*)\]/ then
                @job_target_class = $1
              when /target id:\s*\[(\S*)\]/ then
                @job_target_id = $1
              when /agent class:\s*\[(\S*)\]/ then
                @job_agent_class = $1
              when /agent id:\s*\[(\S*)\]/ then
                @job_agent_id = $1
                
              end
            }
            
          when /action-process_finish/ then
            @job_action = "action-process_finish"
            if /job\[(.*?)\]/ =~ _working_array[0]  then
              # if the target job is buried in the payload of the JOB command
              # then we can excise it by the experssion above and inject
              # as real job_uuid
              @job_uuid = $1
            end
          when /(action-.*)\s*job\s*\[(.*?)\]/ then
            @job_action = $1
            @job_uuid = $2
            _temp1 = $POSTMATCH
            case _temp1
            when /undefined method (\.*)/ then
              @job_cmd = "Job Terminated"
              @job_action = @job_action + "Error job - undefined method" + $POSTMATCH
            when /No eligible proxies/ then
            end            
          else puts "#{File.basename(__FILE__)}:#{__LINE__}=>#{payload}\n\t unrecognized JOB action"
          end
        end
#        if /\]/ =~ @job_uuid then
#          puts ""
#        end
#        end
#      puts "#{_modifiers}"
    when /JOB\(\[(.*?)\]\s*(.*?)\)\s*(.*)/ then

      @job_cmd = $2
      @job_uuid = $1
      _temp = $3   
      _modifiers = $3
       if /action-(\S*)\:(.*)/ =~ _temp then
         @job_action = $1 + ":" + $2
       else 
          @job_action = _temp
       end
            case @job_action
            when /Summary\s*XML/ then
              if /original_filename=\'(\S*)\'/ =~ @job_action then
                @job_action = "action-process_data: Summary XML [" + $1 + "]"
              end
              
            else
            end       
#      if /MIQ/ =~ _temp then
#        puts "#{__FILE__}:#{__LINE__}=>#{_temp.inspect}"
#      end
      
      if @job_cmd.size < 2 || @job_cmd ==  nil || @job_cmd == " " then
        puts "#{File.basename(__FILE__)}:#{__LINE__}=>#{@job_cmd}"
      end
# if TRACE is within the JOB statement then capture that info      
      if /TRACE/ =~ payload then @trace_line = TRUE else @trace_line = nil end

      # if this job log entry contains the response from an MIQ command
      # then handle it differently from others
      if /MIQ\((\S*)\)\s*(.*)/ =~ _modifiers then
        #capture the MIQ command and the text returned from the smarthost
        @job_miq_cmd = $1
        @job_mig_cmd_text = $2
      end
      # if this only contains state modifiers and status then handle as follows
      # each seems to be a descriptor":" value"," so I'll split them at the comma
      # into an array      
        _working_array = _modifiers.split(",")
        @job_modifiers_cnt = _working_array.size
        @job_modifiers = _working_array
#      end
#    end
    when /Job\s*created\:\s*(.*)$/  then
      @job_action = "Job Created"
      _working_string = $1
      if /name:\s*\[(.*?)\],/ =~ _working_string then
        _working_name = $1.tr(","," ")
        _working_string = $PREMATCH + "name: [" + _working_name + "]," + $POSTMATCH

      end
      _working_array = _working_string.split(",")             # the information follow this line is formatted as key: [value]
                                                 # separated by commas, so I'll turn this into an array and process
                                                 # each array element separately 
      _working_array.each {|key_value| 
        case key_value
          when /guid:/ then
            if /\[(.*?)\]/ =~ key_value then @job_uuid = $1 end
          when /name:/ then
            if /\[(.*)\]/ =~ key_value then @job_description = $1 end
          when /target class:/ then
            if /\[(.*)\]/ =~ key_value then @job_target_class = $1 end
          when /target id:/ then
            if /\[(.*)\]/ =~ key_value then @job_target_id = $1 end
          when /process type:/ then
            if /\[(.*)\]/ =~ key_value then @job_process_type = $1 end
          when /agent class:/ then
            if /\[(.*)\]/ =~ key_value then @job_agent_class = $1 end
          when /agent id:/ then
            if /\[(.*)\]/ =~ key_value then @job_agent_id = $1 end
          when /userid:/ then
            if /\[(.*)\]/ =~ key_value then @job_userid = $1 end
          when /zone:/ then
            if /\[(.*)\]/ =~ key_value then @job_zone = $1 end
          else
            puts "******** #{File.basename(__FILE__)}:#{__LINE__}\n\tfrom job_payload_class: payload contains unknown keyword.\n\tpayload =>#{payload}\n\tkey_value data is '#{key_value}'"
        end
            }  
#            puts "#{__FILE__}:#{__LINE__}"
#            puts "#{@job_cmd}"
#            puts "#{@job_description}"
#            puts "#{job_target_class}"
#            puts "#{job_target_id}"
       @job_cmd = "Job Created:" + @job_description  + "("  + @job_target_class + "=" + @job_target_id + ")"
#       @job_uuid = $1
#      @job_vm_name = $3
#      @job_userid = $2
# Job [2ea93eb6-502b-11de-8aa1-0050568b2450] update: userid: [admin], name: [Scan from Vm DB2], target class: [Vm], target id: [6], process type: [VmScan], agent class: [MiqServer], agent id: [1]
    when /Job\s*\[(.*?)\]\s*update\:\s*(.*)/ then
      @job_uuid = $1
      @job_action = "Job update"
      _working_array = $2.split(",")
      _working_array.each {|key_value|
        case key_value
         when /guid:/ then
          if /\[(.*?)\]/ =~ key_value then @job_uuid = $1 end
        when /name:/ then
          if /\[(.*)\]/ =~ key_value then @job_description = $1 end
        when /target class:/ then
          if /\[(.*)\]/ =~ key_value then @job_target_class = $1 end
        when /target id:/ then
          if /\[(.*)\]/ =~ key_value then @job_target_id = $1 end
        when /process type:/ then
          if /\[(.*)\]/ =~ key_value then @job_process_type = $1 end
        when /agent class:/ then
          if /\[(.*)\]/ =~ key_value then @job_agent_class = $1 end
        when /agent id:/ then
          if /\[(.*)\]/ =~ key_value then @job_agent_id = $1 end
        when /userid:/ then
          if /\[(.*)\]/ =~ key_value then @job_userid = $1 end
        when /zone:/ then
          if /\[(.*)\]/ =~ key_value then @job_zone = $1 end
        else
          puts "******** #{File.basename(__FILE__)}:#{__LINE__}\n\tfrom job_payload_class: payload contains unknown keyword.\n\tpayload =>#{payload}\n\tkey_value data is '#{key_value}'"
        end        
      }

    when /Job deleted:\s*(.*)$/ then
      @job_action = "Job deleted"
      _working_array = $1.split(",")    #save the post match string for parsing
      _working_array.each {|key_value|
        case key_value
         when /guid:/ then 
          if /\[(.*?)\]/ =~ key_value then @job_uuid = $1 end
        when /name:/ then 
          if /\[(.*)\]/ =~ key_value then @job_description = $1 end
        when /target class:/ then
          if /\[(.*)\]/ =~ key_value then @job_target_class = $1 end
        when /target id:/ then
          if /\[(.*)\]/ =~ key_value then @job_target_id = $1 end
        when /process type:/ then
          if /\[(.*)\]/ =~ key_value then @job_process_type = $1 end
        when /agent class:/ then
          if /\[(.*)\]/ =~ key_value then @job_agent_class = $1 end
        when /agent id:/ then
          if /\[(.*)\]/ =~ key_value then @job_agent_id = $1 end
        when /userid:/ then
          if /\[(.*)\]/ =~ key_value then @job_userid = $1 end
        when /zone:/ then
          if /\[(.*)\]/ =~ key_value then @job_zone = $1 end
        else
          puts "******** #{File.basename(__FILE__)}:#{__LINE__}\n\tfrom job_payload_class: payload contains unknown keyword.\n\tpayload =>#{payload}\n\tkey_value data is '#{key_value}'"
        end
                    
#        end
      }
#    if @job_uuid.to_s.split.size > 1 then
#      puts "#{__FILE__}:#{__LINE__}=> uuid has more than one word #{payload}"
#    end
#[----] I, [2009-04-11T06:20:43.663257 #31129]  INFO -- : Q-task_id([5a59e40a-264d-11de-91e4-005056800ef4]) MIQ(MiqQueue.deliver)  (PID: 31129) Message id: [1599596], Zone: [TIC], Role: [smartstate], Server: [], Ident: [priority], Target id: [], Task id: [5a59e40a-264d-11de-91e4-005056800ef4], Delivered in [9.324893] seconds, status [ok]
#[----] I, [2009-04-11T06:20:43.663257 #31129]  INFO -- : Q-task_id([5a59e40a-264d-11de-91e4-005056800ef4]) MIQ(PriorityWorker) [31129] message [1599596] delivered [OK]
#[----] I, [2009-04-11T06:20:43.083684 #31129]  INFO -- : Q-task_id([5a59e40a-264d-11de-91e4-005056800ef4]) SOAP Request:  length=9425
#[----] I, [2009-04-11T06:20:43.443869 #31129]  INFO -- : Q-task_id([5a59e40a-264d-11de-91e4-005056800ef4]) SOAP Response: length=467
#[----] I, [2009-04-11T06:20:43.464372 #31129]  INFO -- : Q-task_id([5a59e40a-264d-11de-91e4-005056800ef4]) MIQ(proxy-call_ws): Method: [ScanMetadata] returned: [true]
#[----] I, [2009-04-11T06:20:42.883130 #31129]  INFO -- : Q-task_id([5a59e40a-264d-11de-91e4-005056800ef4]) MIQ(vm-scan_metadata): SCAN METADATA [softwaresystemaccountsvmconfigservicesprofiles] [Array]
#[----] I, [2009-04-11T06:20:42.923431 #31129]  INFO -- : Q-task_id([5a59e40a-264d-11de-91e4-005056800ef4]) MIQ(proxy-call_ws): Calling: [{:hostId=>"d67c9bea-fec0-11dd-99a5-005056807da9", :category=>"software,system,accounts,vmconfig,services,profiles", :host=>"10.233.39.109", :port=>"1139", :method_name=>"ScanMetadata", :taskid=>"5a59e40a-264d-11de-91e4-005056800ef4", :args=>["[ENGN-DMX0611-0B5B] cn071vcce130/cn071vcce130.vmx", "--- \nems: \n  ems: \n    :username: svc_miq\n    :hostname:
#[----] I, [2009-04-11T06:20:34.583893 #31129]  INFO -- : Q-task_id([5a59e40a-264d-11de-91e4-005056800ef4]) MIQ(ExtManagementSystem-get_vim_vm_by_path) EMS: [Virtual Center (10.233.71.130)] Connecting
#[----] I, [2009-04-11T06:20:34.713090 #31129]  INFO -- : Q-task_id([5a59e40a-264d-11de-91e4-005056800ef4]) MIQ(MiqFaultTolerantVim-_connect) EMS: [Virtual Center (10.233.71.130)] [Broker] Connecting with ipaddress: [10.233.71.130], userid: [svc_miq]...
#[----] I, [2009-04-11T06:20:35.384237 #31129]  INFO -- : Q-task_id([5a59e40a-264d-11de-91e4-005056800ef4]) MIQ(MiqFaultTolerantVim-_connect) EMS: 10.233.71.130 is VC, API version: 2.5u2
#[----] I, [2009-04-11T06:20:35.384237 #31129]  INFO -- : Q-task_id([5a59e40a-264d-11de-91e4-005056800ef4]) MIQ(MiqFaultTolerantVim-_connect) EMS: [Virtual Center (10.233.71.130)] [Broker] Connecting to EMS: [Virtual Center (10.233.71.130)]...Complete
#[----] I, [2009-04-11T06:20:35.392914 #31129]  INFO -- : Q-task_id([5a59e40a-264d-11de-91e4-005056800ef4]) MIQ(ExtManagementSystem-get_vim_vm_by_path) EMS: [Virtual Center (10.233.71.130)] Translated path [[ENGN-DMX0611-0B5B] cn071vcce130/cn071vcce130.vmx] to VM
#[----] I, [2009-04-11T06:20:35.564083 #31129]  INFO -- : Q-task_id([5a59e40a-264d-11de-91e4-005056800ef4]) MIQ(ExtManagementSystem-invoke_vim_ws) EMS: [Virtual Center (10.233.71.130)] VM path [[ENGN-DMX0611-0B5B] cn071vcce130/cn071vcce130.vmx] Invoking [createEvmSnapshot]...
#[----] I, [2009-04-11T06:20:41.373278 #31129]  INFO -- : Q-task_id([5a59e40a-264d-11de-91e4-005056800ef4]) MIQ(ExtManagementSystem-invoke_vim_ws) EMS: [Virtual Center (10.233.71.130)] VM path [[ENGN-DMX0611-0B5B] cn071vcce130/cn071vcce130.vmx] Returned with result [snapshot-38120]...
#[----] I, [2009-04-11T06:20:41.383790 #31129]  INFO -- : Q-task_id([5a59e40a-264d-11de-91e4-005056800ef4]) MIQ(ExtManagementSystem-get_vim_vm_by_path) EMS: [Virtual Center (10.233.71.130)] Disconnected
#[----] I, [2009-04-11T06:20:34.264133 #31502]  INFO -- : Q-task_id([job_dispatcher]) MIQ(JobProxyDispatcher-start_job_on_proxy) Job [5a59e40a-264d-11de-91e4-005056800ef4] update: userid: [admin], name: [Scan from Vm CN071VCCE130], target class: [Vm], target id: [106], process type: [VmScan], agent class: [Host], agent id: [7]
#[----] I, [2009-04-11T06:20:34.304218 #31502]  INFO -- : Q-task_id([job_dispatcher]) MIQ(MiqQueue.put): Zone: [TIC], Role: [smartstate], Server: [], Target id: [], Ident: [priority], Message id: [1599596], Class name: [Job], Instance id: [36424], Method name: [signal], Task id: [5a59e40a-264d-11de-91e4-005056800ef4] saved queue entry
    when /Q-task_id\(\[(.*?)\]\) MIQ\(proxy-call_ws\)\: Calling\:\S*\[/ then
      @job_uuid = $1
      work_string = $POSTMATCH
      @job_miq_cmd = "proxy-call_ws"
      _tmp_str = parse_proxy_call_ws_parms(work_string)
      @job_action = @job_miq_cmd + " " + parse_proxy_call_ws_parms(work_string)
      @job_miq_cmd_text = payload

    when /Q-task_id\(\[(.*?)\]\)\s*OS\:\[(.*)\]\s*found on VM\s*\[(.*)\]\.\s*Loaded in \[(.*)\]\s*seconds/ then
#[----] I, [2009-06-23T21:38:48.465100 #4759]  INFO -- : 
#Q-task_id([f98ba372-603d-11de-995a-005056a8784f]) OS:[Linux] found on VM [[Demo] debian40/debian40server.vmx].  Loaded in [11.372065] seconds
#    when /Q-task_id\(\[(.*)\]\)\s*OS\:\[(.*)\]\s*found\s*(.*)\]\.\s*Loaded in \[(.*)\]\s*seconds/ then
      @job_uuid = $1
      @job_miq_cmd = "Loading " + $2 + " VM"
      work_string = $3                         # capture VM identifying info in case job create was missed
      @job_action = @job_miq_cmd + " IN " + $4
      @job_miq_cmd_text = payload
      if /\[(.*?)\](.*?)\// =~ work_string then
        @job_action = @job_action + " [" + $2.strip + "]"  # append to job action so that ACCESS routines can pick this up
      end
    when /Q-task_id\(\[(.*?)\]\)\s*VM snapshot created in\s*\[(.*)\]\s*seconds/ then
      @job_uuid = $1
      @job_miq_cmd = "VM Snapshot " + $2
      @job_action = @job_miq_cmd
      @job_miq_cmd_text = payload
    when /Q-task_id\(\[(.*?)\]\)\s*FileSystem\:\s*(.*)/ then
#[----] I, [2009-06-09T13:05:24.597402 #7794]  INFO -- : Q-task_id([3858bc1a-54f5-11de-9653-005056ac3083]) 
#FileSystem: 1656574692-16128, Mounted on: D:, Type: NTFS, Free bytes: 14424592384

      @job_uuid = $1
      _work_string = $2     
      @job_miq_cmd = "VM FileSystems " 
      @job_action = @job_miq_cmd + "," + _work_string                    # capture the file system info and parse it out later in SQL
      @job_miq_cmd_text = payload   
    when /Q-task_id\(\[(.*?)\]\)\s*Command\s*\[(.*?)\]\s*completed successfully in\s*\[(.*?)\]\s*seconds/ then
#[----] I, [2009-06-12T12:04:42.128251 #32241]  INFO -- :
#Q-task_id([0be62d48-5748-11de-b191-005056b11195]) Command [scanmetadata] completed successfully in [465.018791] seconds.  TaskId:[0be62d48-5748-11de-b191-005056b11195]
      @job_uuid = $1
      @job_miq_cmd = "Command " + $2 + " completed "
      @job_action = @job_miq_cmd + $3
      @job_miq_cmd_text = payload
    when /snapshot_delete\: Enter/ then
    when /snapshot_delete, message\:/ then
#JOB([ec03e3c6-0aed-11df-81eb-00505691443f] Agent state update: state: [Scanning], message: [Scanning completed.]
    when /JOB\(\[(.*?)\]\s*Agent state update\: state\: \[(\S*)\](.*)/ then
      @job_uuid = $1
      @job_miq_cmd = "Command " + $2

      @job_action = "Agent state update: state: [#{$2}]" + $3
      @job_miq_cmd_text = payload
    end
#  end 
  end
end
class MIQ_payload
  attr_reader :miq_cmd, :miq_post_cmd
  def initialize(payload)
#    if /EVM Server/ =~ payload && /Process [I|i]nfo/ =~ payload then
#      puts "#{__FILE__}:#{__LINE__}:#{payload}"
#    end
    @miq_cmd = nil
    @miq_post_cmd = nil
#    if /MIQ\((\S*)\)[\s|\:](.*)$/ =~ payload
    if /MIQ\((\S*)\)?\s*(.*)$/ =~ payload
      @miq_cmd = $1.tr(")"," ").strip
      @miq_post_cmd = $2
    end
    if @miq_cmd == nil || @miq_cmd.size == 0 then
      puts "#{__FILE__}:#{__LINE__}-> unknown MIQ command '#{payload}'"
      @miq_cmd = "unknown"
    end
  end
end
class Parsed_log_line < String
    attr_reader :msgid, :log_type, :log_type_word, :log_pid,  :log_datetime, :log_raw_datetime
    attr_reader :log_datetime_string, :log_tid

    attr_accessor  :payload , :startup_incremented, :payload_word1
    @log_tid = nil
  
  def initialize(log_line)
#puts "#{__FILE__}:#{__LINE__}- #{log_line}\n"
    _work = Array.new
    _work = log_line.split("-- :")
#    if _work[1].class.to_s == "NilClass" then
#    if _work.count < 2 then
#      puts "#{__FILE__}:#{__LINE__}- #{log_line}"
#      return
#    end
begin
    @startup_incremented = false
    @msgid = _work[0].split[0]
    @log_type1 = _work[0].split[1]
    @log_raw_datetime = _work[0].split[2].tr('\[\-T:.','     ')
    @log_type_word = _work[0].split[-1]
    @log_pid = _work[0].split[-2].tr('#]','  ').strip

    _temp_work_pid = @log_pid.split(":")
    if _temp_work_pid.size > 1 then                                         #changes made to log line in May 2010
      @log_tid = _temp_work_pid[1]                                            # necessitate splitting pid from tid
      @log_pid = _temp_work_pid[0]                                            #pid -> process id, tid->task id
    end
    #begin
#    puts " #{__FILE__}:#{__LINE__}- LOG LINE =>'#{log_line}' \n\t _work[1]=> '#{_work[1]}' "
    @payload = _work[1].strip
    @payload_word1 = _work[1].split(" ")[0]
    _time_parts = @log_raw_datetime.split
    # break down log time to convert to seconds
    begin
    _worktime =  Time.gm(_time_parts[0],_time_parts[1],_time_parts[2],
              _time_parts[3],_time_parts[4],_time_parts[5]).to_f 
    #capture fractional seconds and add into tod        
    rescue Exception => e
      puts "error in #{__FILE__}:#{__LINE__}\n\t log line is '#{log_line}'\n\t raw_datetime is #{@log_raw_datetime}"
      puts "backtrace of the exception:\n #{e.backtrace.join("\n")}"
    end
    _seconds = (_time_parts[6].to_i) * (0.000001)       
      @log_datetime = _worktime.to_f + _seconds
#      puts "#{_worktime} plus #{_seconds}"
#      puts "#{@log_datetime}"
    @log_datetime_string = _time_parts[1] + "/" + _time_parts[2] + "/" + _time_parts[0].strip + " " +
                           _time_parts[3] + ":" + _time_parts[4 ] + ":" +_time_parts[5] + '.' + _time_parts[6].strip
    rescue Exception => e
      puts "error in #{__FILE__}:#{__LINE__}\n\t log line is '#{log_line}'\n\t raw_datetime is #{@log_raw_datetime}"
      puts "backtrace of the exception:\n #{e.backtrace.join("\n")}"
      end
  end
#  def msgid
#  @msgid
#  end
#  def log_type
#    @log_type
#  end
#  def log_type_word
#    @log_type_word
#  end
#  def log_pid
#    @log_pid
#  end
#  def payload
#    @payload
#  end
#  def log_datetime
#    @log_datetime
#  end
  def splice_payload(part1,part2)
    @payload = part1.to_s + part2.to_s
  end
end

