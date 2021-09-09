#!/bin/bash
source ./functions.sh


if [[ $# -eq 4  || $1 == "--help" ]]; then
  while [ "$1" != "" ]; do
    case $1 in
      -e | --environment ) 
        env="$2"
  			[[ ! -d ./env/$env ]] && echo "There is no such environment directory exits! please make usre to choose either [prod OR dev]" && exit
  			break ;;

      -play | --playbook)
  			playbook="$2"
        [[ ! -f ./playbooks/$playbook ]] && echo "This is no such playbook '$playbook' found!" && exit 
  			break;;

      -h | --help ) 

          display_help          
          exit ;;     

      * )   
          display_help                  
          exit ;;

    esac
  done

  while [ "$3" != "" ]; do
    case $3 in
      -e | --environment ) 
        env="$4"
        [[ ! -d ./env/$env ]] && echo "There is no such environment directory exits! please make usre to choose either [prod OR dev]" && exit 
  			break ;;  

      -play | --playbook)
  			playbook="$4"
        [[ ! -f ./playbooks/$playbook ]] && echo "This is no such playbook '$playbook' found!" && exit 
  			break ;;  

      -h | --help ) 

          display_help          
          exit ;;     

      * )   
          display_help                  
          exit ;;    
    esac
  done
  ############### Set vars to be used in Ansible command ########
  echo "Set Variables based on the Environment name "
  hostFile=./env/$env/hosts
  varsFile=./env/$env/vars/main.yml
  echo "Configure ansible.cfg file"
  printf "[defaults]\nhost_key_checking = false\ncommand_warnings=False\ninventory = $hostFile" > ./ansible.cfg  
  
  ############### Install & initialize Git and git-crypt #########

  echo "Install required Git-crypt and GPG installation"
  unameOut="$(uname -s)"
  case "${unameOut}" in
    Linux*)  
      sudo apt-get install -y git-crypt
      sudo apt-get install gnupg
      ;;
    Darwin*)    
      brew install git-crypt
      brew install gpg
      ;;
  esac

  echo "Initialize Git and git-crypt"
  git init 
  git-crypt init

  ############### Check required Files ( hosts & variables )    ######
  ############### Run Ansible playbook based on the Environment ######

  echo "Running Ansible playbook $playbook on $env"
  [[ ! -f $hostFile || ! -f $varsFile ]] && echo "Hosts file: $hostFile OR Vars file: $varsFile not exists" && exit
  ansible-playbook playbooks/$playbook -e "@$varsFile"

else
  echo "Kindly run ./run.sh --help for help"
fi
