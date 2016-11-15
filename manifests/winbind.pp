define pam::d::winbind (
  $control,
  $debug   = undef,
  $debug_state = undef,
  $enable_cached_login   = false,
  $enable_krb5_auth      = false,
  $enable_mkhomedir      = false,
  $krb5_ccache_type      = "",
  $require_membership_of = [],
  $silent                = false,
  $service,
  $type,
) {
  if ! defined(Concat["/etc/pam.d/${service}"]) {
    concat { "/etc/pam.d/${service}":
      ensure  => present,
      content => template("pam/pam.d/winbind.erb"),
      warn    => true,
    }
  }

#  concat::fragment { "/etc/pam.d/${service}_${type}_winbind":
}

class pam::winbind (
  $krb5_ccache_type = $pam::params::winbind_krb5_ccache_type,
  $packages = $pam::params::winbind_packages,
) inherits pam::params {
  package { $packages:
    ensure => present,
  }
}
