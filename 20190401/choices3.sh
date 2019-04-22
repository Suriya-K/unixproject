#! /bin/bash
# Written by Dodgy Coder (with error checking)
set -u

choice1 () {
  printf "One large, thin crust pepperoni and mushroom pizza.\n"
}

choice2 () {
  printf "Triple Whopper with cheese and bacon.\n"
}

choice3 () {
  printf "\n"
}

choice4 () {
  printf "\n"
}

choice5 () {
  printf "\n"
}



menu () {
  local CHOICE
  local uintpattern="^[[:digit:]]+$"
  local maxchoise=5
  while true
  do
    printf "\n	Food Menu\n"
    for ((i=0;i<${#MENU[@]};i++))
    do
	    printf "%u.	%s"
    done
    printf "1.	Pizza\n"
    printf "2.	Burger\n"
    printf "3.	Hot Dog\n"
    printf "4.	Frebch Fries\n"
    printf "5.	Onion Rings\n"
    printf "6.	Quit\n"
    read -p "What do you want to order?" CHOICE
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
exit 0
