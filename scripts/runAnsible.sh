#!/bin/sh

# Exit immediately if a simple command exits with a nonzero exit value
set -e

echo "Runing Ansible master playbook..."
ansible-playbook -i ansible/production.ini ansible/master.yml
