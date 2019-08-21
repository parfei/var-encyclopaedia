#!/bin/bash

###################functions###################

#Prints the main menu, and houses an array full of all possible options.
printMainMenu()
{
  local options=("(l)ist existing creations" "(p)lay an existing creation"
  "(d)elete an existing creation" "(c)reate a new creation"
  "(q)uit authoring tool") #options for the menu, can later on add more

  echo -e "\n=========================================================="
  echo "Welcome to the Wiki-Speak Authoring Tool"
  echo "=========================================================="
  echo "Please select one of the following options: "
  for ((i = 0; i < ${#options[*]}; i++)); do #iterate through all the options and print them out to user.
  printf "\n   %s" "${options[i]}"
done

while [[ true ]]; do
  printf "\n\nEnter a selection [l/p/d/c/q]: "
  read select
  if [[ $select != [lLpPdDcCqQ] && $select != [lL][iI][sS][tT] && $select != [pP][lL][aA][yY] && $select != [dD][eE][lL][eE][tT][eE] \
  && $select != [cC][rR][eE][aA][tT][eE] && $select != [qQ][uU][iI][tT] ]]; then
    printf "Invalid option, try again..."
    continue #run the while loop again and reprompt the user to enter the selection.
  fi
  break #Exit the while loop if a correct key has been pressed.
done

return 0
}

#Lists all creations and prompts user to continue (unless there are no creations)
listCreations()
{
  if [[ ${#creations[*]} -eq 0 ]]; then
    printf "No existing creations.\n"
    return 1 #return false if there are no Creations currently.
  else
    printf "\nExisting creations (total: %d)\n" "${#creations[*]}"
    for (( i = 0; i < ${#creations[*]}; i++ )); do
      printf "\t%d)   %s\n" "$((i+1))" "${creations[i]}" #print out existing creations.
    done
    promptContinue
    return 0
  fi
}

#Select a creation, saves the number selected from the list of Creations into a global variable.
selectCreation()
{
  while [[ true ]]; do
    read -p "Select a creation (enter the number matching the creation name) " creationNumber
    if [[ $creationNumber == [[:digit:]] ]]; then
      if [[ $creationNumber -ge 1 && $creationNumber -le ${#creations[*]} ]]; then
        break #break out of loop and return function, number given was valid.
      fi
    fi
    printf "That is not a valid number in the list, try again..." #force another iteration to reselect a creation number.
  done

  return 0
}

#Play the selected creation, using the global variable of the specified creation number.
playCreation()
{
  local filepath=`find "$path/wiki_speak_creations/creations" | \
  grep "${creations[$(($creationNumber-1))]}"` &> /dev/null #retrieve the file of the creation in the array specified by the creation number.
  ffplay -autoexit "$filepath" &> /dev/null #play, autoexit when finish else press esc to close earlier.

  return 0
}

#Deletes the selected creation, using the global variable of the specified creation number.
deleteCreation()
{
  while [[ true ]]; do
    read -p "Are you sure you want to delete ${creations[$(($creationNumber-1))]}? Type (y)es to delete, otherwise (r)eturn back to menu "
    if [[ $REPLY == [yY] || $REPLY == [yY][eE][sS] ]]; then
      local filepath=`find "$path/wiki_speak_creations/creations" | grep "${creations[$(($creationNumber-1))]}"` &> /dev/null
      rm -f "$filepath" #delete specified file retrieved from the creations array of specified creation number.
      break
    elif [[ $REPLY == [rR] || $REPLY == [rR][eE][tT][uU][rR][nN] ]]; then
      return 1 #break out of loop and return to menu, there was no deletion.
    else
      printf "Invalid option. Try again..." #Need to reiterate so user choose a correct option.
    fi
  done

  creations=( "${creations[@]/"${creations["$(($creationNumber-1))"]}"}" ) #delete the creation name out of the creations array
  rm -fr "$path"/"wiki_speak_creations"/"extra"/"$term"/"$creationName" #remove any extra files associated with the Creation.

  return 0
}

#Retrieve content from a specified term from the user- if term cannot be found, return back to the menu.
retrieveTerm()
{
  read -p "What term would you like to synthesize a Creation for? Please enter here: " term

  while [[ true ]]; do
    content=`wikit "$term"`
    #If term not found
    if [[ "$content" == "$term not found :^(" ]]; then
      read -p "$term not found. Press (a)gain to enter a new term or (r)eturn back to menu "
      if [[ $REPLY == [aA] || $REPLY == [aA][gG][aA][iI][nN] ]]; then
        read -p "Enter a new term: " term #Forced to go through while loop to check validity of term
      elif [[ $REPLY == [rR] || $REPLY == [rR][eE][tT][uU][rR][nN] ]]; then
        return 1
      else
        printf "Invalid option. Try again...\n"
      fi
      #If term found
    else
      return 0 #force return if there is a valid term available for a Creation
    fi
  done
}

#Create a new creation using the specified term and a specified Creation name.
createCreation()
{
  local linesArray=()

  content=${content//. /.\\n} #split the sentences in different lines.
  content=${content# }
  counter=`echo -e $content | wc -l`

  #print the wiki search, numbered.
  for (( i = 0; i < $counter; i++ )); do
    line=`echo -e "$content" | head -n 1` #retrieve the current line of the wikipedia search.
    printf "\n   %d) $line" "$(($i+1))" 2> /dev/null
    linesArray+=(" $line ")
    content=${content#*\\n} #delete the line stored.
  done

  promptContinue

  while [[ true ]]; do
    read -p "How many sentences would you like to include? Specify a number between (1 - $counter) " sentences
    if [[ $sentences == [[:digit:]] ]]; then
      if [[ $sentences -ge 1 && $sentences -le $counter ]]; then #if not in the range of possible lines of the wikipedia search.
        break #break out of loop because a valid sentence range was given.
      fi
    fi
    printf "Invalid range. Try again..." #force another iteration if a valid range was not given.
  done

  finalLines=${linesArray[@]:0:$sentences} #retrieve the necessary lines from the lines array.

  while [[ true ]]; do
    read -p "Enter a name for this Creation: " creationName
    find "$path/wiki_speak_creations/creations/$creationName.mp4" &> /dev/null
    if [[ `echo $?` == 0 ]]; then
      printf "Name already exists, try again..."
      continue #if was able to find the name in the creations folder, then re-ask for another Creation name.
    elif [[ `echo "$creationName"` == *\/* || $creationName == "" ]]; then
      printf "Invalid naming, try again..."
      continue #if name is not valid, re-ask for another Creation name (contains / or is empty name).
    fi
    break #break out of loop if valid name.
  done

  mkdir -p "$path"/"wiki_speak_creations"/"extra"/"$term"/"$creationName" #make creation's folder for excess files.

  printf "Generating Creation..."
  generationPath="$path/wiki_speak_creations/extra/"$term"/"$creationName""
  generateAudio
  generateVideo

  ffmpeg -i $generationPath/audio.wav -i $generationPath/video.mp4 -c:v copy -c:a aac -strict experimental \
    "$path/wiki_speak_creations/creations/"$creationName.mp4"" &> /dev/null #merge the audio and video together.
  if [[ `echo "$?"` -ne 0 ]]; then #If there was an error generating the Creation...
    rm -f "$path/wiki_speak_creations/creations/"$creationName.mp4""
    printf "ERROR: could not generate Creation. Exiting..." >&2
    return 1
  fi

  creations+=("$creationName") #add to creations array.
  printf "Creation generated.\n"

  return 0
}

generateAudio()
{
    printf "Generating audio..."
  `echo "$finalLines" | text2wave -o $generationPath/audio.wav` &> /dev/null #generate wav audio file.
  if [[ `echo "$?"` -ne 0 ]]; then #If there was an error generating the audio...
    rm -f "$generationPath/audio.wav"
    printf "ERROR: could not generate audio...." >&2
    return 1
  fi
  return 0
}

generateVideo()
{
    printf "Generating video..."
  duration=`soxi -D $generationPath/audio.wav` &> /dev/null #retrieve audio length.

   #create video with specified duration, default white font and blue background.
  ffmpeg -f lavfi -i color=c=blue:s=320x240:d="$duration" -vf \
    "drawtext=fontfile=:fontsize=30:fontcolor=white:x=(w-text_w)/2:y=(h-text_h)/2:text="$term"" "$generationPath/video.mp4" &> /dev/null
  if [[ `echo "$?"` -ne 0 ]]; then #If there was an error generating the video...
    rm -f "$generationPath/video.mp4"
    printf "ERROR: could not generate video..." >&2
    return 1
  fi

  return 0
}

promptContinue()
{
  printf "\n\n-->PRESS ANY KEY TO CONTINUE... "
  read -n 1 -s -r #press any key to continue
  sleep .3
  return 0
}

###################main program###################

path="." #retrieve the path of the current script.
creations=() #holds all the creations in one array.

if [[ ! -e "wiki_speak_creations/creations" ]]; then
  mkdir -p "$path/wiki_speak_creations/creations"
fi

#fill in the creations array with pre-existing Creations.
while IFS=$'\n' read line; do
filename="${line%.*}" #remove extension.
creations+=("$filename")
done < <(ls -1 "$path/wiki_speak_creations/creations")

select=""
while [[ $select != [qQ] && $select != [qQ][uU][iI][tT] ]]; do #keep on repeating the while loop until quit specified.
  IFS=$'\n' creations=(`sort <<<"${creations[*]}"`) #sort creations array, separated by newline
  unset IFS #reset IFS var
  printMainMenu

  case $select in
    [lL] | [lL][iI][sS][tT])
    listCreations
    ;;
    [pP] | [pP][lL][aA][yY])
    listCreations
    if [[ `echo "$?"` -eq 0 ]]; then #if listCreations returns true, then the list is non-empty.
      selectCreation
      playCreation
    fi
    ;;
    [dD] | [dD][eE][lL][eE][tT][eE])
    listCreations
    if [[ `echo "$?"` -eq 0 ]]; then
      selectCreation
      deleteCreation
    fi
    ;;
    [cC] | [cC][rR][eE][aA][tT][eE])
    retrieveTerm
    if [[ `echo "$?"` -eq 0 ]]; then #only when there is a successful term can we create a Creation.
      createCreation
    fi
    ;;
  esac
done

if [[ -e $path/wiki_speak_creations/extra ]]; then
  rm -fr $path/wiki_speak_creations/extra #delete extra files
fi

exit 0
