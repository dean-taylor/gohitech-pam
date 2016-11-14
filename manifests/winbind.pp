define pam::d::winbind (
  $type,
  $cached_login          = false,
  $control,
  $debug   = undef,
  $debug_state = undef,
  $krb5_auth             = false,
  $krb5_ccache_type      = "",
  $mkhomedir             = false,
  $require_membership_of = [],
  $silent                = false,
  $service,
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
