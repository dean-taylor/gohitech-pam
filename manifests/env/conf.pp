define pam::env::set (
  $variable = $name,
  $default  = '',
  $override = '',
) {
  include pam::env::conf

  concat::fragment { "pam_env_conf_${variable}":
    target  => '/etc/security/pam_env.conf',
    content => "${variable} DEFAULT=\"${default}\" OVERRIDE=\"${override}\"\n"
  }
}

class pam::env::conf (
  $conffile = '/etc/security/pam_env.conf',
) inherits pam::params {
  include pam

  concat { '/etc/security/pam_env.conf':
    ensure => present,
  }
}
