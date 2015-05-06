# == Class: askbot::params
# This class holds the default parameters for askbot
class askbot::params {

  # askbot services
  $redis_enabled   = false
  $solr_enabled    = false

  # redis defaults
  $redis_prefix     = 'askbot'
  $redis_port       = undef
  $redis_max_memory = undef
  $redis_bind       = undef
  $redis_password   = undef

  # askbot source repository
  $askbot_repo     = 'https://github.com/ASKBOT/askbot-devel.git'
  $askbot_revision = 'master'

  $askbot_debug    = false

  # database settings
  $db_provider     = 'mysql'
  $db_name         = undef
  $db_user         = undef
  $db_password     = undef
  $db_host         = 'localhost'

  # directories
  $dist_root       = '/srv/dist'
  $site_root       = '/srv/askbot-site'

  # web server settings
  $www_user        = 'www-data'
  $www_group       = 'www-data'

  # ssl configuration
  $site_ssl_enabled             = false
  $site_ssl_cert_file_contents  = undef
  $site_ssl_key_file_contents   = undef
  $site_ssl_chain_file_contents = undef
  $site_ssl_cert_file           = ''
  $site_ssl_key_file            = ''
  $site_ssl_chain_file          = ''

  # custom theme
  $custom_theme_enabled = false
  $custom_theme_name    = undef
}