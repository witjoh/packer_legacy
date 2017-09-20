# refactored templates for centos 6

Will incorperate other vesions soon,  Still POC

Only for libvirt yet.  Will try other builders soon

Important vars are set mandatory.

This can be checked with the following command:

```
packer inspect libvirt-base.json
```

adopt above command to wanted template

one need to build the base template

Optional variables should be used in the -var option.


keep in mind that the ordering matters for the \*variables\* json files
when used with the -var-file option,
the -var file option will overule everything

Vars that shoul be used with -var option :

* headless (defaults to true)
* output_dir (defaults to '/opt/output'

all boxes build an come up properly,

Command to build a box :

```
~/bin/packer build -var-file=builder.variables.json -var-file=provisioner.variables.json -var-file="i386.centos-6.8.variables.json" -var "iso_url=/data/johan/iso_images/CentOS-6.8-i386-bin-DVD1.iso" libvirt.base.json
~/bin/packer build -var-file=builder.variables.json -var-file=provisioner.variables.json -var-file="i386.centos-6.8.variables.json" libvirt.nocm.json
~/bin/packer build -var-file=builder.variables.json -var-file=provisioner.variables.json -var-file="i386.centos-6.8.variables.json" libvirt.puppet.json
```

## testing

```
  for i in `ls *centos*.json`
  do
    ~/bin/packer validate --syntax-only -var-file=builder.variables.json -var-file=provisioner.variables.json -var-file=$i libvirt.base.json
  done
```

# TODO

* looking for a proper dir structure ?
* write decent docs
* add virtualbox, vmware and more
* look how to add version 5 (during build, VM does not power recycle properly)
* ......

# Packer and docker

## preparation

* Build a base image form the desired version using for libvirt
* Export this image to a tgz :
````bash
cd output-centos-7.4-x86_64-libvirt
virt-ar-out -a packer-centos-7.4-x86_64-libvirt / - | gzip --best > packer-centos-7.4-x86_64.tgz
````
* Import this tar file in docker (we are using a local repository)
````bash
docker import -m 'centos 7.4 base image full OS' /vagrant/repos/archives/packer-centos-7.4-x86_64.tgz localhost:5000/centos-7.4-x86_64:base
docker import -m 'centos 6.9 base image full OS' /vagrant/repos/archives/packer-centos-6.9-x86_64.tgz localhost:5000/centos-6.9-x86_64:base
````
* Optional: push the base images to the registry
````bash
docker push localhost:5000/centos-6.9-x86_64
docker push localhost:5000/centos-7.4-x86_64
````
* run packer to create new docker images
````bash
PACKER_LOG=1 ~/bin/packer build -var-file=builder.variables.json -var-file=provisioner.variables.json -var-file="x86_64.centos-7.4.variables.json" -var="docker_registry=localhost:5000/" -var="docker_tag=:base" docker.nocm.json
PACKER_LOG=1 ~/bin/packer build -var-file=builder.variables.json -var-file=provisioner.variables.json -var-file="x86_64.centos-7.4.variables.json" -var="docker_registry=localhost:5000/" -var="docker_tag=:base" docker.puppet.json
PACKER_LOG=1 ~/bin/packer build -var-file=builder.variables.json -var-file=provisioner.variables.json -var-file="x86_64.centos-6.9.variables.json" -var="docker_registry=localhost:5000/" -var="docker_tag=:base" docker.nocm.json
PACKER_LOG=1 ~/bin/packer build -var-file=builder.variables.json -var-file=provisioner.variables.json -var-file="x86_64.centos-6.9.variables.json" -var="docker_registry=localhost:5000/" -var="docker_tag=:base" docker.puppet.json
````

This schould result in the following registry entries :

[vagrant@docker centos]$ curl -X GET http://localhost:5000/v2/_catalog
{"repositories":["centos-6.9-x86_64","centos-6.9-x86_64-nocm","centos-6.9-x86_64-puppet","centos-7.4-x86_64","centos-7.4-x86_64-nocm","centos-7.4-x86_64-puppet"]}
[vagrant@docker centos]$ 
