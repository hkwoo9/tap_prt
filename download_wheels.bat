@echo off
chcp 65001 > nul
echo ============================================
echo  [1단계] 인터넷 PC에서 실행하세요
echo  패키지를 wheels\ 폴더에 다운로드합니다
echo ============================================
echo.

pip download -r requirements.txt -d wheels

if %errorlevel% neq 0 (
    echo.
    echo [오류] 다운로드 실패. pip 및 인터넷 연결 확인 필요.
    pause
    exit /b 1
)

echo.
echo ============================================
echo  완료! 이제 프로젝트 폴더 전체를 VDI로 복사하세요.
echo  복사 후 VDI에서 install_and_start.bat 실행
echo ============================================
pause
