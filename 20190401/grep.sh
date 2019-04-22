#! /bin/bash
# Partial clone of 'grep' command

# This requires 2 arguments, first is filename, and second is line of text to show
showline () {
  if ((SINGLE==1))                 # if there is only one file
  then
    printf "%s\n" "${2}"           # then just show the matching line
  else                             # otherwise there are multiple files, so
    printf "%s:%s\n" "${1}" "${2}" # show the filename and the matching line
  fi
}

usage () {
  printf "Usage:\n"
  printf "  %s regex filename [...]\n" "${0##*/}"
  printf "  %s -V\n" "${0##*/}"
  printf "  -V     Show version number of this program.\n"
  printf "  -v     Show lines that do NOT match instead.\n"
  printf "  -?     Show this helpful information ;-)\n"
  printf "  At least one filename must be specified.\n"
}

# returns 0 for success
#         1 for unreadable file or not normal file except directory
#         2 for directory
grep_a_file () {
  local OLDIFS ALINE

  if [ -d "${1}" ]            # if the filename is actually a directory
  then
    return 2                  # return error code 2
  elif [ -r "${1}" ] &&       # if the file is readable
       [ -f "${1}" ]          # and is a regular file
  then
    exec 9< "${1}"            # open the file for input as file #9
    OLDIFS="${IFS}"           # backup the current IFS
    IFS=""                    # set IFS to nothing to prevent splitting
    while read -r -u9 ALINE   # while we can read another line from file #9
    do
      if ((INVERT==1))        # if the -v flag was specified
      then
        if [[ ! "${ALINE}" =~ ${regex} ]] # if the line does not match the pattern
        then
          showline "${1}" "${ALINE}"      # show the line
        fi
      else                    # otherwise
        if [[ "${ALINE}" =~ ${regex} ]]   # if the line matches the pattern
        then
          showline "${1}" "${ALINE}"      # show the line
        fi
      fi
    done
    IFS="${OLDIFS}"           # restore old IFS
    exec 9<&-                 # close file #9
    return 0                  # return indicating success
  fi
  return 1                    # return error code 1
}

VERSION="1.0"                 # version number of this program is 1.0
((SHOWVERSION=0))             # initialize SHOWVERSION flag to false
((INVERT=0))                  # initialize INVERT flag to false
((SHOWUSAGE=0))               # initialize SHOWUSAGE flag to zero
                              # tristate: 0 says do not show usage
                              #           1 says show usage and exit normally
                              #           2 says show usage and exit with error
while getopts ":Vv" item "${@}"   # while there are still options to process
do
  case "${item}" in           # item holds the option letter
      V) ((SHOWVERSION=1))    # set SHOWVERSION flag to true
         ;;
      v) ((INVERT=1))         # set INVERT flag to true
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
shift $((OPTIND-1))           # remove all options and only leave list of files
((OPTIND=1))                  # reset OPTIND
if ((SHOWVERSION==1))         # if the SHOWVERSION flag was set
then
  printf "%s: version is %s\n" "${0##*/}" "${VERSION}"  # show the version
  exit 0                      # and exit normally
elif ((SHOWUSAGE>0))          # if the SHOWUSAGE flag is non-zero
then
  usage                       # show the usage
  exit $((SHOWUSAGE-1))       # and exit with error if the flag was two
elif ((${#}<2))               # if there not at least a pattern and a filename
then
  usage                       # show the usage
  exit 1                      # and exit with error
fi
regex="${1}"                  # save the first non-option argument as the pattern
shift                         # move to the first filename
((SINGLE=(${#}==1)?1:0))      # if there is only 1 filename, set SINGLE to true
                              # otherwise set it to false
((ERRORCOUNT=0))              # initialize ERRORCOUNT to zero
while ((${#}>0))              # while there are more filenames
do
  grep_a_file "${1}"          # try to grep the current file for the pattern
  case ${?} in
    0) # everything is OK, so do nothing
       ;;
    1) printf "Error: Unable to open file '%s' for input.\n" "${1}" 1>&2  # show error
       ((++ERRORCOUNT))       # and increment ERRORCOUNT by one
       ;;
    2) printf "grep: %s: Is a directory\n" "${1}" 1>&2  # show error
       ((++ERRORCOUNT))       # and increment ERRORCOUNT by one
       ;;
  esac
  shift                       # move to the next filename
done
exit $((ERRORCOUNT>0?1:0))    # exit with 1 if there were errors, zero otherwise
