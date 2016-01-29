class packer::vsphere inherits packer::vsphere::params {

  include packer::vsphere::repos
  include packer::vsphere::networking

  if $qa_root_passwd and $qa_root_passwd != "" {
    notice("Root password set")
    user { root:
      ensure   => present,
      password => "$qa_root_passwd"
    }
  } else {
    notice("Root password not set")
  }

  package { $ruby_packages:
    ensure => present,
  }

  package { 'rbvmomi':
    ensure   => present,
    provider => gem,
    require  => Package[$ruby_packages],
  }


  $vsphere_host = $::bootstrap_vsphere_host
  $vsphere_user = $::bootstrap_vsphere_user
  $vsphere_password = $::bootstrap_vsphere_password
  $vsphere_insecure_ssl = $::bootstrap_vsphere_insecure_ssl

  file { $bootstrap_file:
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    content => template("packer/vsphere/vsphere-bootstrap.rb.erb"),
  }

  file { $startup_file:
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template("packer/vsphere/${startup_file_source}"),
  }

  file { '/root/.ssh':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
  }

  file { '/root/.ssh/authorized_keys':
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    source  => 'puppet:///modules/packer/vsphere/authorized_keys',
  }

}
