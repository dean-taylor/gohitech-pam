define pam::service::rule (
  $rule = $name,
) {
  validate_hash($rule)

  validate_re($rule['type'],'^-?(account|auth|password|session)$')

  validate_string($rule['module'])
  validate_string($rule['service'])

  $module_path = "pam_${$rule['module']}.so"

  if $rule['order'] { $_index = $rule['order'] }
  else { $_index = '5' }

  $_type = regsubst($rule['type'],'^-?(.*)$','\1')
  if $_type == 'auth' { $_order = "aauth${_index}" }
  else { $_order = "${_type}${_index}" }

  if is_hash($rule['args']) {
    $_module_args = join_keys_to_values($rule['args'], '=')
    $module_args = join($_module_args,' ')
  }
  elsif is_array($rule['args']) {
    $module_args = join($rule['args'],' ')
  }

  case $module_path {
    'pam_oddjob_mkhomedir.so': { include pam::oddjob_mkhomedir }
    'pam_script.so':           { include pam::script }
    'pam_winbind.so':          { include pam::winbind }
  }

  concat::fragment { "/etc/pam.d/${rule['service']}_${rule['type']}_${rule['module']}":
    target  => "/etc/pam.d/${rule['service']}",
    content => "${rule['type']}\t${rule['control']}\t${module_path} ${module_args}\n",
    order   => $_order,
  }
}

define pam::service (
  $rules,
  $service = $name,
) {
  validate_string($service)
  validate_array($rules)

  if ! defined(Concat["/etc/pam.d/${service}"]) {
    concat { "/etc/pam.d/${service}":
      ensure => present,
    }

    concat::fragment { "/etc/pam.d/${service}__header":
      target  => "/etc/pam.d/${service}",
      content => "#%PAM-1.0\n# This file is managed by Puppet. DO NOT EDIT.\n",
      order   => '00',
    }
  }

  $_rules = ght_merge_each($rules,{service=>$service,})

  ::pam::service::rule { $_rules: }
}
