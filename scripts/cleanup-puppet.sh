#!/bin/bash

# PE is currently used to provision nocm and puppet boxes.
# This script cleans up directories that may be left around
# as part of that process.

# Unmount NFS share if PUPPET_NFS provided
if [ -n "${PUPPET_NFS}" ]; then
  umount -l /opt/puppet
fi

# Only remove /etc/puppetlabs on -nocm boxes
case "${PACKER_BUILD_NAME}" in *-nocm)
  rm -rf /etc/puppetlabs
esac

# Run the PE uninstaller on Amazon builders
case "${PACKER_BUILDER_TYPE}" in amazon-*)
  cd `ls -d puppet*`
  ./puppet-enterprise-uninstaller -d -p -y
esac

# Remove other Puppet-related files and directories
rm -rf /opt/puppet
rm -rf /var/cache/yum/puppetdeps
rm -rf /var/opt/lib/pe-puppet
rm -rf /var/opt/puppetlabs
