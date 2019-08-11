#!/bin/bash

#script variables
select=""
path=`realpath wiki_speak.sh` #<-CHECK

#functions
printMainMenu()
{
  local options=("(l)ist existing creations" "(p)lay an existing creation"
                  "(d)elete an existing creation" "(c)reate a new creation"
                  "(q)uit authoring tool")

echo "=========================================================="
echo "Welcome to the Wiki-Speak Authoring Tool"
echo "=========================================================="
echo -n "Please select one of the following options: "
for i in ${options[*]}
do
  printf "\n\t%s" "${options[i]}"
done

local wrongSelect=false
while [ select != "[lLpPdDcCqQ]" ]
do
  if [ wrongSelect ]
  then
    echo -n "You entered an invalid option, try again..."
  fi

  read -p "Enter a selection [l/p/d/c/q]:" select
  wrongSelect=true
done
}

listCreations()
{

}

#main program

if [ ! -e "wiki_speak_creations" ]
then
  mkdir "$path/wiki_speak_creations"
fi

while [ select != [qQ] ]
do


  select=""
  printMainMenu

done

exit 0
