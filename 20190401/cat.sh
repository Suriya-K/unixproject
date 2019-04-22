#! /bin/bash
# Partial clone of 'cat' command

cat_a_file () {
  local OLDIFS ALINE

  if [ -r "${1}" ] &&         # if we can read the file
     [ -f "${1}" ]            # and it is a normal file
  then
    exec 9< "${1}"            # open the file for input as file #9
    OLDIFS="${IFS}"           # backup the current IFS
    IFS=""                    # set IFS to nothing to prevent splitting
    while read -r -u9 ALINE   # while we can read another line from file #9
    do
      if ((SHOWNUMBERS==1))   # if the user specified -n
      then
        printf "%6u\t%s\n" $((++CURNO)) "${ALINE}"   # show the linenumber and line
                                                     # and increment CURNO by one
      else
        printf "%s\n" "${ALINE}"  # show the line
      fi
    done
    IFS="${OLDIFS}"           # restore old IFS
    exec 9<&-                 # close file #9
    return 0                  # return indicating success
  fi
  return 1                    # return indicating failure
}

usage () {
  printf "Usage:\n"
  printf "  %s filename [...]\n" "${0##*/}"
  printf "  %s -V\n" "${0##*/}"
  printf "  -V     Show version number of this program.\n"
  printf "  -n     Show line numbers.\n"
  printf "  -?     Show this helpful information ;-)\n"
  printf "  At least one filename must be specified.\n"
}

VERSION="1.0"                 # version number of this program is 1.0
((CURNO=0))                   # initialize current line number to zero
                              # displayed line numbers are one-based
((SHOWVERSION=0))             # initialize SHOWVERSION flag to false
((SHOWNUMBERS=0))             # initialize SHOWNUMBERS flag to false
((SHOWUSAGE=0))               # initialize SHOWUSAGE flag to zero
                              # tristate: 0 says do not show usage
                              #           1 says show usage and exit normally
                              #           2 says show usage and exit with error
while getopts ":Vn" item "${@}"   # while there are still options to process
do
  case "${item}" in           # item holds the option letter
      V) ((SHOWVERSION=1))    # set SHOWVERSION flag to true
         ;;
      n) ((SHOWNUMBERS=1))    # set SHOWNUMBERS flag to true
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
  exit 0
elif ((SHOWUSAGE>0))     # if the SHOWUSAGE flag is non-zero
then
  usage                  # show the usage
  exit $((SHOWUSAGE-1))  # and exit with error if the flag was two
fi
if ((${#}<1))            # if there were no filenames
then
  usage                  # show the usage
  exit 1                 # and exit with error
fi
((ERRORCOUNT=0))         # initialize ERRORCOUNT to zero
while ((${#}>0))         # while there are still more filenames
do
  if ! cat_a_file "${1}" # if we cannot cat the file
  then
    printf "Error: Unable to open file '%s' for input.\n" "${1}" 1>&2  # show error
    ((++ERRORCOUNT))     # and increment ERRORCOUNT by one
  fi
  shift                  # move to the next filename
done
exit $((ERRORCOUNT>0?1:0))  # exit with 1 if there were errors, zero otherwise
