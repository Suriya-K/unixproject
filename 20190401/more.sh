#! /bin/bash
# A partial clone of 'more'

if ((${#}!=1))                # if the number of arguments is not exactly 1
then
  printf "%s requires exactly one filename argument.\n" "${0}" 1>&2 # show error
  exit 1                      # and exit with an error
fi
if [ ! -r "${1}" ] ||         # if the file is not readable
   [ ! -f "${1}" ]            # or is not a normal file
then
  printf "File '%s' cannot be opened for input or is not a regular file.\n" "${1}" 1>&2 # show error
  exit 1                      # and exit with error
fi
# some truly ugly stuff to get the LINES and COLUMNS
# magic variables set to the proper values
shopt -s checkwinsize         # this requires we run an external command
                              # to make it update LINES and COLUMNS built-in magic variables
enable -n echo                # disable built-in echo
echo "crud" >/dev/null 2>&1   # run external echo command, discarding output
enable echo                   # re-enable built-in echo
# use fall-back values of 1 line, 80 columns
: ${LINES:=1}
: ${COLUMNS:=80}
if ((LINES<2))
then
  printf "Only 1 line in terminal, but I need at least 2 to run.\n" 1>&2 # show error
  exit 1
fi

declare -a FILELINES
exec 9< "${1}"                     # open the file for input as file #9
mapfile -t -n 0 -u 9 FILELINES     # bulk read all lines in file #9 into FILELINES
                                   # integer-index array
exec 9<&-                          # close file #9

((curoffset=0))                    # initialize curoffset to zero
((maxoffset=${#FILELINES[@]}-LINES+1)) # set maxoffset = (number of lines in file) - 
                                       #                 (number of lines on terminal) - 1
                                       # The 1 is to save room for the prompt at the bottom
                                       # of the terminal
if ((maxoffset<0))                 # if there aren't enough lines to fill the screen
then
  ((maxoffset=0))                  # set maxoffset to zero
fi
OLDIFS="${IFS}"                    # backup current IFS
IFS=""                             # and set IFS to nothing to allow space as input
while ((i+curoffset<=${#FILELINES[@]}))
do
  clear -x                         # comment this out if your clear doesn't handle -x
                                   # the clear is just to cut down on screen flicker...
  # show a screenfull (or the remaining lines if there isn't an
  # an entire screenfull left)
  for ((i=0;(i+curoffset<${#FILELINES[@]}) && (i<LINES-1);++i))
  do
    printf "%s\n" "${FILELINES[$((i+curoffset))]}"
  done
  if ((i+curoffset==${#FILELINES[@]})) # if all lines have been shown
  then
    break                              # break out of while loop
  fi
  read -p ":" -n 1 WHAT                # prompt with a colon and get 1 byte from STDIN from user
  case "${WHAT}" in                    # if WHAT is a
    " ") printf "\n"                   # space
         ((curoffset+=(LINES-1)))      # update curoffset to show another screenfull
         if ((curoffset>maxoffset))    # if there isn't an entire screenfull left
         then
            ((curoffset=maxoffset))    # then update it to show the remaining lines
         fi
         ;;
    "")  ((++curoffset))               # return then increment curoffset by 1
         ;;
    q)   printf "\n"                   # letter q
         break 2                       # break out of case AND while
         ;;
    *)   ;;
  esac
done
IFS="${OLDIFS}"                    # restore IFS
exit 0                             # exit program indiciating success
