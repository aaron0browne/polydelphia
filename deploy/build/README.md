# Packer Build Configuration

Using Packer, this configuration builds a Google Compute Engine image with the site installed and ready to run. To build a new image, run `./build.sh` which is a simple wrapper around `packer build` that injects the git tag into `packer.json`. This should probably be done regularly, both to make sure the build process still works and also to update the system packages.

The Packer build installs and configures the site via the Ansible `playbook.yml`.

The `start.sh` script is a Terraform template file intended to be rendered with host name information and passed to the instance started from this AMI in the cloudinit user data. It inserts the information into the configuration file and starts the service.
