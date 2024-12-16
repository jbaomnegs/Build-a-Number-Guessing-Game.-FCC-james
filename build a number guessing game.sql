#!/bin/bash
# Added welcome message for clarity
# This is a simple Number Guessing Game script
echo "Welcome to the Number Guessing Game!"

# 連接資料庫的 PSQL 命令
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# 隨機生成 1 到 1000 的數字
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

# 計算用戶猜測的次數
NUMBER_OF_GUESSES=0

# 提示用戶輸入用戶名
echo "Enter your username:"
read USERNAME

# 查詢用戶資料
USER_INFO=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME'")

# 判斷用戶是否存在
if [[ -z $USER_INFO ]]; then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  # 新用戶插入資料庫
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
else
  # 已存在用戶，顯示歡迎信息
  IFS="|" read GAMES_PLAYED BEST_GAME <<< "$USER_INFO"
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# 開始猜數字遊戲
echo "Guess the secret number between 1 and 1000:"
while true; do
  read GUESS

  # 檢查輸入是否為整數
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
      # 更新資料庫中的遊戲記錄
      UPDATE_RESULT=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE username='$USERNAME'")
      # 更新最佳遊戲記錄
      if [[ -z $BEST_GAME || $NUMBER_OF_GUESSES -lt $BEST_GAME ]]; then
        UPDATE_BEST=$($PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESSES WHERE username='$USERNAME'")
      fi
      break
    fi
  fi
done

