define pam::nsswitch::database (
  $database = $name,
  $sources  = [],
) {
  validate_re($database,'^alias|ethers|group|hosts|initgroups|netgroup|networks|passwd|protocols|publickey|rpc|services|shadow$')
  validate_array($sources)

  
}

class pam::nsswitch (
  $aliases    = ['files',],
  $automount  = ['files',],
  $bootparams = ['files',],
  $ethers     = ['files',],
  $group      = ['files',],
  $hosts      = ['files','dns',],
  $initgroups = undef,
  $netgroup   = ['files',],
  $netmasks   = ['files',],
  $networks   = ['files',],
  $passwd     = ['files',],
  $protocols  = ['files',],
  $publickey  = undef,
  $rpc        = ['files',],
  $services   = ['files',],
  $shadow     = ['files'],
) inherits pam::params {
  if is_array($aliases)    { $aliases_real   = join($aliases,' ') }
  if is_array($automount)  { $automount_real = join($automount,' ') }
  if is_array($bootparams) { $bootparams_real = join($bootparams,' ') }
  if is_array($ethers)     { $ethers_real    = join($ethers,' ') }
  if is_array($group)      { $group_real     = join($group,' ') }
  if is_array($hosts)      { $hosts_real     = join($hosts,' ') }
  if is_array($netgroup)   { $netgroup_real  = join($netgroup,' ') }
  if is_array($netmasks)   { $netmasks_real  = join($netmasks,' ') }
  if is_array($networks)   { $networks_real  = join($networks,' ') }
  if is_array($passwd)     { $passwd_real    = join($passwd,' ') }
  if is_array($protocols)  { $protocols_real = join($protocols,' ') }
  if is_array($rpc)        { $rpc_real       = join($rpc,' ') }
  if is_array($services)   { $services_real  = join($services,' ') }
  if is_array($shadow)     { $shadow_real    = join($shadow,' ') }

  file { '/etc/nsswitch.conf.puppet':
    ensure  => present,
    content => template("pam/nsswitch.conf.erb"),
  }
}
