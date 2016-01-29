#!/bin/bash

if_exists () {
  command -v $1 >/dev/null && "$@"
}

if [ -n "${MASTER_INSTALL_URL}" ]; then
  echo "Installing PE from installer on master..."
  if_exists yum install -y wget
  wget --no-verbose --no-check-certificate "${MASTER_INSTALL_URL}" -O- | bash
else
  echo "The environment variable MASTER_INSTALL_URL must be provided to provision PE." >&2
  exit 1
fi

echo "$AUTOSIGN" >/etc/puppetlabs/puppet/csr_attributes.yaml

FACTER_hostname="$TEMPLATE_HOSTNAME" puppet agent --test --waitforcert=30

if [ -f /etc/puppetlabs/puppet/csr_attributes.yaml ] ; do
  echo "Puppet run did not succeed." >&2
  exit 1
done
