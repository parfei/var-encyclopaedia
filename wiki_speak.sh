#!/bin/bash

#script variables
path=`dirname "realpath wiki_speak.sh"`
creations=() #create an array that consists of all creations

#functions
reloadCreationList()
{
  while IFS=$'\n' read line
  do
    filename="${line%.*}"
    creations+=("$filename")
  done < <(ls -a1 $path/wiki_speak_creations)

  IFS=$'\n' creations=(`sort <<<"${creations[*]}"`) #sort array
  unset IFS #reset LFS var
}

printMainMenu()
{
  local options=("(l)ist existing creations" "(p)lay an existing creation"
  "(d)elete an existing creation" "(c)reate a new creation"
  "(q)uit authoring tool") #options for the menu

  printf "\n"
  echo "=========================================================="
  echo "Welcome to the Wiki-Speak Authoring Tool"
  echo "=========================================================="
  echo "Please select one of the following options: "
  for ((i = 0; i < ${#options[*]}; i++))
  do
    printf "\n\t%s" "${options[i]}"
  done

  printf "\n\n"
  select=""
  read -p "Enter a selection [l/p/d/c/q]:" select
  while [[ $select != [lLpPdDcCqQ] ]]
  do
    read -p "You entered an invalid option, try again...Enter a selection [l/p/d/c/q]: " >&2 select
  done

  return 0
}

listCreations()
{
  local newCreation

  if [[ ${#creations[*]} == 0 ]]
  then
    read -p "No existing creations. Would you like to create one? (y/n) " newCreation
    while [[ $newCreation != [yYnN] ]]
    do
      read -p "Invalid response, try again...Would you like to create one? (y/n) " >&2 newCreation
    done

    if [[ $newCreation == [yY] ]]
    then
      echo ".."#go to creation function
    fi
  else
    printf "\nExisting creations (total: %d)\n\n" "${#creations[*]}"
    for (( i = 0; i < ${#creations[*]}; i++ ))
    do
      printf "\t%d) %s\n" "$((i+1))" "${creations[i]}"
    done
  fi

  return 0
}

selectCreation()
{
  creationNumber=""
  read -p "Select a creation (enter the number matching the creation name) " creationNumber
  while [[ $creationNumber != {0..${#creations[*]}} ]]
  do
    read -p "That creation does not exist, try again...Select a creation (enter the number matching the creation name) " >&2 creationNumber
  done

  return 0
}

findCreation()
{
  local filepath=`find $path/wiki_speak_creations/ | grep $1` &> /dev/null
  return "$filepath"
}

playSelectedCreation()
{
  local play

  play=`findCreation "${creations[creationNumber]}"`

  return 0
}

deleteSelectedCreation()
{
  local confirm delete

  read -p "Are you sure you want to delete ${creations[creationNumber]} ? Please type out
  the name to contine (case-sensitive), otherwise press b to go back " confirm
  while [[ $confirm != [${creations[creationNumber]} | bB] ]]
  do
    read -p "That creation does not exist, try again...
    Are you sure you want to delete ${creations[creationNumber]} ? Please type out
    the name to contine (case-sensitive), otherwise press b to go back " >&2 creationNumber
  done

  if [[ $confirm == "${creations[creationNumber]}" ]]
  then
    delete=`findCreation "${creations[creationNumber]}"`
  fi

  rm -f "$delete"

  promptContinue

  return 0
}

addNewCreation()
{
  
}

promptContinue()
{
  read -ps "Press any key to continue "
  return 0
}

#main program
reloadCreationList

if [ ! -e "wiki_speak_creations" ]
then
  mkdir "$path/wiki_speak_creations"
fi

while [[ $select != [qQ] ]]
do

  select=""
  printMainMenu
  case $select in
    [lL])
    listCreations
    promptContinue
    ;;
    [pP])
    listCreations
    selectCreation
    playSelectedCreation
    ;;
    [dD])
    listCreations
    selectCreation
    deleteSelectedCreation
    ;;
    [cC])

    ;;
  esac

done

exit 0
