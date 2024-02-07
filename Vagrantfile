# -*- mode: ruby -*-
# vi: set ft=ruby :
#
##### https://dev.to/mattdark/using-docker-as-provider-for-vagrant-10me

#DOCKER_GID = 121
DOCKER_GID = `stat -c '%g' /var/run/docker.sock | tr -d '\n'`
PROXY="http://10.0.2.2"
PROXY_PORT="8000"


Vagrant.configure("2") do |config|
  config.vm.define "docker.dind", autostart: false do |dock|
    dock.vm.hostname = "docker.dind"
    dock.vm.provider  :docker do |d|
      d.name = "docker.dind"
      d.build_dir = "."
      d.dockerfile = "Dockerfile.dind"
      #d.build_args = ["--build-arg", "DOCKER_GID=121"]
      d.build_args = ["--build-arg", "DOCKER_GID=#{DOCKER_GID}"]
      d.remains_running = true
      d.has_ssh = true
      #d.create_args = ["-v", "/var/run/docker.sock:/var/run/docker.sock"]
      d.create_args = ["--mount", "type=bind,source=//var/run/docker.sock,target=/var/run/docker.sock"]
      #d.create_args = ["-v", "/home/def/vagrant_docker_provider2/file.txt:/file.txt:ro"]
      #d.create_args = ["--mount", "type=bind,source=/home/def/vagrant_docker_provider2/file.txt,target=/file.txt,readonly"]
      #d.ports = ["8800:8800"]
    end

    #dock.vm.network "forwarded_port", guest: 4000, host: 4000
#    config.vm.provision "docker" do |d|
#      d.images = ["ubuntu"]
#      #d.pull_images "mysql:latest"
#      d.run "ubuntu",
#        cmd: "bash -l",
#        args: "-v '/vagrant:/var/www'"
#      #d.run "mysql", args: "-e MYSQL_ROOT_PASSWORD=insecure", image: "mysql:latest"
#    end
  end


  ### NOTE   OK on Windows PS with Docker Desktop through WSL2
  config.vm.define "docker.ubuntu.dind", autostart: true do |dock|
    dock.vm.hostname = "docker.ubuntu.dind"
    dock.vm.provider  :docker do |d, override|
      override.vm.box = nil
#     docker.image = "rofrano/vagrant-provider:ubuntu"
      d.name = "docker.ubuntu.dind"
      d.build_dir = "."
      d.dockerfile = "Dockerfile.ubuntu.dind"
      d.build_args = ["--build-arg", "DOCKER_GID=#{DOCKER_GID}"]
      d.remains_running = true
      d.has_ssh = true
      d.privileged = true

      d.volumes = ["//sys/fs/cgroup:/sys/fs/cgroup:rw"]

      ### privileged dind needs host's dockerd socket
      d.create_args = [
        "--cgroupns=host",
        "--mount", "type=bind,source=//var/run/docker.sock,target=/var/run/docker.sock"
      ]
      #d.ports = ["8802:8802"]
    end

    dock.vm.provision "ansible_local" do |ansible|
      ### https://developer.hashicorp.com/vagrant/docs/provisioning/ansible_local
      ansible.provisioning_path = "/vagrant_data"
      ansible.playbook = "playbook.yml"
      ansible.install = false
      #iansible.version = "latest"
      #ansible.install_mode = "default"
      ansible.install_mode = "pip"
      #ansible.version = "2.2.1.0"
      ansible.pip_install_cmd = " \
        https_proxy=#{PROXY}:#{PROXY_PORT} curl -s https://bootstrap.pypa.io/get-pip.py \
        | sudo https_proxy=#{PROXY}:#{PROXY_PORT} python"
    end
  end


  config.vm.synced_folder ".", "/vagrant_data"

end
