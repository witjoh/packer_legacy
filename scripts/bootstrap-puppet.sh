#!/bin/bash

#### FIXME add puppetca cert to package

# Run a command only if it exists
if_exists () {
  command -v $1 >/dev/null && "$@"
}

case "${TEMPLATE}" in fedora-22*)
  echo "Updating rpcbind..."
  dnf -y upgrade rpcbind
  systemctl enable rpcbind.socket
  systemctl restart rpcbind.service
esac


if [ -n "${PUPPET_NFS}" ]; then
  # Mount NFS share if PUPPET_NFS set
  echo "Mounting PE via NFS..."

  # Create mount point and required directories
  mkdir -p /opt/puppet
  mkdir -p /etc/puppetlabs
  mkdir -p /var/opt/puppetlabs/puppet

  mount -o ro -t nfs ${PUPPET_NFS}/${TEMPLATE} /opt/puppet
elif [ -n "${PE_URL}" ]; then
  # Install PE via tarball download if PE_URL set
  echo "Installing PE via tarball..."

  if_exists yum install -y wget

  # Debian 7 in particular won't accept our CA, so we don't verify certificates here
  wget --no-verbose --no-check-certificate ${PE_URL} -O pe.tar.gz

  cat > /tmp/answers <<EOF
q_all_in_one_install=n
q_continue_or_reenter_master_hostname=c
q_database_install=n
q_fail_on_unsuccessful_master_lookup=n
q_install=y
q_puppet_cloud_install=n
q_puppet_enterpriseconsole_install=n
q_puppetagent_certname=scratch.debian
q_puppetagent_install=y
q_puppetagent_server=puppet
q_puppetca_install=n
q_puppetdb_install=n
q_puppetmaster_install=n
q_run_updtvpkg=n
q_vendor_packages_install=y
EOF

  ## extract and install PE
  tar -xzvf pe.tar.gz
  cd `ls -d puppet*`
  ./puppet-enterprise-installer -a /tmp/answers
elif [ -n "${MASTER_INSTALL_URL}" ]; then
  echo "Installing PE from installer on master..."
  if_exists yum install -y wget
  wget --no-verbose --no-check-certificate "${MASTER_INSTALL_URL}" -O- | bash
else
  echo "The environment variables PUPPET_NFS, PE_URL, or MASTER_INSTALL_URL must be provided to provision PE." >&2
  exit 1
fi

PATH=/opt/puppetlabs/bin:/opt/puppet/bin:"$PATH"
MODULEPATH=/tmp/packer-puppet-masterless/manifests/modules

# Show Puppet version
printf 'Puppet ' ; puppet --version

# Installed required modules
for module in "$@" ; do
  puppet module install "$module" --modulepath=$MODULEPATH >/dev/null 2>&1
done

case "${TEMPLATE}" in fedora-23*)
  dnf -y install git
  git clone https://github.com/nibalizer/puppet-dnf $MODULEPATH/puppet-dnf
  dnf -y remove git
esac

printf 'Modules installed in ' ; puppet module list --modulepath=$MODULEPATH
