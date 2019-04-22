#! /bin/bash
# A amazing menu demo using the built-in menu feature from select

declare -a MENU    # declare associative array MENU
                   # and populate it with our menu choices
MENU=("Pizza "Burger" "Hot Dog" "French Fries" "Onion Rings")

OLDPS3="${PS3}"    # backup current PS3 prompt
PS3="What do you want to order?"  # set our own PS3 prompt
regex='^[[:digit:]]+$'         # regex is used to guarantee input is an unsigned integer
COLUMNS=${COLUMNS:=80}         # if COLUMNS is not set, default to  80 columns
MENUTITLE="Action Menu"        # this is our menu title
((SPACES=(COLUMNS-${#MENUTITLE})/2))  # this computes the number of leading spaces needed
                                      # to center the menu title
printf "%*s%s\n\n" ${SPACES} " " "${MENUTITLE}"  # actually print the menu title
select menuitem in "${MENU[@]}"       # show the menu
do
   if [[ ! "${REPLY}" =~ ${regex} ]]  # if the user did not enter an unsigned integer
   then
     printf "'%s' is not even an unsigned integer!\n" ${REPLY} 1>&2  # show the error
     printf "You need to choose an integer in the range from 1 to %u\n" \
       ${#MENU[@]} 1>&2
     continue                 # and show menu again
   fi
   if ((REPLY>${#MENU[@]})) || ((REPLY<1))   # if their reply was out of range
   then
     printf "%u is not even a choice on the menu!\n" ${REPLY}  1>&2  # show the error
     continue                 # and show menu again
   fi
   # printf "You want to %s, which was choice %u\n" "${menuitem}" ${REPLY}
   break                      # if we got this far, the choice is valid so exit the loop
done
PS3="${OLDPS3}"    # restore PS3 prompt
case ${REPLY} in   # respond to choice with a message corresponding to each menu choice
  1) printf "One\n"
     ;;
  2) printf "How about a Big Gulp?\n"
     ;;
  3) printf "Mr. Ham's class is a popular place to sleep.\n"
     ;;
  4) printf "Never talk to real people face-to-face.  That requires\n"
     printf "a lot of courage and reveals the real you.\n"
     ;;
  5) printf "Never do today what you can do tomorrow.\n"
     ;;
  6) printf "Remember, wait for somebody else to decide, then follow\n"
     printf "and blame them if something goes wrong but be quick to\n"
     printf "take the credit if things work out well.\n"
     ;;
  7) printf "Study?  Yeah, I'll study the rules to force a retest...\n"
     ;;
  *) printf "Unsupported choice, go away!\n"
     ;;
esac
exit 0            # and exit program indicating success
