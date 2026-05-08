#!/usr/bin/env python3
"""Gigamon TAP 도식화 — 웹서버
실행: python server.py
"""
from flask import Flask, request, jsonify, send_from_directory
import os, socket

app = Flask(__name__)
BASE = os.path.dirname(os.path.abspath(__file__))

@app.route('/')
def index():
    return send_from_directory(BASE, 'index.html')

@app.route('/api/fetch-config', methods=['POST'])
def fetch_config():
    d = request.get_json() or {}
    host     = (d.get('host') or '').strip()
    port     = int(d.get('port') or 22)
    username = (d.get('username') or '').strip()
    password = d.get('password') or ''
    if not host or not username:
        return jsonify({'error': 'IP와 사용자명은 필수입니다.'}), 400
    try:
        import paramiko
        client = paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        client.connect(host, port=port, username=username, password=password,
                       timeout=15, look_for_keys=False, allow_agent=False)
        _, stdout, _ = client.exec_command('show running-config')
        output = stdout.read().decode('utf-8', errors='replace')
        client.close()
        return jsonify({'config': output})
    except ImportError:
        return jsonify({'error': 'paramiko 미설치: pip install paramiko'}), 500
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    try:
        ip = socket.gethostbyname(socket.gethostname())
    except Exception:
        ip = '127.0.0.1'
    print(f"\n{'='*42}")
    print(f"  Gigamon TAP 도식화 서버 기동")
    print(f"  로컬:      http://127.0.0.1:8080")
    print(f"  네트워크:  http://{ip}:8080")
    print(f"{'='*42}\n")
    app.run(host='0.0.0.0', port=8080, debug=False)
