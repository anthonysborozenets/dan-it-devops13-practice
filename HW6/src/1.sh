#!/bin/bash

SECRET_NUMBER=$((RANDOM % 100 + 1))
MAX_ATTEMPTS=5
ATTEMPT=1

echo "I'm thinking of a number between 1 and 100."
echo "You have $MAX_ATTEMPTS attempts to guess it."

while [ $ATTEMPT -le $MAX_ATTEMPTS ]; do
  read -r -p "Attempt $ATTEMPT: Enter your guess: " GUESS

  # Check if input is a number
  if ! [[ "$GUESS" =~ ^[0-9]+$ ]]; then
    echo "Please enter a valid number."
    continue
  fi

  if [ "$GUESS" -eq "$SECRET_NUMBER" ]; then
    echo "Congratulations! You guessed the right number."
    exit 0
  elif [ "$GUESS" -gt "$SECRET_NUMBER" ]; then
    echo "Too high."
  else
    echo "Too low."
  fi

  ATTEMPT=$((ATTEMPT + 1))
done

echo "Sorry, you've run out of attempts. The correct number was $SECRET_NUMBER."
exit 1

