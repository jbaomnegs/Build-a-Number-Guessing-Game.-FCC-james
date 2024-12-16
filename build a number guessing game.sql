#!/bin/bash
# Added welcome message for clarity
# This is a simple Number Guessing Game script
echo "Welcome to the Number Guessing Game!"

# PSQL commands to connect to the database
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Randomly generate a number from 1 to 1000
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

# Count the number of guesses made by the user
NUMBER_OF_GUESSES=0

# Prompt user to enter username
echo "Enter your username:"
read USERNAME

# Query user information
USER_INFO=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME'")

# Determine whether the user exists
if [[ -z $USER_INFO ]]; then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  # Insert new user into database
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
else
  # User already exists, display welcome message
  IFS="|" read GAMES_PLAYED BEST_GAME <<< "$USER_INFO"
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Start guessing number game
echo "Guess the secret number between 1 and 1000:"
while true; do
  read GUESS

  # Checks if the input is an integer
  if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
  else
    ((NUMBER_OF_GUESSES++))
    if [[ $GUESS -lt $SECRET_NUMBER ]]; then
      echo "It's higher than that, guess again:"
    elif [[ $GUESS -gt $SECRET_NUMBER ]]; then
      echo "It's lower than that, guess again:"
    else
      echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
      # Update game records in the database
      UPDATE_RESULT=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE username='$USERNAME'")
      # Update best game record
      if [[ -z $BEST_GAME || $NUMBER_OF_GUESSES -lt $BEST_GAME ]]; then
        UPDATE_BEST=$($PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESSES WHERE username='$USERNAME'")
      fi
      break
    fi
  fi
done

