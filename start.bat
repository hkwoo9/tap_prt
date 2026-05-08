@echo off
chcp 65001 > nul
echo Gigamon TAP 도식화 서버 기동 중...
pip install -r requirements.txt -q
python server.py
pause
