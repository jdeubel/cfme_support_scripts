# Delete any records older than this:
ARCHIVE_CUTOFF = Time.now.utc - 1.month
ORPHANED_CUTTOFF = Time.now.utc - 1.month
# If true, do not delete anything; only report:
REPORT_ONLY = true

old_logger = $log
$log = VMDBLogger.new(STDOUT)
$log.level = Logger::INFO

query = Vm.where("updated_on < ? or updated_on IS NULL", ORPHANED_CUTTOFF)
orphaned = 0
#archived = 0

$log.info "Searching for orphaned VMs older than #{ORPHANED_CUTTOFF} UTC."
$log.info "Expecting to prune #{query.all_orphaned.count} of the #{query.count} older vms"
if REPORT_ONLY
  $log.info "Reporting only; no rows will be deleted."
else
  $log.warn "Will delete any matching records."
end

query.all_orphaned.find_in_batches do |vms|
  vms.each do |vm|
    begin
      orphaned += 1
      unless REPORT_ONLY
        $log.info "Deleting orphaned VM '#{vm.name}' (id #{vm.id})"
        vm.destroy
      end
    rescue => err
      $log.error("#{err} #{err.backtrace.join("\n")}")
    end
  end
end

$log.info "Completed purging orphaned VMs. #{REPORT_ONLY ? 'Found' : 'Purged'} #{orphaned} orphaned VMs."

$log.close
$log = old_logger               
