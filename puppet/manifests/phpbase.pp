# Enable XDebug ("0" | "1")
$use_xdebug = "0"

# Default path
Exec 
{
  path => ["/usr/bin", "/bin", "/usr/sbin", "/sbin", "/usr/local/bin", "/usr/local/sbin"]
}

exec 
{ 
    'apt-get update':
        command => '/usr/bin/apt-get update',
        require => Exec['add php55 apt-repo']
}

include bootstrap
include other
include php55 #specific setup steps for 5.5
include php
include apache


package { 'git-core':
    ensure => present,
  }

  exec { 'install composer':
    command => 'curl -s https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin',
    require => Package['php5-cli'],
    unless => "[ -f /usr/local/bin/composer ]"
}

exec { 'global composer':
  command => "sudo mv /usr/local/bin/composer.phar /usr/local/bin/composer",
  require => Exec['install composer'],
  unless => "[ -f /usr/local/bin/composer ]"
}

# Check to see if there's a composer.json and app directory before we delete everything
# We need to clean the directory in case a .DS_STORE file or other junk pops up before
# the composer create-project is called
exec { 'clean www directory': 
  command => "/bin/sh -c 'cd /var/www && find -mindepth 1 -delete'",
  unless => [ "test -f /var/www/composer.json", "test -d /var/www/app" ],
  require => Package['apache2']
}
