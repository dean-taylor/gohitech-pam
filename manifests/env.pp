define pam::env::service (
  $conffile     = undef,        # def:/etc/security/pam_env.conf
  $debug        = undef,        # def: false
  $envfile      = undef,
  $readenv      = undef,        # readenv=0|1 ;on
  $user_envfile = undef,        # ~/.pam_environment
  $user_readenv = undef,        # user_readenv=0|1 ;off
) {
  if $conffile { validate_absolute_path($conffile) }
  if $debug    { validate_bool($debug) }
  if $envfile  { validate_absolute_path($envfile) }
  if $readenv  { validate_bool($readenv) }
}

class pam::env (
) {
  include pam

}
