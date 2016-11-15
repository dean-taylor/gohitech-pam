class pam::params {
  $mkhomedir_module = $::operatingsystemmajrelease ? {
    '7'     => 'oddjob_mkhomedir',
    default => 'mkhomedir',
  }

  $pam_pwquality = $::operatingsystemmajrelease ? {
    '7'     => 'pwquality',
    default => 'cracklib',
  }

  $succeed_if_uid = $::operatingsystemmajrelease ? {
    '7'     => '1000',
    default => '500',
  }

  $winbind_packages = $::osfamily ? {
    'RedHat'  => $::operatingsystemmajrelease ? {
      '7'     => 'samba-winbind-modules',
      default => 'samba-winbind-clients',
    },
    default => 'samba-winbind-clients',
  }

  $winbind_krb5_ccache_type = $::operatingsystemmajrelease ? {
    '7'		=> 'KEYRING',
    default	=> 'FILE',
  }
}
