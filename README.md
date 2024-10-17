# Ansible volume mounts

## Motivation

if you want to mount volumes via `Ansible`, how to do that?

Note: `Ansible` needs SSH access to the target machine. You can find out how to configure SSH access in the docker container at [https://github.com/Frunza/configure-docker-container-with-ssh-access](https://github.com/Frunza/configure-docker-container-with-ssh-access)

## Prerequisites

A Linux or MacOS machine for local development. If you are running Windows, you first need to set up the *Windows Subsystem for Linux (WSL)* environment.

You need `docker cli` and `docker-compose` on your machine for testing purposes, and/or on the machines that run your pipeline.
You can check both of these by running the following commands:
```sh
docker --version
docker-compose --version
```

Make sure that you already have a docker container with SSH access.

You will also need some tool that provides you with volumes that you can use as mounts.

## Implementation

First of all, you want to create the directory for the mount:
```sh
    - name: Create harbor database mount directory
      file:
        path: "{{ appDataDir }}"
        state: directory
```

Now you have to place a mount configuration file in *systemd*.

A smart way to create the mount configuration file is to use the `Ansible` templating mechanism. Create the following file named *data-app.mount.j2*:
```sh
[Unit]
Description=Mount app from nas
After=network.target

[Mount]
What={{ mountAppServerLocation }}
Where={{ appDataDir }}
Type={{ mountType }}
Options=_netdev,auto

[Install]
WantedBy=multi-user.target
```
Note that most of the mount parameters are taken from variables. This is the advantage of templating. Do also note that *systemd* mount configuration files are typically named based on the path they are mounting, with slashes (`/`) replaced by hyphens (`-`). The `.mount` suffix is appended to the filename.

Now you have to fill the mount configuration templating file with its proper values and copy it to */etc/systemd/system*:
```sh
    - name: Create data-app.mount file
      template:
        src: templates/data-app.mount.j2
        dest: /etc/systemd/system/data-app.mount
        mode: '0644'
```
This task can consume variables defined in your current playbook as well as variables available from imported files.

Now you only have to apply the mount:
```sh
    - name: Reload systemd manager configuration
      systemd:
        daemon_reload: yes

    - name: Start and enable data-app.mount
      systemd:
        name: data-app.mount
        enabled: yes
        state: started
        daemon_reload: yes
```

## Usage

Navigate to the root of the repository and run the following command:
```sh
sh run.sh 
```

The following happens:
1) the first command builds the docker image, passing the private key value as an argument and tagging it as *respondansible*
2) the docker image sets up the SSH access by copying the value of the `SSH_PRIVATE_KEY` argument to the standard location for SSH keys
3) the second command uses docker-compose to run the `Ansible` playboog that prepares the mount and makes it available
