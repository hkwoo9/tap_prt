#!/bin/bash
echo "Gigamon TAP 도식화 서버 기동 중..."
pip3 install -r requirements.txt -q
python3 server.py
