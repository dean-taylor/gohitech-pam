class pam::mkhomedir (
  $packages = ['oddjob-mkhomedir',],
) inherits pam::params {
  include pam

  package { $packages:
    ensure => present,
  }

  service { 'oddjobd':
    ensure  => running,
    enable  => true,
    require => Package['oddjob-mkhomedir'],
  }
}
