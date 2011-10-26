#!/bin/bash
# (c) 2011 Erin "slowbro" Schiesser
# you can do whatever you want with this code as long as you retain credit

function msg(){
    echo -e "$1"
}

function prompt(){
    echo -n "> "
    read $1
}

function prompt_secret(){
    echo -n "> "
    read -s $1
    echo ""
}

function prompt_regex(){
    while [ 1=1 ];do   
        prompt $1
        val=`eval echo "\\$$1"`
        if [[ "$val" =~ $2 ]];then
            break;
        else
            msg "Sorry, input was invalid: $3"
        fi;
    done
}

function prompt_al(){
    prompt_regex $1 "^[A-Za-z]{1,}$" "A-z only!"
}

function prompt_alnum(){
    prompt_regex $1 "^[A-Za-z0-9]{1,}$" "A-z and 0-9 only!"
}

function login(){
    if [[ -f "$HOME/players/$1" ]];then
        userfile=`cat $HOME/players/$1`
        user_pass=`echo "$userfile" | grep ^password | cut -d'=' -f2`
        user_fname=`echo "$userfile" | grep ^fname | cut -d'=' -f2`
        user_lname=`echo "$userfile" | grep ^lname | cut -d'=' -f2`
        user_x=`echo "$userfile" | grep ^pos_x | cut -d'=' -f2`
        user_y=`echo "$userfile" | grep ^pos_y | cut -d'=' -f2`
        user_lastlog=`echo "$userfile" | grep ^lastlog | cut -d'=' -f2`
        checklogin $1
    else
        msg "\nWelcome to the MUD, $1! This looks like the first time I've seen you."
        newuser $1
    fi
}

function checklogin(){
    msg "Password, please."
    prompt_secret pass
    if [[ `echo $pass | sha1sum | cut -d' ' -f1` != $user_pass ]];then
        msg "Sorry, that's not correct."
        exit
    else
        msg "Welcome back, $1! I last saw you `date -d @$user_lastlog`."
        sed -i "s/lastlog=$user_lastlog/lastlog=`date +%s | tr -d '\n'`/" "$HOME/players/$1"
    fi
}

function newuser(){
    msg "I need to collect some info about you, for posterity.\nHow about a password?"
    passfail=1
    while [[ "$passfail" == "1" ]];do
        prompt_secret pass1
        msg "And again?"
        prompt_secret pass2
        if [[ "$pass1" == "$pass2" && "$pass1" != "" ]];then
            break
        else
            msg "Sorry, those passwords don't seem to match (or were blank). Try again!"
        fi
    done
    msg "Great, what is your first name?"
    prompt_al fname
    msg "And your last?"
    prompt_al lname
    msg "Thanks, your name is $fname $lname!"
    pass_hash=`echo $pass1 | sha1sum | cut -d' ' -f1`
    touch "$HOME/players/$name"
    echo "\
[$name]
password=$pass_hash
fname=$fname
lname=$lname
loc_x=0
loc_y=0
lastlog=`date +%s`
" > "$HOME/players/$name"
    msg "Okay, I have you down. be careful out there."
}

function showhelp(){
  case $1 in
    info)
        msg "info   : shows your player info. that's it."
    ;;

    set)
        msg "Sorry, no help is available for that yet."
    ;;

    exit)
        msg "exit  : exits you from the dungeon, believe it or not."
    ;;

    *)
    msg "\
Welcome to slowbro's MUD thing. There are a few commands you can use:

info    : show your player info.
set     : set certain things about your player. try typing 'help set' for more info.
help    : show this help. you can to 'help <item>' to get specific help about an item in this menu.
exit    : exit the dungeon.
"
  esac;
}

msg "Welcome to slowbro's MUD thing"
msg "What is your username?"
prompt_alnum name

login $name

msg "What would you like to do? Type 'help' for help, or 'exit' to exit."

while [ 1=1 ];do
    prompt in
    action=`echo $in | cut -d' ' -f1`
    rest=`echo $in | sed -e "s/$action //"`
    case $action in
        help)
            showhelp "$rest"
        ;;
        exit | bye | quit)
            msg "See ya!"
            exit
        ;;
        *)
            msg "Sorry, I don't know what that is. Try typing 'help'."
    esac
done
