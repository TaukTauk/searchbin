#!/bin/bash



# I will present three parts for three option
# Without the functions, the code will be too bulky
# So functions are used in the script.
# For -s option,
# list down the items from /bin/* using "ls -l"
# but there will be too many codes to manage to get the specific string
# for loop is then used instead of "ls -l" 
# to get the last name, basename command is used
# to count the number of items, two loop is separated
# one is to count, one for display
# For -b option,
# first, I used if condition to check the size of the vlaue.
# later, case condition is used to choose the operators so that number of lines is 
# minimized and clear.
# two loops are also used here like option -s.
# inside case to choose operator, if condition is used together with calculation
# For -l option,
# "ls -l | grep ^l" which list the item in details and filter the item which starts 
# with l which means that the file type is symbolic
# but -L in if condition is better and used it 
# For getopts
# :s:b:l
# for s and b option, argument is required so colon is used but not in l option
# to check if there is arugument or not for l option, if contion is used
# For the entire script, 
# Whether if there is option or not is checked first,
# if there is no option or more than two arguments, it will be terminated
# if the option is not s , b , or l, it will be terminated
# if there is no argument in s and b or no valid byte value in b, it will be terminated
# if there is argument in l, it will be terminated.
# otherwise, it will be executed according to the option and argument.
# The commands ,conditions and loops used in the script: bc(to get float number), awk(get the last column)
# , echo(display the message in color), printf(display message in structured form),read IFS(read the value
# from input),stat(to get the size of the item),basename (to get the basename), funcitons(create the functions
# which will be called in main), getopts(to choose the options), exit 0 and 1(exit with error or success), 
# for loop(list down each item from /bin/*), while loop(iterate), case(choose the oprators and options) 
# ,and if condition(check the conditions)

#color code for blue
blue='\033[0;34m'
#color code for red
red='\033[0;31m'
#color code for green
green='\033[0;32m'
#color code for no color
reset='\033[0m'

# Function to format byte size
function unit() {
    # local variable 
    local size=$1
    # if size is less than 1024, the unit is byte
    if (( size < 1024 )); then
        #display the unit
        echo "${size} b"
    # if size is between 1024 and 1048576, the unit is kilobyte
    elif (( size < 1048576 )); then
        #display the unit by calcuting using bc to get float value
        echo "$(echo "scale=2; $size/1024" | bc) Kb"
    # if size is greater than 1048576, the unit is megabyte
    else
        #display the unit by calcuting using bc to get float value
        echo "$(echo "scale=2; $size/ 1048576" | bc) Mb"
    #end of if condition
    fi
}

