class pam::authconf (
  $access           = false,
  $access_listsep   = undef,
  $enable_mkhomedir = true,
  $enable_script    = false,
  $mkhomedir_module = $pam::params::mkhomedir_module,
  $pwquality      = $pam::params::pam_pwquality,
  $script_onerr     = 'fail',		# success|fail
  $succeed_if_uid = $pam::params::succeed_if_uid,
  $winbind        = false,
  $winbind_cached_login = false,
  $winbind_krb5_ccache_type = $pam::params::winbind_krb5_ccache_type,
  $winbind_require_membership_of = undef,
) inherits pam::params {
  validate_bool($access,$enable_mkhomedir,$enable_script,$winbind,$winbind_cached_login)
  if $access_listsep { validate_re($access_listsep,'^.$') }
  validate_re($script_onerr,'^fail|success$')
  validate_integer($succeed_if_uid,2000)
  validate_re($winbind_krb5_ccache_type,'^FILE|KEYRING$')
  if $winbind_require_membership_of { validate_array($winbind_require_membership_of) }

  $rules_default = [
    { order=>1,type=>'auth',    control=>'required',  module=>'env', },
    { order=>1,type=>'auth',    control=>'sufficient',module=>'unix',args=>['nullok','try_first_pass',], },
    { order=>2,type=>'auth',    control=>'requisite', module=>'succeed_if',args=>["uid >= ${succeed_if_uid}",'quiet_success',], },
    { order=>9,type=>'auth',    control=>'required',  module=>'deny', },
    { order=>1,type=>'account', control=>'required',  module=>'unix',args=>["broken_shadow",] },
    { order=>2,type=>'account', control=>'sufficient',module=>'localuser', },
    { order=>2,type=>'account', control=>'sufficient',module=>'succeed_if',args=>["uid < ${succeed_if_uid}",'quiet',], },
    { order=>9,type=>'account', control=>'required',  module=>'permit', },
    { order=>1,type=>'password',control=>'requisite', module=>"${pwquality}",args=>['try_first_pass','local_users_only','retry=3','authtok_type=',], },
    { order=>2,type=>'password',control=>'sufficient',module=>'unix',args=>['md5','shadow','nullok','try_first_pass','use_authtok',], },
    { order=>9,type=>'password',control=>'required',  module=>'deny', },
    { order=>1,type=>'session', control=>'optional',  module=>'keyinit',args=>['revoke',], },
    { order=>1,type=>'session', control=>'required',  module=>'limits', },
    { order=>4,type=>'session', control=>'[success=1 default=ignore]',module=>'succeed_if',args=>['service in crond','quiet','use_uid',], },
    { order=>5,type=>'session', control=>'required',  module=>'unix', },
  ]
  ::pam::service { 'password-auth-puppet':
    rules => $rules_default,
  }
  ::pam::service { 'system-auth-puppet':
    rules => $rules_default,
  }

  if $::operatingsystemmajrelease == '7' {
    $rules_systemd = [
      { type=>'-session',order=>3,control=>'optional',  module=>'systemd' },
    ]
    ::pam::service { 'system-auth-puppet_systemd':
      service => 'system-auth-puppet',
      rules   => $rules_systemd,
    }
    ::pam::service { 'password-auth-puppet_systemd':
      service => 'password-auth-puppet',
      rules   => $rules_systemd,
    }
  }

  if $enable_mkhomedir {
    $rules_mkhomedir = [
      { type=>'session',order=>4,control=>'optional',module=>"${mkhomedir_module}",args=>["umask=0077",], },
    ]
    ::pam::service { 'system-auth-puppet_mkhomedir':
      service => 'system-auth-puppet',
      rules   => $rules_mkhomedir,
    }
    ::pam::service { 'password-auth-puppet_mkhomedir':
      service => 'password-auth-puppet',
      rules   => $rules_mkhomedir,
    }
  }

  if $enable_script {
    $rules_script = [
      { type=>'session',order=>7,control=>'required',module=>'script',args=>["onerr=$script_onerr",], },
    ]
    ::pam::service { 'system-auth-puppet_script':
      service => 'system-auth-puppet',
      rules   => $rules_script,
    }
    ::pam::service { 'password-auth-puppet_script':
      service => 'password-auth-puppet',
      rules   => $rules_script,
    }
  }

  if $winbind {
    $cached_login = $winbind_cached_login ? {
      true    => ['cached_login',],
      default => [],
    }
    $krb5_auth = ['krb5_auth',"krb5_ccache_type=${winbind_krb5_ccache_type}",]
    if $winbind_require_membership_of {
      $_workgroup = upcase(regsubst($::domain,'^(.*?)\..*$','\1'))
      $_require_membership_of = concat(["require_membership_of=${_workgroup}\\${::hostname}$",],$winbind_require_membership_of)
      $__require_membership_of = join($_require_membership_of,',')
      $require_membership_of = [$__require_membership_of,]
    }
    $rules_winbind = [
      { type=>'auth',order=>4,control=>'sufficient',module=>'winbind',args=>concat($cached_login,$krb5_auth,$require_membership_of,['use_first_pass',]), },
      { type=>'account',order=>4,control=>'[default=bad success=ok user_unknown=ignore]',module=>'winbind',args=>concat($cached_login,$krb5_auth), },
      { type=>'password',order=>4,control=>'sufficient',module=>'winbind',args=>concat($krb5_auth,['use_authtok',]), },
      { type=>'session',order=>6,control=>'optional',module=>'winbind',args=>concat($cached_login,$krb5_auth), },
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
