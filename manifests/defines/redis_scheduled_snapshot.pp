/*

define: redis::scheduled_snapshot

This resource installs a cron job that issues the SAVE command to redis so as to make it
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
define redis::scheduled_snapshot(
$user='redis',
$hour=undef,
$minute=undef,
$month=undef,
$monthday=undef,
$weekday=undef
) {
  # Schedule saves
  cron {
    "Scheduled Redis snapshot: $name":
      command	=> '/usr/local/bin/redis-cli SAVE',
      user	=> $user,
      hour	=> $hour,
      minute	=> $minute,
      month	=> $month,
      monthday	=> $monthday,
      weekday	=> $weekday;
  }
}
