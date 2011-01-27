/*

Define: redis::server

This resource compiles and install a Redis server and ensure it is running

Parameters:
  $version:
    Redis version to install.
  $path:
    Path where to download and compile Redis sources.
  $bin:
    Path where to install Redis's executables.
  $owner:
    Redis POSIX account.
  $group
    Redis POSIX group.

Actions:
 - Downloads and compiles Redis.
 - Install binaries in $bin directory.
 - Ensure the Redis daemon is running.

Sample usage:
redis::server {
  redis:
    version	=> 'v2.0.4-stable';
}
*/
define redis::server(
    $version,
    $path = '/usr/local/src',
    $bin = '/usr/local/bin',
    $owner = 'redis',
    $group = 'redis'
) {
  include redis
  redis_source {
    redis:
      version	=> $version,
      path	=> $path,
      bin	=> $bin,
      owner	=> $owner,
      group	=> $group;
  }

  # Ensure Redis is running
  service {
    'redis-server':
      enable	=> true,
      ensure	=> running,
      pattern	=> '/usr/local/bin/redis-server';
  }
}
