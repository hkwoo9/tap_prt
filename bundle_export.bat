@echo off
chcp 65001 > nul
echo ============================================
echo  TAP 도식화 - 번들 내보내기 (인터넷 PC)
echo ============================================
echo.

cd /d "%~dp0"

echo [1/3] 최신 변경사항 가져오는 중...
git pull origin main
if %errorlevel% neq 0 goto ERROR

echo.
echo [2/3] 번들 생성 중...

if not exist "last_bundle_commit.txt" goto FULL_BUNDLE

REM ── 업데이트 번들 ─────────────────────────────
set /p LAST_COMMIT=<last_bundle_commit.txt
echo     기준 커밋: %LAST_COMMIT%

git bundle create tap_prt_update.bundle %LAST_COMMIT%..main
if %errorlevel% neq 0 goto NO_CHANGE

git rev-parse HEAD > last_bundle_commit.txt

echo.
echo [3/3] 완료!
echo ============================================
echo  생성된 파일: tap_prt_update.bundle
echo.
echo  이 파일을 VDI의 bundle_import.bat 과 같은 폴더에 복사 후
echo  bundle_import.bat 실행하세요.
echo ============================================
goto SHOW_LOG

REM ── 전체 번들 (최초) ──────────────────────────
:FULL_BUNDLE
echo     최초 실행 - 전체 번들 생성

git bundle create tap_prt_full.bundle --all
if %errorlevel% neq 0 goto ERROR

git rev-parse HEAD > last_bundle_commit.txt

echo.
echo [3/3] 완료!
echo ============================================
echo  생성된 파일: tap_prt_full.bundle
echo.
echo  이 파일 + bundle_import.bat 을 VDI로 복사 후
echo  bundle_import.bat 실행하세요.
echo ============================================
goto SHOW_LOG

:NO_CHANGE
echo.
echo [알림] 변경사항이 없어 번들을 생성하지 않았습니다.
goto END

:ERROR
echo.
echo [오류] 처리 중 문제가 발생했습니다.
pause
exit /b 1

:SHOW_LOG
echo.
echo 현재 커밋:
git log --oneline -1

:END
echo.
pause
