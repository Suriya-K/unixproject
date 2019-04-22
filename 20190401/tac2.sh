#! /bin/bash
# Partial clone of 'tac' command

tac_a_file () {
  local -a LINES

  if [ -r "${1}" ] &&         # if we can read the file
     [ -f "${1}" ]            # and it is a normal file
  then
    exec 9< "${1}"            # open the file for input as file #9
    mapfile -t -u 9 LINES     # bulk read file #9 lines into the
                              # LINES integer-index array
    exec 9<&-                 # close file #9
    for ((i=${#LINES[@]};i>0;--i)) # for each line in LINES (in backwards order)
    do
      printf "%s\n" "${LINES[$((i-1))]}" # show the line
    done
    return 0                  # return indicating success
  fi
  return 1                    # return indicating failure
}

usage () {
  printf "Usage:\n"
  printf "  %s filename ...\n" "${0##*/}"
  printf "  %s -V\n" "${0##*/}"
  printf "  -V     Show version number of this program.\n"
  printf "  -?     Show this helpful information ;-)\n"
  printf "  At least one filename must be specified.\n"
}

VERSION="1.0"                 # version number of this program is 1.0
((SHOWVERSION=0))             # initialize SHOWVERSION flag to false
((SHOWUSAGE=0))               # initialize SHOWUSAGE flag to zero
                              # tristate: 0 says do not show usage
                              #           1 says show usage and exit normally
                              #           2 says show usage and exit with error
while getopts ":V" item "${@}"   # while there are still options to process
do
  case "${item}" in           # item holds the option letter
      V) ((SHOWVERSION=1))    # set SHOWVERSION flag to true
         ;;
      ?) ((SHOWUSAGE=1))      # set SHOWUAGE flag to one
         if [[ -n "${OPTARG:-}" ]] &&      # if the option is not blank
            [ ! "${OPTARG:-}" = "?" ]      # and it is not -?
         then
           printf "Unknown switch \"%s\"\n" "${OPTARG:-}" 1>&2  # show error
           ((SHOWUSAGE=2))    # set SHOWUAGE flag to two
         fi
         ;;
  esac
done
shift $((OPTIND-1))      # remove all options and only leave list of files
((OPTIND=1))             # reset OPTIND
if ((SHOWVERSION==1))    # if the SHOWVERSION flag was set
then
  printf "%s: version is %s\n" "${0##*/}" "${VERSION}" # show the version
  exit 0                 # and exit with success
elif ((SHOWUSAGE>0))     # if the SHOWUSAGE flag is non-zero
then
  usage                  # show the usage
  exit $((SHOWUSAGE-1))  # and exit with error if the flag was two
elif ((${#}<1))          # if there were no filenames
then
  usage                  # show the usage
  exit 1                 # and exit with error
fi
((ERRORCOUNT=0))         # initialize ERRORCOUNT to zero
while ((${#}>0))         # while there are still more filenames
do
  if ! tac_a_file "${1}" # if we cannot tac the file
  then
    printf "Error: Unable to open file '%s' for input.\n" "${1}" 1>&2  # show error
    ((++ERRORCOUNT))     # and increment ERRORCOUNT by one
  fi
  shift                  # move to the next filename
done
exit $((ERRORCOUNT>0?1:0))  # exit with 1 if there were errors, zero otherwise
