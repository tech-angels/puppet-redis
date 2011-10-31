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
$bin,
$port='6379',
$hour=undef,
$minute=undef,
$month=undef,
$monthday=undef,
$weekday=undef
) {
  # Schedule saves
  cron {
    "Scheduled Redis snapshot: $name":
      command	=> "$bin/redis-cli -p $port SAVE",
      user	=> $user,
      hour	=> $hour,
      minute	=> $minute,
      month	=> $month,
      monthday	=> $monthday,
      weekday	=> $weekday;
  }
}
