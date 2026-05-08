@echo off
chcp 65001 > nul
echo ============================================
echo  [2단계] VDI에서 실행하세요
echo  오프라인 패키지 설치 후 서버 기동
echo ============================================
echo.

REM wheels 폴더 존재 여부 확인
if not exist "wheels\" (
    echo [오류] wheels\ 폴더가 없습니다.
    echo   인터넷 PC에서 download_wheels.bat 을 먼저 실행하고
    echo   프로젝트 폴더 전체를 이곳으로 복사해주세요.
    pause
    exit /b 1
)

echo 패키지 설치 중 (오프라인)...
pip install --no-index --find-links=wheels -r requirements.txt

if %errorlevel% neq 0 (
    echo.
    echo [오류] 설치 실패.
    echo   Python 버전 확인: python --version
    echo   wheels 폴더 내용 확인: dir wheels\
    pause
    exit /b 1
)

echo.
echo 설치 완료! 서버 기동 중...
echo.
python server.py
pause
