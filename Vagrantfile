# -*- mode: ruby -*-
# vi: set ft=ruby :
#
##### https://dev.to/mattdark/using-docker-as-provider-for-vagrant-10me

# https://stackoverflow.com/questions/72151630/how-to-run-a-bash-script-on-wsl-with-powershell/72205311#72205311
# https://stackoverflow.com/questions/26811089/vagrant-how-to-have-host-platform-specific-provisioning-steps
if Vagrant::Util::Platform.windows?
    # is windows
    puts "Vagrant launched from windows."
    # TODO test on Windows PS
    DOCKER_GID = `wsl.exe stat -c '%g' //var/run/docker.sock | tr -d '\n'`
    puts "vagrant host: /var/run/docker.sock is owned by GID #{DOCKER_GID}"
elsif Vagrant::Util::Platform.darwin?
    # is mac
    puts "Vagrant launched from mac."
elsif Vagrant::Util::Platform.linux?
    # is linux
    puts "Vagrant launched from linux."
    #DOCKER_GID = 121
    DOCKER_GID = `stat -c '%g' /var/run/docker.sock | tr -d '\n'`
    puts "vagrant host: /var/run/docker.sock is owned by GID #{DOCKER_GID}"
else
    # is some other OS
    puts "Vagrant launched from unknown platform."

end


PROXY_URL="http://10.0.2.2"
PROXY_PORT="8000"
PROXY="#{PROXY_URL}:#{PROXY_PORT}"
PROXY=""


Vagrant.configure("2") do |config|
    ### NOTE   OK on Windows PS with Docker Desktop through WSL2
  config.vm.define "vagrant.systemd", autostart: true do |conf|
    conf.vm.hostname = "vagrant.systemd"

    ############################################################
    # Provider for Docker on Intel or ARM (aarch64)
    ############################################################
    conf.vm.provider :docker do |docker, override|
      override.vm.box = nil
      docker.name = "vagrant.systemd"
      #docker.image = ""
#     docker.image = "rofrano/vagrant-provider:ubuntu"
      docker.build_dir = "."
      #docker.dockerfile = "Dockerfile.ubuntu.dind"
      docker.dockerfile = "Dockerfile.ubuntu.dind.vagrant.ansible"
      docker.build_args = ["--build-arg", "DOCKER_GID=#{DOCKER_GID}"]
      docker.remains_running = true
      docker.has_ssh = true

      docker.privileged = true
      docker.volumes = ["//sys/fs/cgroup:/sys/fs/cgroup:rw"]
      docker.create_args = ["-t", "--cgroupns=host", "--security-opt", "seccomp=unconfined", "--tmpfs", "/tmp", "--tmpfs", "/run", "--tmpfs", "/run/lock", "--mount", "type=bind,source=//var/run/docker.sock,target=/var/run/docker.sock"]
        #"--mount", "type=bind,source=//var/run/docker.sock,target=/var/run/docker.sock",
        #"-v", "/sys/fs/cgroup:/sys/fs/cgroup:rw", #"--cgroupns=host", # Uncomment to force arm64 for testing images on Intel
      # docker.create_args = ["--platform=linux/arm64", "--cgroupns=host"]

      #d.ports = ["8802:8802"]
    end

    conf.vm.boot_timeout = 600
    conf.vm.synced_folder ".", "/vagrant_data"

    conf.vm.provision "ansible_local" do |ansible|
      ### https://developer.hashicorp.com/vagrant/docs/provisioning/ansible_local
      ansible.provisioning_path = "/vagrant_data"
      ansible.playbook = "playbook.yml"

      ansible.install = false
        ### NOTE on Ubuntu 22.04:
        ###  E: Package 'python-dev' has no installation candidate
      #ansible.install = true
      #ansible.version = "latest"
      #ansible.install_mode = "default"
      ansible.install_mode = "pip"
      #ansible.version = "2.2.1.0"
      ansible.pip_install_cmd = " \
        https_proxy=#{PROXY} curl -s https://bootstrap.pypa.io/get-pip.py \
        | sudo https_proxy=#{PROXY} python3"
    end
  end

  #config.vm.synced_folder ".", "/vagrant_data"

end
