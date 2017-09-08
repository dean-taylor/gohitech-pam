class pam::script (
  $onerr = 'fail',	# onerr=fail|success
  $dir   = undef,	# dir=/usr/share/libpam-script
) {
  validate_re($onerr,'fail|success')
  if $dir { validate_path($dir) }

  package { 'pam_script':
    ensure => present,
  }
}
