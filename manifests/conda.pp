include ::stdlib

$stack_user  = $::lsst_stack_user ? {
  undef   => 'conda',
  default => $::lsst_stack_user,
}
$stack_group = $stack_user

$wheel_group = $::osfamily ? {
  'Debian' => 'sudo',
  default  => 'wheel',
}

if $::osfamily == 'RedHat' {
  include ::epel
  Class['epel'] -> Package<| provider == 'yum' |>
}

user { $stack_user:
  ensure     => present,
  gid        => $stack_group,
  groups     => [$wheel_group],
  managehome => true,
}

group { $stack_group:
  ensure => present,
}

# puppet-lsststack does not currently support el5
# this list of packages works with el5 *only*
# note that
# * e2fsprogs-devel provides uuid.h
# * perl-ExtUtils-MakeMaker does not exist / is not required as
#   ExtUtils::MakeMaker is bundled with perl
# * git is only provided by epel5
# * libcurl-devel is named curl-devel
# * java 1.8.0 is not available
# * the conda-recipes glib package, which is needed by mysqlproxy, requires
#   unxz to unpack the tarball
package {[
  'curl',
  'bzip2',
  'make',
  'patch',
  'tar',
  'zlib',
  #'java-1.7.0-openjdk', # jenkins client
  'git',
  'xz',
  'glibc-headers',
  'glibc-devel', # include <gnu/stubs-64.h>
  'bzip2-devel', # headers needed by boost -- aparently not provided by the conda package???
  'flex', # doxygen requires
  'bison', # doxygen requires
  'ncurses-devel', # mariadb needs -- conda ncurses package didn't work
  'readline-devel', # lua needs
  'openssl-devel', # needed by libevent  #include <openssl/bio.h> -- did not seem to work with conda openssl package
  'pkgconfig', # needed by lsst-glib -- conda pkgconfig package does not include the pkg-config binary
  'gettext', # needed by lsst-glib
]:
  ensure  => present,
  require =>  Class['epel'],
}

# convience packages copied from puppet-lsststcak
package {[
  'screen',
  'tmux',
  'tree',
  'vim-enhanced',
  'emacs-nox',
]:
  ensure  => present,
  require =>  Class['epel'],
}
