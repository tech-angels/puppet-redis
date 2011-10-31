/*

Define: redis::server

This resource compiles and install a Redis server and ensure it is running

Parameters:
- version: Redis version to install.
- path: Path where to download and compile Redis sources. (optional)
- bin: Path where to install Redis's executables. (optional)
- owner: Redis POSIX account. (default: redis)
- group: Redis POSIX group. (default: redis)
- port: redis port, default: 6379
- master_ip: master's IP, to make that server a slave. (optional)
- master_port: master's port. (default 6379)
- master_password: password to access master. (optional)

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
  $group = 'redis',
  $port='6379',
  $master_ip=false,
  $master_port=6379,
  $master_password=false
) {
  include redis
  redis_source {
    $name:
      version	=> $version,
      path	=> $path,
      bin	=> $bin,
      owner	=> $owner,
      group	=> $group;
  }

  # Redis configuration
  file { 
    "/etc/redis-$version.conf":
      ensure	=> present,
      content	=> template("redis/redis.conf.erb"),
      notify	=> Service["redis-server-$version"];
  }

  # Logrotate
  file {
    "/etc/logrotate.d/redis-$version":
      content	=> template('redis/logrotate.erb'),
  }

  # DB folder
  file { "/var/lib/redis-$version":
    ensure => "directory",
    owner => $owner,
    group => $group,
  }

  # Install init.d file
  file { "/etc/init.d/redis-server-$version":
    content => template("redis/redis-server.erb"),
    owner => root,
    group => root,
    mode => 744,
  }

  # Ensure Redis is running
  service {
    "redis-server-$version":
      enable	=> true,
      ensure	=> running,
      pattern	=> "$bin/redis-server /etc/redis-$version.conf";
  }
}
