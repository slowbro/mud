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

function getparam(){
   echo `echo "$userfile" | grep ^$1 | cut -d'=' -f2`
}

function loaduserfile(){
    export userfile=`cat $HOME/players/$1`
}

function login(){
    if [[ -f "$HOME/players/$1" ]];then
        loaduserfile $1
        checklogin $1
    else
        msg "\nWelcome to the MUD, $1! This looks like the first time I've seen you."
        newuser $1
    fi
}

function checklogin(){
    msg "Password, please."
    prompt_secret pass
    if [[ `echo $pass | sha1sum | cut -d' ' -f1` != $(getparam password) ]];then
        msg "Sorry, that's not correct."
        exit
    else
        msg "Welcome back, $1! I last saw you `date -d@$(getparam lastlog) +%m/%d/%Y\ %H\:%M`."
        updateparam $1 "lastlog" "`date +%s | tr -d '\n'`"
    fi
}

function newuser(){
    msg "I need to collect some info about you, for posterity.\nHow about a password for this account?"
    while [ 1==1 ];do
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
registered=`date +%s`
lastlog=`date +%s`
gold=100
char=0
stam=0
atk=0
def=0
dex=0
magic=0
level=1
mana=200
health=200
" > "$HOME/players/$name"
    loaduserfile $name
    msg "Okay, I have you down. Be careful out there."
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

function showplayerinfo(){
    if [[ "$1" == "$name" ]];then
        msg "\
Player Info: $1
-------------------------

       Name: $(getparam fname) $(getparam lname)
 Registered: `date -d @$(getparam registered) +%m/%d/%Y\ %H\:%M`
   Location: ($(getparam loc_x),$(getparam loc_y))
      Level: $(getparam level)
       Gold: $(getparam gold)
     Health: $(getparam health)
       Mana: $(getparam mana)

          Stats
        ---------

  Char: $(getparam char)  \t Atk: $(getparam atk)
   Dex: $(getparam dex)  \t Def: $(getparam def)
 Magic: $(getparam magic)  \tStam: $(getparam stam)
"
    fi
}

function updateparam(){
    sed -i "s/$2=.*/$2=$3/" "$HOME/players/$1"
    loaduserfile $1
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
        info)
            showplayerinfo $name
        ;;
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
