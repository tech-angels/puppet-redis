/*

Define: redis_source

This resource compiles and install a Redis server

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
 - downloads (if needed) and compiles Redis.
 - Install binaries in $bin directory.

Sample usage:
redis_source {
  redis:
    version	=> 'v2.0.4-stable';
}
*/
define redis_source(
    $version = 'v1.3.10',
    $path = '/usr/local/src',
    $bin = '/usr/local/bin',
    $owner = 'redis',
    $group = 'redis'
) {
    case $version {
        default: {
             file { redis_folder:
                 path => "${path}/redis_${version}",
                 ensure => "directory",
                 owner => root,
                 group => root
             }
             # Use archive if present
             exec {
               redis_code_from_archive:
                 command	=> "/bin/ln -s /var/lib/puppet/modules/redis/redis_${version}.tar.gz ${path}/redis_${version}/redis_${version}.tar.gz && tar --strip-components 1 -xzvf redis_${version}.tar.gz",
                 cwd		=> "${path}/redis_${version}",
                 onlyif		=> "/usr/bin/test -f /var/lib/puppet/modules/redis/redis_${version}.tar.gz",
                 creates	=> "${path}/redis_${version}/redis.c",
                 require	=> File["redis_folder"],
                 before		=> Exec["make ${version}"]
             }
             exec { redis_code: 
                  command	=>"wget --no-check-certificate http://github.com/antirez/redis/tarball/${version} -O redis_${version}.tar.gz && tar --strip-components 1 -xzvf redis_${version}.tar.gz",
                  cwd		=> "${path}/redis_${version}",
                  unless	=> "/usr/bin/test -f /var/lib/puppet/modules/redis/redis_${version}.tar.gz",
                  creates	=> "${path}/redis_${version}/redis.c",
                  require	=> File["redis_folder"],
                  before	=> Exec["make ${version}"]
             }
        }
        source: {
             exec { "git clone git://github.com/antirez/redis.git redis_${version}":
                 cwd => "${path}",
                 creates => "${path}/redis_${version}/.git/HEAD",
                 before => Exec["make ${version}"]
             }
        }
    }
    exec { "make ${version}":
         command => "make && find . -executable -and -name 'redis-*' -exec mv {} ${bin}/ \;",
         cwd => "${path}/redis_${version}",
         creates => "${bin}/redis-server",
    }
    file { db_folder:
        path => "/var/lib/redis",
        ensure => "directory",
        owner => $owner,
        group => $group,
    }
    file { "/etc/init.d/redis-server":
         content => template("redis/redis-server.erb"),
         owner => root,
         group => root,
         mode => 744,
    }
}
