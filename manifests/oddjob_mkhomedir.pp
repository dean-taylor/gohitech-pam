class pam::oddjob_mkhomedir (
  $packages = ['oddjob-mkhomedir',],
) {
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
