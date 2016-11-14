class pam::authconf (
  $access         = false,
  $access_listsep = undef,
  $script         = false,
  $script_onerr   = 'fail',		# success|fail
  $succeed_if_uid = $pam::params::succeed_if_uid,
  $winbind        = false,
  $winbind_krb5_ccache_type = $pam::params::winbind_krb5_ccache_type,
  $winbind_require_membership_of = [],
) inherits pam::params {
  validate_bool($access,$script,$winbind)
  if $access_listsep { validate_re($access_listsep,'^.$') }
  validate_re($script_onerr,'^fail|success$')
  validate_integer($succeed_if_uid,2000)
  validate_re($winbind_krb5_ccache_type,'^FILE|KEYRING$')
  validate_array($winbind_require_membership_of)

  $rules_default = [
    { order=>1,type=>'auth',    control=>'required',  module=>'env', },
    { order=>2,type=>'auth',    control=>'sufficient',module=>'unix',args=>['nullok','try_first_pass',], },
    { order=>3,type=>'auth',    control=>'requisite', module=>'succeed_if',args=>["uid >= ${succeed_if_uid}",'quiet_success',], },
    { order=>4,type=>'auth',    control=>'required',  module=>'deny', },
    { order=>1,type=>'account', control=>'required',  module=>'unix', },
    { order=>2,type=>'account', control=>'sufficient',module=>'localuser', },
    { order=>3,type=>'account', control=>'sufficient',module=>'succeed_if',args=>["uid < ${succeed_if_uid}",'quiet',], },
    { order=>4,type=>'account', control=>'required',  module=>'permit', },
    { order=>1,type=>'password',control=>'requisite', module=>'pwquality',args=>['try_first_pass','local_users_only','retry=3','authtok_type=',], },
    { order=>2,type=>'password',control=>'sufficient',module=>'unix',args=>['md5','shadow','nullok','try_first_pass','use_authtok',], },
    { order=>3,type=>'password',control=>'required',  module=>'deny', },
    { order=>1,type=>'session', control=>'optional',  module=>'keyinit',args=>['revoke',], },
    { order=>2,type=>'session', control=>'required',  module=>'limits', },
    { order=>3,type=>'-session',control=>'optional',  module=>'systemd' },
    { order=>4,type=>'session', control=>'[success=1 default=ignore]',module=>'succeed_if',args=>['service in crond','quiet','use_uid',], },
    { order=>5,type=>'session', control=>'required',  module=>'unix', },
  ]

  ::pam::service { 'password-auth-puppet':
    rules => $rules_default,
  }

  ::pam::service { 'system-auth-puppet':
    rules => $rules_default,
  }

  if $winbind {
    $cached_login = ['cached_login',]
    $krb5_auth = ['krb5_auth',"krb5_ccache_type=${krb5_ccache_type}",]
    $rules_winbind = [
      { type=>'auth',order=>4,control=>'sufficient',module=>'winbind',args=>concat($cached_login,$krb5_auth,['use_first_pass',]), },
      { type=>'account',order=>4,control=>'[default=bad success=ok user_unknown=ignore]',module=>'winbind',args=>concat($cached_login,$krb5_auth), },
      { type=>'password',order=>4,control=>'sufficient',module=>'winbind',args=>concat($krb5_auth,['use_authtok',]), },
      { type=>'session',order=>4,control=>'optional',module=>'winbind',args=>concat($cached_login,krb5_auth), },
    ]

    ::pam::service { 'system-auth-puppet_winbind':
      service => 'system-auth-puppet',
      rules   => $rules_winbind,
    }
    ::pam::service { 'password-auth-puppet_winbind':
      service => 'password-auth-puppet',
      rules   => $rules_winbind,
    }
  }
}
