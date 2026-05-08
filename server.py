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
    res = send_from_directory(BASE, 'index.html')
    res.headers['Cache-Control'] = 'no-store'
    return res

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
        import paramiko, time, re

        def recv_until(shell, pattern, timeout=15):
            """프롬프트 패턴이 나올 때까지 수신"""
            buf = ''
            deadline = time.time() + timeout
            while time.time() < deadline:
                if shell.recv_ready():
                    buf += shell.recv(65535).decode('utf-8', errors='replace')
                    if re.search(pattern, buf):
                        return buf
                else:
                    time.sleep(0.1)
            return buf

        client = paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        client.connect(host, port=port, username=username, password=password,
                       timeout=15, look_for_keys=False, allow_agent=False)

        shell = client.invoke_shell(width=512, height=5000)

        # 로그인 후 > 또는 # 프롬프트 대기
        recv_until(shell, r'[>#]')

        # user EXEC(>) 이면 enable 진입
        shell.send('en\n')
        recv_until(shell, r'#')          # # 프롬프트 올 때까지 대기

        shell.send('terminal length 0\n')
        recv_until(shell, r'#')

        shell.send('show running-config\n')

        # config 수신 — 마지막 줄에 # 프롬프트 다시 나올 때까지
        buf = ''
        deadline = time.time() + 30
        while time.time() < deadline:
            if shell.recv_ready():
                chunk = shell.recv(65535).decode('utf-8', errors='replace')
                buf += chunk
                if re.search(r'--[Mm]ore--', chunk):
                    shell.send(' ')
                    time.sleep(0.1)
                # show running-config 결과가 어느 정도 쌓인 뒤 # 프롬프트 확인
                elif len(buf) > 200 and re.search(r'#\s*$', buf.rstrip()):
                    break
            else:
                time.sleep(0.1)

        client.close()

        clean = re.sub(r'\x1b\[[0-9;]*[A-Za-z]', '', buf)
        clean = re.sub(r'--[Mm]ore--[^\r\n]*', '', clean)
        clean = clean.replace('\r\n', '\n').replace('\r', '\n')

        return jsonify({'config': clean})
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
