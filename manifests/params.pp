class pam::params {
  $pam_mkhomedir = $::operatingsystemmajrelease ? {
    '7'         => 'pam_oddjob_mkhomedir.so',
    default     => 'pam_mkhomedir.so',
  }

  $succeed_if_uid = $::operatingsystemmajrelease ? {
    '7'         => '1000',
    default     => '500',
  }

  $winbind_packages = $::osfamily ? {
    'RedHat' => $::operatingsystemmajrelease ? {
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
