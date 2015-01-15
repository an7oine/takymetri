@echo off

SET TRIMBLE=C:\
SET MUUTA_KOODIT=R:\trimble-mmascii.bat
SET ARKISTO=R:\sähkö2015

for %%F in C:\*.csv do (
	for /F "delims=\" %%N in ("%%F") do set NIMI=%%N
	
	:uudestaan
	set /P TULOS=Anna nimi työlle !NIMI!: 
	if "%TULOS%"=="" goto uudestaan
	
	call "%MUUTA_KOODIT%" "%%F" "C:\DATA\%TULOS%.xyz"

	X:
	cd \xpower\Local\takymetri
	copy "C:\DATA\%TULOS%.xyz" .
	echo "%TULOS%.xyz" | starttakym.bat
	if errorlevel 1 pause
	
	MOVE "C:\DATA\%TULOS%.xyz" "%ARKISTO%\"
)