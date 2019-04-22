#! /bin/bash
subby () {
	printf "I hate this class so much\n"
}
subb2 () {
	print "I love this class so much\n"
}
S="printf \"%s\\n" \"Hi Mom!\\n\""
eval ${S}
S="for ((i=1;i<5;i++));do echo \${i};done"
eval ${S}
read -p "Enter 1 or 2:" i
S="Subby()
RETVAL={?}
printf
exit ${?}
