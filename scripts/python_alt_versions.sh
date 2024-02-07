#!/usr/bin/env sh

##### Manage multiple alternative versions of Python system-wide
#!!!REMEMBER it's ALWAYS better to use virtualenv than switch system-wide python !!!
#
# https://hackersandslackers.com/multiple-python-versions-ubuntu-20-04/
# https://www.rosehosting.com/blog/how-to-install-and-switch-python-versions-on-ubuntu-20-04/
# https://unix.stackexchange.com/questions/410579/change-the-python3-default-version-in-ubuntu

package_name="python"
package_major="3"
package_minor="8"
package_name="python3"

package_version="python3.8"
#link_filename="${package%%.*}"
if [ -L "/usr/bin/python3" ]; then
  link_filename="python3"
fi
#if [ -L "/usr/bin/python" ]; then
#  link_filename="python"
#fi
echo "link filename is ${link_filename}"

if [ -L "$(readlink '/usr/bin/'${link_filename})" ]; then
	echo "/usr/bin/python3 is a link to link"
  current_package_version="$(readlink $(readlink '/usr/bin/'${link_filename}))"
else
	echo "/usr/bin/python3 is a link"
  current_package_version="$(readlink '/usr/bin/'${link_filename})"
fi
current_package_version="${current_package_version##*/}"
  echo "current package version is ${current_package_version}"


current_package_no=$(eval " \
	update-alternatives --list ${link_filename} \
	| grep -n ${current_package_version} \
	| cut -f1 -d':' \
	")
if [ -z "${current_package_no}" ]; then
  current_package_no="1"
fi
  echo "current package no is $current_package_no"


alt_package_no="$(update-alternatives --list ${link_filename} | wc -l)"
echo $alt_package_no
alt_package_no=$((${alt_package_no} + 1))
echo $alt_package_no \n

#echo "\n##### Your actual version of Python is..."
#python --version
#
#echo "\n##### Your actual version of Python2 is..."
#python2 --version
#
#echo "\n##### Your actual version of Python3 is..."
#current_python3_version="$(python3 --version)"
#echo "${current_python3_version}"

add_repo() {
### !!! this PPA only for Ubuntu !!!
### RHEL uses it's own repository
echo "\n#####
  System versions are:
  Python2.7 (all),
  Python 3.6 (bionic),
  Python 3.8 (focal),
  Python 3.10 (jammy)
  For a full list of supported versions read 'Supported Ubuntu and Python Versions' chapter in deadsnake PPA disclaimer \n"

sudo apt-get install --yes software-properties-common
sudo add-apt-repository ppa:deadsnakes/ppa
#sudo apt update
}

check_availability() {
  echo "\n##### Checking availability... These packages are available:"
apt list | grep "${package_version}"
}

install_package() {
  echo "\n##### Installing ${package}..."
sudo apt-get install "${package_version}" --yes
echo "Just installed $(${package_version} --version)"
echo "System-wide: $(python3 --version)"
}


update_alternative_python() {
#### in case you have python2.7
## Explanation:-
## sudo update-alternatives --install <symlink_origin> <name_of_config> <symlink_destination> <priority>
  echo "\n##### Setting alternatives for /usr/bin/python link..."
if [ -L "/usr/bin/${link_filename}" ]; then
  echo "current package version is ${current_package_version}"
  echo "current package no is $current_package_no"
sudo update-alternatives --install "/usr/bin/${link_filename}" "${package_name}" "/usr/bin/${current_package_version}" "${current_package_no}"

  alt_package_no="$(update-alternatives --list ${link_filename} | wc -l)"
  alt_package_no=$((${alt_package_no} + 1))
    echo "alt package no is $alt_package_no"
#sudo update-alternatives --install /usr/bin/python python /usr/bin/"${package}" 2
  sudo update-alternatives --install "/usr/bin/${link_filename}" "${package_name}" "/usr/bin/${package_version}" ${alt_package_no}
fi
}

#update_alternatives_python3() {
##### in case you have python3
##sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.7 1
#  echo "\n##### Setting alternatives for /usr/bin/python3 link..."
#if [ -L /usr/bin/python3 ]; then
#  echo "current package version is ${current_package_version}"
#  #sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/"$(readlink '/usr/bin/python3')" "${current_package_no}"
##  sudo update-alternatives --install "/usr/bin/${link_name}" "${package_name}" "/usr/bin/$(readlink '/usr/bin/'${current_package_version})" "${current_package_no}"
#
#  alt_package_no="$(update-alternatives --list ${link_filename} | wc -l)"
#  alt_package_no=$((${alt_package_no} + 1))
#  #sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/"${package}" 2
#  #sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/"${package_version}" ${alt_package_no}
#  sudo update-alternatives --install "/usr/bin/${link_name}" "${package_name}" "/usr/bin/${package_version}" ${alt_package_no}
#fi
#}

list_alternatives() {
  echo "\n##### List of alternatives:"
update-alternatives --list "${package_name}"
}

select_python_version() {
if [ -L "/usr/bin/${link_filename}" ]; then
### interactive select the number of python you want then enter
#sudo update-alternatives --config "${package_name}"

### select with script-ready command
sudo update-alternatives  --set "${package_name}" "/usr/bin/${package_version}"
echo "Now default ${package_name} version is $(${package_name} --version)"
fi
}

#select_python3_version() {
##if [ -L /usr/bin/python3 ]; then
#if [ -L "/usr/bin/${link_filename}" ]; then
#### interactive select the number of python you want then enter
##sudo update-alternatives --config python3
#
#### select with script-ready command
#sudo update-alternatives  --set python3 /usr/bin/"${package_version}"
#  echo "Now default python3 version is $(python3 --version)"
#fi
#}


install_modules() {
  echo "\n##### Reinstall python3-apt for your alternative Python installation"
#?? TODO skip or not skip???
#select_python_version
select_python_version

### ???only in python3 ???
sudo apt remove --purge python3-apt
sudo apt autoclean
sudo apt-get install --yes python3-apt

### Python does not ship with distutils (necessary for installing older Python modules)
sudo apt install --yes "${package_version}"-distutils

### Python does not ship with its package manager (pip)
sudo apt-get install --yes "${package_name}"-pip
"${package_name}" -m pip install --upgrade pip
"${package_version}" -m pip install --upgrade pip

### Virtualenv is the superset of regular venv
## https://realpython.com/python-virtual-environments-a-primer/
sudo apt-get install --yes "${package_name}"-virtualenv
}

create_venv() {
#if venv package for that version is not installed already
#!!BUT do use virtualenv instead of venv !!!
#sudo apt install "${package}"-venv
#python -m venv venv

  ### https://virtualenv.pypa.io/en/latest/
  ### https://virtualenv.pypa.io/en/latest/user_guide.html
python -m virtualenv env_name
## OR:
#virtualenv env_name
source env_name/bin/activate
# confirm
python --version
which python3

#deactivate
}


add_repo
check_availability
install_package

update_alternative_python
###update_alternatives_python3

list_alternatives
select_python_version
###select_python3_version

install_modules

#create_venv

