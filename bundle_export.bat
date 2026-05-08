@echo off
chcp 65001 > nul
echo ============================================
echo  TAP 도식화 - 번들 내보내기 (인터넷 PC)
echo ============================================
echo.

cd /d "%~dp0"

REM 최신 내용 가져오기
echo [1/3] 최신 변경사항 가져오는 중...
git pull origin main
if %errorlevel% neq 0 (
    echo [오류] git pull 실패. 인터넷 연결 및 git 설정 확인
    pause & exit /b 1
)

echo.
echo [2/3] 번들 생성 중...

REM 이전 번들 기준 커밋이 있으면 업데이트 번들, 없으면 전체 번들
if exist "last_bundle_commit.txt" (
    set /p LAST_COMMIT=<last_bundle_commit.txt
    echo     기준 커밋: %LAST_COMMIT%

    git bundle create tap_prt_update.bundle %LAST_COMMIT%..HEAD 2>nul
    if %errorlevel% neq 0 (
        echo [알림] 변경사항이 없거나 번들 생성 실패
        pause & exit /b 0
    )

    echo.
    echo [3/3] 완료!
    echo ============================================
    echo  생성된 파일: tap_prt_update.bundle
    echo.
    echo  이 파일만 VDI의 tap_prt\ 폴더에 복사 후
    echo  bundle_import.bat 실행하세요.
    echo ============================================
) else (
    echo     최초 실행 - 전체 번들 생성

    git bundle create tap_prt_full.bundle --all
    if %errorlevel% neq 0 (
        echo [오류] 번들 생성 실패
        pause & exit /b 1
    )

    echo.
    echo [3/3] 완료!
    echo ============================================
    echo  생성된 파일: tap_prt_full.bundle
    echo.
    echo  이 파일 + bundle_import.bat 을 VDI로 복사 후
    echo  bundle_import.bat 실행하세요.
    echo ============================================
)

REM 현재 커밋 해시 저장 (다음 번 업데이트 기준점)
git rev-parse HEAD > last_bundle_commit.txt

echo.
echo 현재 커밋:
git log --oneline -1
echo.
pause
