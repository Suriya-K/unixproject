#! /bin/bash
udf() {
	local -a ALICE
	local i=0
	while((${#}>0))
	do
		printf "udf '%s'\n" "${1}"
		shift
	done
	printf "exit udf\n"
}
MENU=("Choice A" "Choice B" "Choice C")
printf
echo ${MENU}
echo ${MENU[0]}
echo ${MENU[@]}
echo ${#MENU[@]}
echo ${!MENU[@]}
