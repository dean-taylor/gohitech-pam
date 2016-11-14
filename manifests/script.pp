class pam::script (
  $dir   = undef,	# not implemented
  $onerr = 'fail',	# success|fail
) {
  package { "pam_script":
    ensure => present,
  }
}
