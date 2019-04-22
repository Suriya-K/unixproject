#! /bin/bash
# Written by Dodgy Coder (with error checking)
set -u

choice1 () {
  printf "Doing choice 1 like you asked me to.\n"
}

choice2 () {
  printf "Doing choice 2 like you requested.\n"
}

choice3 () {
  printf "Doing choice 3 like you requested.\n"
}

menu () {
  local CHOICE
  local uintpattern="^[[:digit:]]+$"

  while true
  do
    printf "1.  Choice 1\n"
    printf "2.  Choice 2\n"
    printf "3.  Choice 3\n"
    printf "4.  Quit\n"
    read -p "Enter choice:" CHOICE
    # if choice is unsigned integer
    if [[ "${CHOICE}" =~ ${uintpattern} ]]
    then
      # if choice in range 1..max
      if ((CHOICE>=1)) && ((CHOICE<=4))
      then
        return ${CHOICE}
      fi
    fi
    printf "Invalid choice \"%s\"!\n" "${CHOICE}"
    printf "Choice must be one of 1, 2, or 3\n"
  done
}

menu
what2do=${?}
case ${what2do} in
  1)  choice1
      ;;
  2)  choice2
      ;;
  3)  choice3
      ;;
  4)  # do nothing
      ;;
  *)  printf "I don't know what %d means.\n" ${what2do}
      ;;
esac
exit 0
