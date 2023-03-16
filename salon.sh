#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "~~~Welcome to Cam's Clean Cut's!~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo "$1"
  else
    SERVICE_MENU
  fi
}

SERVICE_MENU() {
  echo "Which service would you like to book?"
  # get services
  SERVICES=$($PSQL "SELECT * FROM services")
  if [[ -z $SERVICES ]]
  then
    MAIN_MENU "Sorry, we have no services currently"
  else
    echo "$SERVICES" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME"
    done
  fi

  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    echo -e "\nYou didn't enter a number, please enter a number"
    SERVICE_MENU
  else
    #echo "Yes, this is a number - going on."
    SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED'")
    if [[ -z $SERVICE_NAME_SELECTED ]]
    then
      echo -e "\nThis service does not exist, try again"
      SERVICE_MENU
    else
      echo "Please enter your phone number"
      read CUSTOMER_PHONE_ENTERED
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE_ENTERED'")
      if [[ -z $CUSTOMER_NAME ]]
      then
        echo "The phone number you provided does not match with any customer in our database"
        echo "What's your name?"
        read CUSTOMER_NAME_ENTERED
        echo "Hello $CUSTOMER_NAME_ENTERED!"
        CREATE_NEW_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME_ENTERED','$CUSTOMER_PHONE_ENTERED')") 
        echo "For test purposes $CREATE_NEW_CUSTOMER_RESULT"
        echo "You have been successfully added to the database!"
      fi
      echo "When would you like to come?"
      read SERVICE_TIME_ENTERED
      #if [[ ! $SERVICE_TIME_ENTERED =~ ^[0-9]{1,2}:[0-9]{2}$|^[0-9]{1,2}am$|^[0-9]{1,2}pm$ ]]
      #then 
        #echo "Please enter a correct time format.."
      #else
        CUSTOMER_NAME_FROM_DB=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE_ENTERED'")
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE_ENTERED'")
        #BOOK_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$(echo $SERVICE_TIME_ENTERED | sed "s/pm/:00/;s/am/:00/;s/_//")')")
        #echo "I have put you down for a $(echo $SERVICE_NAME_SELECTED | sed "s/^ //") at $(echo $SERVICE_TIME_ENTERED | sed "s/pm/:00/;s/am/:00/;s/_//"), $(echo $CUSTOMER_NAME_FROM_DB | sed "s/^ //")."

        BOOK_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME_ENTERED')")
        echo "I have put you down for a $(echo $SERVICE_NAME_SELECTED | sed "s/^ //") at $SERVICE_TIME_ENTERED, $(echo $CUSTOMER_NAME_FROM_DB | sed "s/^ //")."
      #fi
    fi
  fi
}

MAIN_MENU