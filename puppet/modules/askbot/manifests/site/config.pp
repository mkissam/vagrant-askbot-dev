# == Class: askbot::site::config
# This class configure and askbot site
class askbot::site::config (
  $site_root            = $::askbot::params::site_root,
  $dist_root            = $::askbot::params::dist_root,
  $db_provider          = $::askbot::params::db_provider,
  $db_name              = $::askbot::params::db_name,
  $db_user              = $::askbot::params::db_user,
  $db_password          = $::askbot::params::db_password,
  $db_host              = $::askbot::params::db_host,
  $askbot_debug         = $::askbot::params::askbot_debug,
  $smtp_host            = 'localhost',
  $smtp_port            = '25',
  $redis_enabled        = $::askbot::params::redis_enabled,
  $redis_prefix         = $::askbot::params::redis_prefix,
  $redis_port           = $::askbot::params::redis_port,
  $redis_max_memory     = $::askbot::params::redis_max_memory,
  $redis_bind           = $::askbot::params::redis_bind,
  $redis_password       = $::askbot::params::redis_password,
  $custom_theme_enabled = $::askbot::params::custom_theme_enabled,
  $custom_theme_name    = $::askbot::params::custom_theme_name,
  $solr_enabled         = $::askbot::params::solr_enabled,
) {

  case $db_provider {
    'mysql': {
      $db_engine = 'django.db.backends.mysql'
    }
    'pgsql': {
      $db_engine = 'django.db.backends.postgresql_psycopg2'
    }
    default: {
      fail("Unsupported database provider: ${db_provider}")
    }
  }

  file { "${site_root}/config":
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => File[$site_root],
  }

  $setup_templates = [ '__init__.py', 'manage.py', 'urls.py', 'django.wsgi']
  askbot::site::setup_template { $setup_templates:
    template_path => "${dist_root}/askbot/askbot/setup_templates",
    dest_dir      => "${site_root}/config",
    require       => File["${site_root}/config"],
  }

  file { "${site_root}/config/settings.py":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('askbot/settings.py.erb'),
    require => File["${site_root}/config"],
  }

  # post-configuration
  Exec {
    path => ['/bin', '/usr/bin', '/sbin', '/usr/sbin'],
    logoutput => on_failure,
  }

  $post_config_dependency = [
      File["${site_root}/static"],
      File["${site_root}/log"],
      Askbot::Site::Setup_template[ $setup_templates ],
      File["${site_root}/config/settings.py"],
      Vcsrepo["${dist_root}/askbot"],
    ]

  exec { 'askbot-static-generate':
    cwd         => "${site_root}/config",
    command     => 'python manage.py collectstatic --noinput',
    require     => $post_config_dependency,
    subscribe   => [Vcsrepo["${dist_root}/askbot"], File["${site_root}/config/settings.py"] ],
    refreshonly => true,
  }

  exec { 'askbot-syncdb':
    cwd         => "${site_root}/config",
    command     => 'python manage.py syncdb --noinput',
    require     => $post_config_dependency,
    subscribe   => [Vcsrepo["${dist_root}/askbot"], File["${site_root}/config/settings.py"] ],
    refreshonly => true,
  }

  # TODO: end of chain: notify httpd, celeryd
  exec { 'askbot-migrate':
    cwd         => "${site_root}/config",
    command     => 'python manage.py migrate --noinput',
    require     => Exec['askbot-syncdb'],
    subscribe   => [Vcsrepo["${dist_root}/askbot"], File["${site_root}/config/settings.py"] ],
    refreshonly => true,
  }

}