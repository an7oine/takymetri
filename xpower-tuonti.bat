@echo off

REM Muuntaa Xpowerista tuotettuja Excel-rivejä AREA-muotoon
REM (c) Antti Hautaniemi 2015

REM Käytetään muuttujanimien 'viivästettyä laajennusta'
@setlocal enableextensions enabledelayedexpansion

SET TYOHAKEMISTO=C:\DATA

SET SKJ_LAJIT=X:\xpower\local\takymetri\skjlajit.txt
SET KOODIT=R:\KOODIT.EXC
SET VIIVAMAISET_SARAKKEET=31

REM Kysytään käyttäjältä, tehdäänkö .CSV- vai .ARE-tiedosto
CHOICE /C AC /N /M "Kirjoitetaanko (A)rea- vai (C)SV-muotoon? "
if ERRORLEVEL 1 set FORMAATTI=are
if ERRORLEVEL 2 set FORMAATTI=csv

REM Aloitetaan AREA-tiedostot kakkosesta, CSV-tiedostot ykkösestä
if %FORMAATTI%==are set TIED_NRO=1

REM Etsitään seuraava vapaa tiedostonimi
:seuraava_numero
set /A TIED_NRO += 1
SET KOHDE=%TYOHAKEMISTO%\%TIED_NRO%.%FORMAATTI%
if exist %KOHDE% goto seuraava_numero

echo.
echo.Luodaan tiedosto %KOHDE% :
echo.liita Excel-riveja, lopeta nappailemalla Control-Z ja Enter
echo.

REM Kirjoitetaan Area-tiedoston nimi ensimmäiselle riville
if %FORMAATTI%==are (
	echo 15=!TIED_NRO!>>%KOHDE%
)

REM Luetaan kentät vakiosyötteen riveiltä, suodatetaan otsikkorivit pois
REM A=SKJ-laji, B,C,D =alkupisteen koordinaatit, E,F,G =loppupisteen koordinaatit, H=viivamainen?
for /F "tokens=3,6-8,9-11,%VIIVAMAISET_SARAKKEET% delims=	" %%A in ('type con') do if NOT "%%A"=="Laji" (

	REM Numeroidaan pisteet kasvavaan järjestykseen
	set /A NRO += 1
	
	REM Etsitään SKJ-lajitunnusta (kenttä 3) vastaava pistekoodi
	set SKJ_LAJI=%%A
	for /F "tokens=1" %%K in ('findstr /E %%A %SKJ_LAJIT%') do (
		for /F "tokens=1" %%J in ('findstr /E %%K %KOODIT%') do (
			if "!KOODI!"=="" set KOODI=%%J
		)
	)
	REM Asetetaan tuntemattomille SKJ-pisteille koodiksi 99, KL-alkioille 106 ja Z SKJ -alkioille 10
	if "!KOODI!"=="" (
		if "%%H"=="" (set KOODI=99) else (
			if !SKJ_LAJI! GEQ 11200 (set KOODI=106) else (set KOODI=10)
		)
	)
	
	REM Erotellaan koordinaattien kokonais- ja desimaaliosa
	for /F "tokens=1,2 delims=.," %%P in ("%%B") do set XINT=%%P&set XDEC=%%Q000
	for /F "tokens=1,2 delims=.," %%P in ("%%C") do set YINT=%%P&set YDEC=%%Q000
	for /F "tokens=1,2 delims=.," %%P in ("%%D") do set ZINT=%%P&set ZDEC=%%Q000
	if "!XDEC!"=="" set XDEC=000
	if "!YDEC!"=="" set YDEC=000
	if "!ZDEC!"=="" set ZDEC=000

	REM Area: vähennetään 68e5 ja 244e5 X- ja Y-koordinaateista, tulostetaan GDM-kentät
	if %FORMAATTI%==are (
		set /A XINT -= 6800000
		set /A YINT -= 24400000
		echo 5=!NRO!>>%KOHDE%
		echo 4=!KOODI!>>%KOHDE%
		echo 37=!XINT!.!XDEC:~0,3!>>%KOHDE%
		echo 38=!YINT!.!YDEC:~0,3!>>%KOHDE%
		echo 39=!ZINT!.!ZDEC:~0,3!>>%KOHDE%
	)
	REM CSV: tulostetaan pilkulla erotetut kentät
	if %FORMAATTI%==csv (
		echo !NRO!,!XINT!.!XDEC:~0,3!,!YINT!.!YDEC:~0,3!,!ZINT!.!ZDEC:~0,3!,!KOODI!,,>>%KOHDE%
	)
	
	REM Tutkitaan, onko kohde viivamainen ja tulostetaan tarvittaessa uusi piste
	if NOT "%%H"=="" (
	
		REM Kasvatetaan pistenumeroa
		set /A NRO += 1
		
		REM Erotellaan loppupistekoordinaattien kokonais- ja desimaaliosa
		for /F "tokens=1,2 delims=.," %%P in ("%%E") do set XINT=%%P&set XDEC=%%Q000
		for /F "tokens=1,2 delims=.," %%P in ("%%F") do set YINT=%%P&set YDEC=%%Q000
		for /F "tokens=1,2 delims=.," %%P in ("%%G") do set ZINT=%%P&set ZDEC=%%Q000
		if "!XDEC!"=="" set XDEC=000
		if "!YDEC!"=="" set YDEC=000
		if "!ZDEC!"=="" set ZDEC=000

		REM Area: vähennetään 68e5 ja 244e5 X- ja Y-koordinaateista, tulostetaan GDM-kentät
		if %FORMAATTI%==are (
			set /A XINT -= 6800000
			set /A YINT -= 24400000
			echo 5=!NRO!>>%KOHDE%
			echo 4=!KOODI!>>%KOHDE%
			echo 37=!XINT!.!XDEC:~0,3!>>%KOHDE%
			echo 38=!YINT!.!YDEC:~0,3!>>%KOHDE%
			echo 39=!ZINT!.!ZDEC:~0,3!>>%KOHDE%
		)
		REM CSV: tulostetaan pilkulla erotetut kentät
		if %FORMAATTI%==csv (
			echo !NRO!,!XINT!.!XDEC:~0,3!,!YINT!.!YDEC:~0,3!,!ZINT!.!ZDEC:~0,3!,!KOODI!,,>>%KOHDE%
		)
	)
	set KOODI=
)

ECHO Tulostettu !NRO! pistetta tiedostoon %KOHDE%
PAUSE