class packer::vmtools::params {

  case $::osfamily {
    'Redhat' : {
      $root_home = '/root'
      $os_required_packages = [ 'kernel-devel', 'gcc' ]
    }

    'Debian' : {
      $root_home = '/root'
      $os_required_packages = [ "linux-headers-${::kernelrelease}" ]
    }

    default : {
      fail( "Unsupported platform: ${::osfamily}/${::operatingsystem}" )
    }
  }

  case $::provisioner {
    virtualbox: {
      $tools_iso   = 'VBoxGuestAdditions.iso'
      $install_cmd = 'sh /tmp/vmtools/VBoxLinuxAdditions.run --nox11 ; true'
      $required_packages = $os_required_packages
    }

    vmware: {
      # No ISO or install command.
      $required_packages = $os_required_packages + [ 'open-vm-tools' ]
    }

    default: {
      fail( "Unsupported provisioner: ${::provisioner}" )
    }
  }

}
