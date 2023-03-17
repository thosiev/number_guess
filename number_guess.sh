#! /bin/bash

# DB Connection
PSQL="psql --username=freecodecamp --dbname=guessing_game -t --no-align -c"

# create a random number
random_number=$((( $RANDOM % 1000 )  + 1 ))

# Read a user name, which is not longer than 22 char
username=""
while [ -z $username ]
do
  echo "Enter your username:"
  read username
  size_username=${#username}
  if [[ $size_username -gt 22 ]]
  then
    echo "Username to long!"
    username=""
fi
done

# check if username already exists
username_in_db=$($PSQL "SELECT user_name FROM users WHERE user_name='$username'")


# create new user if not 
if [[ -z $username_in_db ]] 
then
create_user=$($PSQL "INSERT INTO users(user_name) VALUES ('$username')")
echo "Welcome, $username! It looks like this is your first time here."
else
# retrieve infos from db
user_id=$($PSQL "SELECT user_id FROM users WHERE user_name='$username'")
username=$($PSQL "SELECT user_name FROM users WHERE user_name='$username'")
games_played=$($PSQL "SELECT count(game_id) FROM game WHERE user_id=$user_id")
best_game=$($PSQL "SELECT min(number_of_attempts) FROM game AS g INNER JOIN users AS u ON g.user_id = u.user_id ")
echo "Welcome back, $username! You have played $games_played games, and your best game took $best_game guesses."
fi

user_id=$($PSQL "SELECT user_id FROM users WHERE user_name='$username'")

# Message to start the game
echo "Guess the secret number between 1 and 1000:"
# echo $random_number

# game loop
solved="false"
number_of_guesses=1


while [ $solved != "ture" ] 
do
read input

# input not a number 
if [[ ! $input =~ ^[0-9]+$ ]]
then
 echo "That is not an integer, guess again:"
# input is the number
elif [[ $input -eq $random_number ]]
then
 echo "You guessed it in $number_of_guesses tries. The secret number was $random_number. Nice job!"
 solved="true"
 # insert info in DB
 insert_result=$($PSQL "INSERT INTO game (user_id,number_of_attempts) VALUES ($user_id,$number_of_guesses)")

 break
# lower than number
elif [[ $input -ge $random_number ]]
then
echo "It's lower than that, guess again:"
# bigger than number
elif [[ $input -le $random_number ]] 
then 
echo "It's higher than that, guess again:"
fi

let "number_of_guesses++"

done
