@echo off
cd flutter_questions_backend
start cmd /k "node index.js"
start cmd /k "node captcha.js"
timeout /t 3 /nobreak >nul
cd ../flutter_questions
call flutter clean
call flutter pub get
start "" flutter run -d chrome --web-port=59792 --web-browser-flag="--disable-cache"