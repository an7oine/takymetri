@echo off

if NOT "%~1"=="" (
	cd /D X:\xpower\Local\takymetri
	copy %1 .
	echo "%~nx1" | starttakym.bat
	if errorlevel 1 pause
)