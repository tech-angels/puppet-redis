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
    $bin,
    $owner = 'redis',
    $group = 'redis'
) {
    # Create bin directory if it doesn't exist
    exec { "Create Redis bin directory $bin":
      command => "/bin/mkdir -p $bin",
      unless  => "/usr/bin/test -d $bin",
    }

    case $version {
        default: {
             file { "${path}/redis_${name}":
                 ensure => "directory",
                 owner => root,
                 group => root
             }
             # Use archive if present
             exec {
               "redis_code_from_archive $name":
                 command	=> "/bin/ln -s /var/lib/puppet/modules/redis/redis_${version}.tar.gz ${path}/redis_${version}/redis_${version}.tar.gz && tar --strip-components 1 -xzvf redis_${version}.tar.gz",
                 cwd		=> "${path}/redis_${name}",
                 onlyif		=> "/usr/bin/test -f /var/lib/puppet/modules/redis/redis_${version}.tar.gz",
                 creates	=> "${path}/redis_${name}/redis.conf",
                 require	=> File["${path}/redis_${name}"],
                 before		=> Exec["make ${name}"]
             }
             exec { "redis_code $name": 
                  command	=>"wget --no-check-certificate http://github.com/antirez/redis/tarball/${version} -O redis_${version}.tar.gz && tar --strip-components 1 -xzvf redis_${version}.tar.gz",
                  cwd		=> "${path}/redis_${name}",
                  unless	=> "/usr/bin/test -f /var/lib/puppet/modules/redis/redis_${version}.tar.gz",
                  creates	=> "${path}/redis_${name}/redis.conf",
                  require	=> File["${path}/redis_${name}"],
                  before	=> Exec["make ${name}"]
             }
        }
        source: {
             exec { "git clone git://github.com/antirez/redis.git redis_${name}":
                 cwd => "${path}",
                 creates => "${path}/redis_${name}/.git/HEAD",
                 before => Exec["make ${name}"]
             }
        }
    }
    exec { "make ${name}":
         command => "make && find . -executable -and -name 'redis-*' -exec mv {} ${bin}/ \\;",
         cwd => "${path}/redis_${name}",
         creates => "${bin}/redis-server",
    }
}
