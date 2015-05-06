# == Class: askbot::install
# This class installs the required packages for askbot
class askbot::install (
  $db_provider     = $::askbot::params::db_provider,
  $dist_root       = $::askbot::params::dist_root,
  $askbot_repo     = $::askbot::params::askbot_repo,
  $askbot_revision = $::askbot::params::askbot_revision,
  $redis_enabled   = $::askbot::params::redis_enabled,
  $solr_enabled    = $::askbot::params::solr_enabled,
) {

  if !defined(Package['git']) {
    package { 'git':
      ensure => present,
    }
  }

  if !defined(Package['python-pip']) {
    package { 'python-pip':
      ensure => present,
    }
  }

  if !defined(Package['python-dev']) {
    package { 'python-dev':
      ensure => present,
    }
  }

  case $db_provider {
    'mysql': {
      $db_provider_package = 'python-mysqldb'
    }
    'pgsql': {
      $db_provider_package = 'python-psycopg2'
    }
    default: {
      fail("Unsupported database provider: ${db_provider}")
    }
  }
  if ! defined(Package[$db_provider_package]) {
    package { $db_provider_package:
      ensure => present,
    }
  }

  if $redis_enabled {
    package { 'django-redis-cache':
      ensure   => present,
      provider => 'pip',
    }
  }

  include apache::mod::wsgi

  if $solr_enabled {
    package { [ 'django-haystack', 'pysolr' ]:
      ensure   => present,
      provider => 'pip',
    }
  }

  # Notice: we are not using a pre-packaged askbot, so it is mandatory
  # to install pip dependencies, and execute setup.py install when
  # local askbot repo have been refreshed.

  # TODO: include stopforumspan in requirements.txt ?
  package { 'stopforumspam':
    ensure   => present,
    provider => 'pip',
    before   => Exec['askbot-install'],
  }

  exec { 'pip-requirements-install':
    path        => [ '/bin', '/sbin' , '/usr/bin', '/usr/sbin', '/usr/local/bin' ],
    command     => "pip install -q -r ${dist_root}/askbot/askbot_requirements.txt",
    cwd         => "${dist_root}/askbot",
    logoutput   => on_failure,
    subscribe   => Vcsrepo["${dist_root}/askbot"],
    refreshonly => true,
  }

  exec { 'askbot-install':
    path        => [ '/bin', '/sbin' , '/usr/bin', '/usr/sbin', '/usr/local/bin' ],
    cwd         => "${dist_root}/askbot",
    command     => 'python setup.py -q install',
    logoutput   => on_failure,
    subscribe   => Vcsrepo["${dist_root}/askbot"],
    refreshonly => true,
  }

}