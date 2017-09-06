define pam::d::winbind (
  $control,
  $service,
  $type,
  $debug   = undef,
  $debug_state = undef,
  $enable_cached_login   = false,
  $enable_krb5_auth      = false,
  $enable_mkhomedir      = false,
  $krb5_ccache_type      = '',
  $require_membership_of = [],
  $silent                = false,
) {
  if ! defined(Concat["/etc/pam.d/${service}"]) {
    concat { "/etc/pam.d/${service}":
      ensure  => present,
      content => template('pam/pam.d/winbind.erb'),
      warn    => true,
    }
  }

#  concat::fragment { "/etc/pam.d/${service}_${type}_winbind":
}

define pam::winbind::service (
  $rules,
  $service = $name,
) {
  validate_array($rules)
  validate_string($service)

  $_rules = ght_merge_each($rules,{service=>$service,})

  ::pam::service::rule { $_rules: }
}

class pam::winbind (
  $cached_login          = true,
  $krb5_auth             = true,
  $krb5_ccache_type      = $pam::params::winbind_krb5_ccache_type,
  $require_membership_of = undef,		# 'UNIWA\SCI-NIX-029$,UNIWA\00078081,UNIWA\90078081'
  $services              = [ 'system-auth-puppet', ],	# undef
  $packages              = $pam::params::winbind_packages,
) inherits pam::params {
  # validate

  package { $packages:
    ensure => present,
  }

  if $cached_login { $_cached_login = ['cached_login'] }
  if $krb5_auth { $_krb5_auth = ['krb5_auth',"krb5_ccache_type=$krb5_ccache_type"] }
  if $require_membership_of {
    if is_string($require_membership_of) { $_require_membership_of = ["require_membership_of=$require_membership_of"] }
  }

  if $services {
    $_services = {
      'system-auth-puppet_winbind' => {
        service => 'system-auth-puppet',
        rules => [
          { type=>'auth',module=>'winbind',control=>'sufficient',args=>concat($_cached_login,$_krb5_auth,$_require_membership_of,['use_first_pass']) },
          { type=>'account',module=>'winbind',control=>'[default=bad success=ok user_unknown=ignore]',args=>concat($_cached_login,$_krb5_auth) },
          { type=>'password',module=>'winbind',control=>'sufficient',args=>concat($_krb5_auth,['use_authtok']) },
          { type=>'session',module=>'winbind',control=>'optional',args=>concat($_cached_login,$_krb5_auth) },
        ]
      }
    }
    create_resources(pam::service,$_services)

#    $_rules = [
#      { service=>'system-auth-puppet',type=>'auth',module=>'winbind',control=>'sufficient',args=>concat($_cached_login,$_krb5_auth,$_require_membership_of,['use_first_pass']) },
#      { service=>'system-auth-puppet',type=>'account',module=>'winbind',control=>'[default=bad success=ok user_unknown=ignore]',args=>concat($_cached_login,$_krb5_auth) },
#      { service=>'system-auth-puppet',type=>'password',module=>'winbind',control=>'sufficient',args=>concat($_krb5_auth,['use_authtok']) },
#      { service=>'system-auth-puppet',type=>'session',module=>'winbind',control=>'optional',args=>concat($_cached_login,$_krb5_auth) },
#    ]
#    ::pam::service::rule { $_rules: }
  }
}
