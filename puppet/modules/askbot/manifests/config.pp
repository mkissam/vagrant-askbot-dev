# == Class: askbot::config
# This class sets up askbot install
#
# == Parameters
#
# == Actions
class askbot::config (
  $site_root                    = $::askbot::params::site_root,
  $dist_root                    = $::askbot::params::dist_root,
  $www_group                    = $::askbot::params::www_group,
  $db_provider                  = $::askbot::params::db_provider,
  $db_name                      = $::askbot::params::db_name,
  $db_user                      = $::askbot::params::db_user,
  $db_password                  = $::askbot::params::db_password,
  $db_host                      = $::askbot::params::db_host,
  $askbot_debug                 = $::askbot::params::askbot_debug,
  $redis_enabled                = $::askbot::params::redis_enabled,
  $redis_prefix                 = $::askbot::params::redis_prefix,
  $redis_port                   = $::askbot::params::redis_port,
  $redis_max_memory             = $::askbot::params::redis_max_memory,
  $redis_bind                   = $::askbot::params::redis_bind,
  $redis_password               = $::askbot::params::redis_password,
  $site_ssl_enabled             = $::askbot::params::site_ssl_enabled,
  $site_ssl_cert_file_contents  = $::askbot::params::site_ssl_cert_file_contents,
  $site_ssl_key_file_contents   = $::askbot::params::site_ssl_key_file_contents,
  $site_ssl_chain_file_contents = $::askbot::params::site_ssl_chain_file_contents,
  $site_ssl_cert_file           = $::askbot::params::site_ssl_cert_file,
  $site_ssl_key_file            = $::askbot::params::site_ssl_key_file,
  $site_ssl_chain_file          = $::askbot::params::site_ssl_chain_file,
  $site_name                    = undef,
  $custom_theme_enabled         = $::askbot::params::custom_theme_enabled,
  $custom_theme_name            = $::askbot::params::custom_theme_name,
  $solr_enabled                 = $::askbot::params::solr_enabled,
) {
  file { $site_root:
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }

  file { "${site_root}/upfiles":
    ensure  => directory,
    owner   => 'root',
    group   => $www_group,
    mode    => '0775',
    require => File[$site_root],
  }

  if $site_ssl_enabled == true {
    class { 'askbot::site::ssl':
      site_ssl_cert_file_contents  => $site_ssl_cert_file_contents,
      site_ssl_key_file_contents   => $site_ssl_key_file_contents,
      site_ssl_chain_file_contents => $site_ssl_chain_file_contents,
      site_ssl_cert_file           => $site_ssl_cert_file,
      site_ssl_key_file            => $site_ssl_key_file,
      site_ssl_chain_file          => $site_ssl_chain_file,
    }
  }

  class { 'askbot::site::http':
    site_root => $site_root,
    site_name => $site_name,
  }

  class { 'askbot::site::celeryd':
    site_root => $site_root,
  }

  class { 'askbot::site::config':
    site_root            => $site_root,
    db_provider          => $db_provider,
    db_name              => $db_name,
    db_user              => $db_user,
    db_password          => $db_password,
    db_host              => $db_host,
    askbot_debug         => $askbot_debug,
    redis_enabled        => $redis_enabled,
    redis_prefix         => $redis_prefix,
    redis_port           => $redis_port,
    redis_max_memory     => $redis_max_memory,
    redis_bind           => $redis_bind,
    redis_password       => $redis_password,
    custom_theme_enabled => $custom_theme_enabled,
    custom_theme_name    => $custom_theme_name,
    solr_enabled         => $solr_enabled,
  }

  class { 'askbot::site::static':
    site_root => $site_root,
  }

  class { 'askbot::site::log':
    site_root => $site_root,
    www_group => $www_group,
  }

  class { 'askbot::site::cron':
    site_root => $site_root,
  }

}