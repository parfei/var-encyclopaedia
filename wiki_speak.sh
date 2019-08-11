#!/bin/bash

select=""
printMainMenu(){ #Print a neat menu, user chooses an option.

options=("(l)ist existing creations" "(p)lay an existing creation"
"(d)elete an existing creation" "(c)reate a new creation"
"(q)uit authoring tool")

echo "====================================================="
echo "Welcome to the Wiki-Speak Authoring Tool"
echo "====================================================="
echo -n "Please select one of the following options: "
for i in ${options[*]}
do
  printf "\n\t%s" "${options[i]}"
done

wrongSelect=false
while [ select != "[lLpPdDcCqQ]" ]
do
  if [ wrongSelect ]; then
    echo -n "You entered an invalid option, try again...\t"
  fi
  read -p "Enter a selection [l/p/d/c/q]: " select
  wrongSelect=true
done
}

while [ select != [qQ] ]
do






done

exit 0
