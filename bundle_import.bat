@echo off
chcp 65001 > nul
echo ============================================
echo  TAP 도식화 - 번들 가져오기 (VDI)
echo ============================================
echo.

cd /d "%~dp0"

REM ── full bundle: 최초 설치 ────────────────────
if not exist "tap_prt_full.bundle" goto CHECK_UPDATE

if exist "tap_prt\" goto ALREADY_INIT

echo [최초 설치] tap_prt_full.bundle 에서 클론 중...
git clone tap_prt_full.bundle tap_prt --no-local
if %errorlevel% neq 0 goto ERROR

echo.
echo 패키지 설치 중...
cd tap_prt
pip install -r requirements.txt -q
cd ..

del tap_prt_full.bundle

echo.
echo ============================================
echo  설치 완료!
echo  tap_prt\start.bat 으로 서버를 시작하세요.
echo ============================================
goto END

:ALREADY_INIT
echo [알림] tap_prt\ 폴더가 이미 존재합니다.
echo   업데이트는 tap_prt_update.bundle 을 복사 후 실행하세요.
goto END

REM ── update bundle: 업데이트 ───────────────────
:CHECK_UPDATE
if not exist "tap_prt_update.bundle" goto NO_BUNDLE

if not exist "tap_prt\" goto NO_REPO

echo [업데이트] 변경분 적용 중...
cd tap_prt
git fetch ..\tap_prt_update.bundle main
if %errorlevel% neq 0 goto ERROR

git reset --hard FETCH_HEAD
cd ..
del tap_prt_update.bundle

echo.
echo ============================================
echo  업데이트 완료!
echo.
echo  최근 변경사항:
cd tap_prt
git log --oneline -5
cd ..
echo.
echo  서버 재시작: tap_prt\start.bat
echo ============================================
goto END

:NO_REPO
echo [오류] tap_prt\ 폴더가 없습니다.
echo   먼저 tap_prt_full.bundle 로 최초 설치를 진행하세요.
goto END

REM ── 번들 없음 ─────────────────────────────────
:NO_BUNDLE
echo [오류] 번들 파일이 없습니다.
echo.
echo  이 bat 파일과 같은 폴더에 아래 파일이 있어야 합니다:
echo.
echo  처음이라면  : tap_prt_full.bundle
echo  업데이트라면: tap_prt_update.bundle
goto END

:ERROR
echo.
echo [오류] 처리 중 문제가 발생했습니다.
pause
exit /b 1

:END
echo.
pause
