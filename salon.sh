#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

SERVICES=$($PSQL "SELECT service_id, name FROM services")
echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU()
{
    if [[ -z $1 ]]
    then
        echo "$SERVICES" | while read ID BAR NAME
        do
            if [[ ID != "service_id" ]]
            then echo "$ID) $NAME"
            fi 
        done
    else
        echo -e "$1\n"
        echo "$SERVICES" | while read ID BAR NAME
        do
            if [[ ID != "service_id" ]]
            then echo "$ID) $NAME"
            fi 
        done
    fi
    
    SELECT_SERVICE
}


SELECT_SERVICE()
{
    read SERVICE_ID_SELECTED
    SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
        MAIN_MENU "\nI could not find that service. What would you like today?"
    else
        CHECK_SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
        if [[ -z $CHECK_SERVICE_ID ]]
        then
            MAIN_MENU "\nI could not find that service. What would you like today?"
        else 
            echo -e "\nWhat's your phone number?" 
            read CUSTOMER_PHONE
            PHONE_NUMBER_QUERY=$($PSQL "SELECT phone FROM customers WHERE phone='$CUSTOMER_PHONE'")
            if [[ -z $PHONE_NUMBER_QUERY ]]
            then
                echo -e "\nI don't have a record for that phone number, what's your name?"
                read CUSTOMER_NAME
                echo -e "\nWhat time would you like your $SERVICE, $CUSTOMER_NAME?"
                read SERVICE_TIME
                NEW_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
                CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
                NEW_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
                echo -e "\nI have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
            else
                CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
                echo -e "\nWhat time would you like your $SERVICE, $CUSTOMER_NAME?"
                read SERVICE_TIME
                CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
                NEW_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
                echo -e "\nI have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
                
            fi
        fi
    fi
}

MAIN_MENU
