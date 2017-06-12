#!/bin/bash

menu () {
    PS3='What do you want to do? : '
    options=("Disable \"Menu Item 1\"" "Disable \"Menu Item 2\"" \
        "Disable \"Menu Item 3\"" "Enable \"Menu Item 1\"" \
        "Enable \"Menu Item 2\"" "Enable \"Menu Item 3\"" "Quit")
    select opt in "${options[@]}"
    do
        case $opt in
            "Disable \"Menu Item 1\"")
            	echo "Disabling \"Menu Item 1\""
            	policyId=1
                state=false
            	break
                ;;
            "Disable \"Menu Item 2\"")
            	echo "Disabling \"Menu Item 2\""
            	policyId=2
                state=false
            	break
                ;;
            "Disable \"Menu Item 3\"")
            	echo "Disabling \"Menu Item 3\""
            	policyId=3
                state=false
            	break
                ;;
            "Enable \"Menu Item 1\"")
                echo "Enabling \"Menu Item 1\""
                policyId=1
                state=true
                break
                ;;
            "Enable \"Menu Item 2\"")
                echo "Enabling \"Menu Item 2\""
                policyId=2
                state=true
                break
                ;;
            "Enable \"Menu Item 3\"")
                echo "Enabling \"Menu Item 3\""
                policyId=3
                state=true
                break
                ;;
            "Quit")
                exit
                ;;
            *) echo invalid option;;
        esac
    done
}

menu
