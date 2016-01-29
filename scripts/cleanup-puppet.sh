#!/bin/bash

# Run a command only if it exists
if_exists () {
  command -v $1 >/dev/null && "$@"
}

# PE is currently used to provision nocm and puppet boxes.
# This script cleans up directories that may be left around
# as part of that process.

# Unmount NFS share if PUPPET_NFS provided
if [ -n "${PUPPET_NFS}" ]; then
  umount -l /opt/puppet
fi

# Remove /etc/puppetlabs on -nocm boxes
case "${PACKER_BUILD_NAME}" in *-nocm)
  NOCM=1
esac

if [ -n "$NOCM" ] ; then
  rm -rf /etc/puppetlabs
fi

# Run the PE uninstaller on Amazon builders
case "${PACKER_BUILDER_TYPE}" in amazon-*)
  cd `ls -d puppet*`
  ./puppet-enterprise-uninstaller -d -p -y
esac

echo "Making sure there aren't any Puppet packages installed"
if_exists apt-get -y --purge remove puppet-agent || true
if_exists yum remove package puppet-agent || true

# Remove other Puppet-related files and directories
rm -rf /opt/puppet*
rm -rf /var/cache/yum/puppetdeps
rm -rf /var/opt/lib/pe-puppet
rm -rf /var/opt/puppetlabs
