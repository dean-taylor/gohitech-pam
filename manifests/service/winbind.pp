define pam::service::winbind (
  $type,
  $control,
  $args,
#  $cached_login          = false,
#  $debug                 = undef,
#  $debug_state           = undef,
#  $krb5_auth             = false,
#  $krb5_ccache_type      = "",
#  $mkhomedir             = false,
#  $require_membership_of = [],
#  $silent                = false,
  $service,
) {
  if ! defined(Concat["/etc/pam.d/${service}"]) {
    concat { "/etc/pam.d/${service}":
      ensure  => present,
      warn    => true,
    }
  }

  concat::fragment { "/etc/pam.d/${service}_${type}_winbind":
    target => "/etc/pam.d/${service}",
    content => template("pam/pam.d/winbind.erb")
  }
}
