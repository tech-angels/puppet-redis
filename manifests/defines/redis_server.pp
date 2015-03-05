class redis::server(
  $port            = '6379',
  $master_ip       = false,
  $master_port     = 6379,
  $master_password = false,
  $save            = true
) {
  include redis

  # Redis
  package { 'redis-server':
    ensure => installed,
  } ->
  file { 
    "/etc/redis/redis.conf":
      ensure	=> present,
      content	=> template("redis/redis.conf.erb"),
      notify	=> Service["redis-server"];
  } ->
  # Ensure Redis is running
  service {
    "redis-server":
      enable	=> true,
      ensure	=> running,
  }
}
