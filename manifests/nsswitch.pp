class pam::nsswitch (
  $aliases    = undef,
  $automount  = undef,
  $bootparams = undef,
  $ethers     = undef,
  $group      = undef,
  $hosts      = undef,
  $initgroups = undef,
  $netgroup   = undef,
  $netmasks   = undef,
  $networks   = undef,
  $passwd     = undef,
  $protocols  = undef,
  $publickey  = undef,
  $rpc        = undef,
  $services   = undef,
  $shadow     = undef,
) inherits pam::params {
  if is_array($aliases) { $aliases_real   = join($aliases,' ') }
  else { $aliases_real = 'files' }

  if is_array($automount) { $automount_real = join($automount,' ') }
  else { $automount_real = 'files' }

  if is_array($bootparams) { $bootparams_real = join($bootparams,' ') }
  else { $bootparams_real = 'files' }

  if is_array($ethers) { $ethers_real = join($ethers,' ') }
  else { $ethers_real = 'files' }

  if is_array($group) { $group_real = join($group,' ') }
  else { $group_real = 'files' }

  if is_array($hosts) { $hosts_real = join($hosts,' ') }
  else { $hosts_real = 'files dns' }

  if is_array($netgroup) { $netgroup_real = join($netgroup,' ') }
  else { $netgroup_real = 'files' }

  if is_array($netmasks) { $netmasks_real = join($netmasks,' ') }
  else { $netmasks_real = 'files' }

  if is_array($networks) { $networks_real = join($networks,' ') }
  else { $networks_real = 'files' }

  if is_array($passwd) { $passwd_real = join($passwd,' ') }
  else { $passwd_real = 'files' }

  if is_array($protocols) { $protocols_real = join($protocols,' ') }
  else { $protocols_real = 'files' }

  if is_array($rpc) { $rpc_real = join($rpc,' ') }
  else { $rpc_real = 'files' }

  if is_array($services) { $services_real = join($services,' ') }
  else { $services_real = 'files' }

  if is_array($shadow) { $shadow_real = join($shadow,' ') }
  else { $shadow_real = 'files' }

  $winbind_enabled = defined(Class['pam::winbind'])

  file { '/etc/nsswitch.conf.puppet':
    ensure  => present,
    content => template("pam/nsswitch.conf.erb"),
  }
}
