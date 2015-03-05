/*

define: redis::scheduled_snapshot

This resource installs a cron job that issues the BGSAVE command to redis so as to make it
dump its data on disk in /var/lib/redis

Parameters:
- user: POSIX user that is running the redis server. (default: "redis")

Plus these cron resourse parameters:
- hour
- minute
- month
- monthday
- weekday 

*/
class redis::scheduled_snapshot(
$port='6379',
$hour=undef,
$minute=undef,
$month=undef,
$monthday=undef,
$weekday=undef,
$archive_dir=false,
$max_archive_age='7'
) {


  # Create archival directory
  if $archive_dir {
    if !defined(File[$archive_dir]) {
      file { $archive_dir:
        ensure => directory,
        owner  => $user,
        mode   => '0700',
      }
    }

    # Clean it up of old files
    cron { "clean up Redis snapshots":
      command => "find ${archive_dir} -mtime +${max_archive_age} -exec rm -f {} \\;",
      user    => $user,
      hour    => 0,
      minute  => 0,
    }

    $backup_command = "sh -c \"[ -f ${db_dir}/dump.rdb ] && mv ${db_dir}/dump.rdb ${archive_dir}/\${NOW}.rdb ; /usr/bin/redis-cli -p ${port} BGSAVE\""
  } else {
    $backup_command = "/usr/bin/redis-cli -p ${port} BGSAVE"
  }
  

  # Compute command
  
  


  # Schedule saves
  cron {
    "Scheduled Redis snapshot:":
      environment => 'NOW=$(date +%Y-%m-%d-%H-%M)',
      command	=> $backup_command,
      user	=> 'redis',
      hour	=> $hour,
      minute	=> $minute,
      month	=> $month,
      monthday	=> $monthday,
      weekday	=> $weekday;
  }
}