#funtion to search the string
function string() {
    #local variablies
    local count=0
    local arg=$1
    #each item in /bin/*
    for i in /bin/*; do
        #if the argument given is found in /bin/*
        if  [[ $(basename "$i") == *"$arg"* ]]; then
            #the number of count is increased
            ((count++))
        fi
    #exit of for loop
    done
    #if there is no item found
    if [[ $count == "0" ]];then
        #display the exit message
        echo -e "${blue}No match found...${reset}"
        #exit with success
        exit 0
    fi
    #display number of matches
    echo -e "${green}$count${reset} matches found..."
    #column for display 
    printf "${blue}%-30s %10s${reset}\n" "NAME" "SIZE"
    
    for i in /bin/*; do
        if [[ $(basename "$i") == *"$arg"* ]]; then
            #display item and its size with unit
            printf "%-30s %10s \n" "$(basename "$i")" "$(unit $(stat -c %s "$i"))"
        fi
    done
}

# Function to get the items based on byte size
function bsize() {
    #local variable
    local bs=$1
    #read the input the user gives
    IFS=, read operator bytes_value <<< "$bs"
    #if the input is not digit
    if [[ ! $bytes_value =~ ^[0-9]+$ ]]; then
        #display error message and assign to stderr
        echo -e "${red}Invalid bytes value passed. Exiting... ${reset}" >&2
        #exit with error
        exit 1
    fi
    #local variable
    local count=0
    #each item in /bin/*
    for i in /bin/*; do
        #get the byte size of the item
        local size=$(stat -c %s "$i")
        #choose one among operators
        case "$operator" in
            #if size of the item is greater than the value given by the user, count will be increased by 1
            GT) if (( size > bytes_value )); then ((count++)); fi ;;
            #if size of the item is less than the value given by the user, count will be increased by 1
            LT) if (( size < bytes_value )); then ((count++)); fi ;;
            #if size of the item is less than or equal the value given by the user, count will be increased by 1
            LE) if (( size <= bytes_value )); then ((count++)); fi ;;
            #if size of the item is greater than or equal the value given by the user, count will be increased by 1
            GE) if (( size >= bytes_value )); then ((count++)); fi ;;
            #if size of the item is equal to the value given by the user, count will be increased by 1
            EQ) if (( size == bytes_value )); then ((count++)); fi ;;
            #if size of the item is not equal to the value given by the user, count will be increased by 1
            NE) if (( size != bytes_value )); then ((count++)); fi ;;
            #if the operators are not from the above, error message will be displayed with error exit code
            *) echo -e "${red}Invalid operator provided. Exiting...${reset}" >&2; exit 1 ;;
        #end of case
        esac
    done
    #if there is no item found
    if [[ $count == "0" ]];then
        #display the exit message
        echo -e "${blue}No match found...${reset}"
        #exit with success
        exit 0
    fi
    #display number of matches
    echo -e "${green}$count${reset} matches found..."
    #column for display 
    printf "${blue}%-30s %10s${reset}\n" "NAME" "SIZE"
    
    for i in /bin/*; do
        local size=$(stat -c %s "$i")
        case "$operator" in
            #display the item with its size with unit if its size is greater than value given
            GT) if (( size > bytes_value )); then printf "%-30s %10s \n" "$(basename "$i")" "$(unit $size)"; fi ;;
            #display the item with its size with unit if its size is less than value given
            LT) if (( size < bytes_value )); then printf "%-30s %10s \n" "$(basename "$i")" "$(unit $size)"; fi ;;
            #display the item with its size with unit if its size is less than or equal tovalue given
            LE) if (( size <= bytes_value )); then printf "%-30s %10s \n" "$(basename "$i")" "$(unit $size)"; fi ;;
            #display the item with its size with unit if its size is greater than or equal to value given
            GE) if (( size >= bytes_value )); then printf "%-30s %10s \n" "$(basename "$i")" "$(unit $size)"; fi ;;
            #display the item with its size with unit if its size is equal to value given
            EQ) if (( size == bytes_value )); then printf "%-30s %10s \n" "$(basename "$i")" "$(unit $size)"; fi ;;
            #display the item with its size with unit if its size is not equal to value given
            NE) if (( size != bytes_value )); then printf "%-30s %10s \n" "$(basename "$i")" "$(unit $size)"; fi ;;
            #if the operators are not from the above, error message will be displayed with error exit code
            *) echo -e "${red}Invalid operator provided. Exiting...${reset}" >&2; exit 1 ;;
        esac
    done
}

# Function to search for symbolic links and which they point to
function symlink() {
    #local variable
    local count=0
    #each item in /bin/*
    for i in /bin/*; do
        #if the item is symbolic link by filtering with -L
        if [[ -L "$i" ]]; then
            #number of count is increased
            ((count++))
        fi
    done
    #if there is no item found
    if [[ $count == "0" ]];then
        #display the exit message
        echo -e "${blue}No match found...${reset}"
        #exit with success
        exit 0
    fi
    #display number of items
    echo -e "${green}$count${reset} matches found..."
    #columns for display
    printf "${blue}%-30s %25s${reset}\n" "SYMBOLIC" "POINT TO"
    
    for i in /bin/*; do
        if [[ -L "$i" ]]; then
            #local variable for which the item point to # list the item from /bin/* and take the last part of it.
            local point=$(ls -l "$i" | awk '{print $NF}')
            #display the symbolic link with its point
            printf "%-30s %25s \n" "$(basename "$i")" "$(basename "$point")"
        fi
    done
}

# Main script
# check if there is argument or not| if there is no argument,
if [ $# -eq 0 ]; then
    #exit with error message 
    echo -e "${red}No options/args passed. Exiting...${reset}"
    #exit with error
    exit 1
fi
# if there is more than 2 arguments,
if [ $# -gt 2 ]; then
    #exit with specific error message
    echo -e "${red} Multiple arguments are passed. Please try again. Exiting...${reset}"
    #exit with error
    exit 1
fi

# available options using getopts
while getopts ":s:b:l" opt; do
    # choose the options
    case "$opt" in
        # for option -s, string funciton will be performed
        s) string "$OPTARG" ;;
        # for option -b, bsize funciton will be performed
        b) bsize "$OPTARG" ;;
        # for option -l, symlink funciton will be performed. 
        # but it will only performed if there is no argument
        l) if [[ $2 == "" ]];then
                symlink
            # if there is an argument
            else 
            # terminate with erro message
                echo -e "${red}No argment is required for option -l.${reset}"
                #exit with error
                exit 1
            fi
            ;;
        # if there is no argument for -s and -b option, display error message
        :)
            echo -e "${red}Missing argument.Exiting...${reset}" >&2; exit 1 ;;
        # if the option passed is not from the list above, display error message
        \?)
            echo -e "${red}Invalid -$OPTARG passed.Exiting...${reset}" >&2; exit 1 ;;
    esac
    # after certain option is executed, exit with success.
    exit 0  
done


