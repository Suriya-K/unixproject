#! /bin/bash
# Partial clone of 'wc' command

# get the number of words on a line, where words are space-separted
# this subroutine is very tricky....
get_line_word_count () {
  set -f                       # temporarily disable shell globbing
  set -- ${1}                  # split line by IFS (tabs and spaces)
                               # and assign it to arguments 1..#
  set +f                       # re-enable shell globbing
  printf "%u\n" ${#}           # print number of arguments (words) to return it
}

usage () {
  printf "Usage:\n"
  printf "  %s [options] filename [...]\n" "${0##*/}"
  printf "  %s -V\n" "${0##*/}"
  printf "  -V     Show version number of this program.\n"
  printf "  -c     Show byte counts.\n"
  printf "  -l     Show line counts.\n"
  printf "  -?     Show this helpful information ;-)\n"
  printf "  At least one filename must be specified.\n"
}

get_counts () {
  local bytecount linecount wordcount
  local -a LINES

  if [ -r "${1}" ] &&           # if we can read the file
     [ -f "${1}" ]              # and it is a regular file
  then
    exec 9< "${1}"              # open the file for input as file #9
    mapfile -u 9 LINES          # bulk load file #9 into LINES array
    exec 9<&-                   # close file #9
    ((bytecount=0))             # initialize bytecount to zero
    ((linecount=${#LINES[@]}))  # linecount is number of elements in LINES array
    ((wordcount=0))             # initialize wordcount to zero
    for ((i=0;i<linecount;++i)) # for each line in the LINES array
    do
      ((bytecount+=${#LINES[i]}))                          # add the bytecount
      ((wordcount+=$(get_line_word_count "${LINES[i]}")))  # add the word count
    done
    printf "%u %u %u\n" ${linecount} ${wordcount} ${bytecount}  # return the counts
    return 0    # indicate successful return
  fi
  return 1      # indicate failure return
}

VERSION="1.0"                 # version number of this program is 1.0
((SHOWVERSION=0))             # initialize SHOWVERSION flag to false
((WANTBYTES=0))               # initialize WANTBYTES flag to false
((WANTLINES=0))               # initialize WANTLINES flag to false
((SHOWUSAGE=0))               # initialize SHOWUSAGE flag to zero
                              # tristate: 0 says do not show usage
                              #           1 says show usage and exit normally
                              #           2 says show usage and exit with error
while getopts ":Vcl" item "${@}"   # while there are still options to process
do
  case "${item}" in           # item holds the option letter
      V) ((SHOWVERSION=1))    # set SHOWVERSION flag to true
         ;;
      c) ((WANTBYTES=1))      # set WANTBYTES flag to true
         ;;
      l) ((WANTLINES=1))      # set WANTLINES flag to true
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
  exit 0                 # and exit normally
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
((filecount=0))          # initialize filecount to zero
((totalbytes=0))         # initialize totalbytes to zero
((totallines=0))         # initialize totallines to zero
# this regex matches the 3 values returned by get_counts
# which are counts of lines, words, and bytes
regex='([[:digit:]]+) ([[:digit:]]+) ([[:digit:]]+)'
while ((${#}>0))         # while there are still more filenames
do
  retval=$(get_counts "${1}") # call get_counts() and put retun value in retval
  if ((${?}!=0))         # if get_counts() returned an error
  then
    printf "Error: Unable to open file '%s' for input.\n" "${1}" 1>&2 # show error message
    ((++ERRORCOUNT))     # increment ERRORCOUNT by one
    shift                # move to next file
    continue             # and jump to next loop iteration
  fi
  if [[ ! "${retval}" =~ ${regex} ]] # if returned information does not match our regex
  then
    printf "Error: Counts are garbled for file '%s'.\n" "${1}" 1>&2  # show error message
    ((++ERRORCOUNT))     # increment ERRORCOUNT by one
    shift                # move to next file
    continue             # and jump to next loop iteration
  fi
  if ((WANTBYTES==1)) && ((WANTLINES==1)) # if the user specified both -c and -l
  then
    printf "%8u\t%8u\t%s\n" ${BASH_REMATCH[1]} ${BASH_REMATCH[3]} "${1}" # show byte and line counts and filename
  elif ((WANTBYTES==1))                   # else if the user specified -c
  then
    printf "%8u\t%s\n" ${BASH_REMATCH[3]} "${1}" # show byte count and filename
  elif ((WANTLINES==1))                   # else if the user specified -l
  then
    printf "%8u\t%s\n" ${BASH_REMATCH[1]} "${1}" # show line count and filename
  else                                    # otherwise show all counts and filename
    printf "%8u\t%8u\t%8u\t%s\n" ${BASH_REMATCH[1]} ${BASH_REMATCH[2]} ${BASH_REMATCH[3]} "${1}"
  fi
  ((++filecount))                         # increment number of files processed by one
  ((totallines+=${BASH_REMATCH[1]}))      # add this file's linecount to totallines
  ((totalwords+=${BASH_REMATCH[2]}))      # add this file's wordcount to totalwords
  ((totalbytes+=${BASH_REMATCH[3]}))      # add this file's bytecount to totalbytes
  shift                                   # move to the next filename
done
if ((filecount>1))                        # if there multiple files we need to show totals
then
  if ((WANTBYTES==1)) && ((WANTLINES==1)) # if the user specified both -c and -l
  then
    printf "%8u\t%8u\ttotal\n" ${totallines} ${totalbytes} # show total line and byte counts
  elif ((WANTBYTES==1))                   # else if the user specified -c
  then
    printf "%8u\ttotal\n" ${totalbytes}   # show total byte count
  elif ((WANTLINES==1))                   # else if the user specified -l
  then
    printf "%8u\ttotal\n" ${totallines}   # show total line count
  else                                    # otherwise
    printf "%8u\t%8u\t%8u\ttotal\n" ${totallines} ${totalwords} ${totalbytes} # show line, word and byte totals
  fi
fi
exit $((ERRORCOUNT>0?1:0))   # exit with 1 if there were errors, zero otherwise
