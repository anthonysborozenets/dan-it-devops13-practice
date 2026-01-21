#!/bin/bash

read -r -p "який файл: " FILENAME

if [ -f "$FILENAME" ]; then
  echo "Файл '$FILENAME' є"
else
  echo "Файл '$FILENAME' нема"
fi
