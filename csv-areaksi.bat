@echo off

REM Muuntaa CSV-tiedoston AREA-muotoon
REM (c) Antti Hautaniemi 2017

REM Käytetään muuttujanimien 'viivästettyä laajennusta'
@setlocal enableextensions enabledelayedexpansion

SET LAHDE=%~1

REM Etsitään ensimmäinen vapaa tiedostonimi, alkaen 2.ARE:sta
set TIED_NRO=1
:seuraava_numero
set /A TIED_NRO += 1
SET KOHDE=%~dp1\%TIED_NRO%.are
if exist %KOHDE% goto seuraava_numero

REM Kirjoitetaan Area-tiedoston numero ensimmäiselle riville
echo 15=!TIED_NRO!>>%KOHDE%

REM Asetetaan R=lähderivi
for /F "tokens=*" %%R in ('type %LAHDE%') do (
	set RIVI=%%R,,
	set RIVI=!RIVI:,,=,0,!
	for /F "tokens=1,2,3,4 delims=," %%W in (^"!RIVI!^") do set NRO=%%W&set XC=%%X&set YC=%%Y&set ZC=%%Z
	for /F "tokens=5,6,7 delims=," %%T in (^"!RIVI!^") do set KOODI=%%T&set PINTA=%%U&set VIIVA=%%V
	
	REM Erotellaan koordinaattien kokonais- ja desimaaliosa
	for /F "tokens=1,2 delims=." %%P in ("!XC!") do set XINT=%%P&set XDEC=%%Q000
	for /F "tokens=1,2 delims=." %%P in ("!YC!") do set YINT=%%P&set YDEC=%%Q000

	REM Vähennetään 68 / 244 -alkunumerot X- ja Y-koordinaateista (tarvittaessa)
	if !XINT! GEQ 6800000 set /A XINT -= 6800000
	if !YINT! GEQ 24400000 set /A YINT -= 24400000
	if not !ZC!==0.000 if !PINTA!==0 set PINTA=7

	echo 5=!NRO!>>%KOHDE%
	echo 4=!KOODI!>>%KOHDE%
	echo 90=!PINTA!>>%KOHDE%
	echo 91=!VIIVA!>>%KOHDE%
	echo 37=!XINT!.!XDEC!>>%KOHDE%
	echo 38=!YINT!.!YDEC!>>%KOHDE%
	echo 39=!ZC!>>%KOHDE%
)