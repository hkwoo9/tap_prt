@echo off
chcp 65001 > nul
echo ============================================
echo  TAP 도식화 - 번들 가져오기 (VDI)
echo ============================================
echo.

cd /d "%~dp0"

REM ── full bundle 확인 ──────────────────────────
if not exist "tap_prt_full.bundle" goto CHECK_UPDATE

if exist ".git" goto ALREADY_INIT

echo [최초 설치] 전체 번들에서 클론 중...
git clone tap_prt_full.bundle . --no-local
if %errorlevel% neq 0 goto ERROR

echo.
echo 패키지 설치 중...
pip install -r requirements.txt -q
if %errorlevel% neq 0 echo [경고] 패키지 설치 실패. 수동으로 pip install -r requirements.txt 실행하세요.

del tap_prt_full.bundle

echo.
echo ============================================
echo  설치 완료! start.bat 으로 서버를 시작하세요.
echo ============================================
goto END

:ALREADY_INIT
echo [알림] 이미 설치된 저장소입니다.
echo   업데이트는 tap_prt_update.bundle 을 복사 후 실행하세요.
goto END

REM ── update bundle 확인 ────────────────────────
:CHECK_UPDATE
if not exist "tap_prt_update.bundle" goto NO_BUNDLE

if not exist ".git" goto NO_REPO

echo [업데이트] 변경분 적용 중...
git fetch tap_prt_update.bundle main:main
if %errorlevel% neq 0 goto ERROR

git checkout main
del tap_prt_update.bundle

echo.
echo ============================================
echo  업데이트 완료!
echo.
echo  최근 변경사항:
git log --oneline -5
echo.
echo  서버 재시작: start.bat
echo ============================================
goto END

:NO_REPO
echo [오류] git 저장소가 없습니다.
echo   먼저 tap_prt_full.bundle 로 최초 설치를 진행하세요.
goto END

REM ── 번들 파일 없음 ────────────────────────────
:NO_BUNDLE
echo [오류] 번들 파일이 없습니다.
echo.
echo  처음이라면  : 인터넷 PC에서 bundle_export.bat 실행
echo               tap_prt_full.bundle + bundle_import.bat 을 VDI로 복사
echo.
echo  업데이트라면: 인터넷 PC에서 bundle_export.bat 실행
echo               tap_prt_update.bundle 만 이 폴더에 복사
goto END

:ERROR
echo.
echo [오류] 처리 중 문제가 발생했습니다.
pause
exit /b 1

:END
echo.
pause
