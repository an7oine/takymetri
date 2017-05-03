@echo off

REM Muuntaa GT-, CSV- ja JOB-aineistoja MM ASCII -muotoon kooditaulukosta haetuilla T4-koodeilla
REM (c) Antti Hautaniemi 2014-2015

REM Käytetään muuttujanimien 'viivästettyä laajennusta'
@setlocal enableextensions enabledelayedexpansion

REM Hakemistot ja tiedostot
SET KOODIT=R:\KOODIT.EXC
SET TYOHAKEMISTO=C:\DATA
SET LAHDE=%~1


REM Käytetään tilapäistä kooditiedostoa ja lisätään siihen tarvittaessa uudet koodimuunnokset
SET TILAP_KOODIT=%TYOHAKEMISTO%\KOODIT.EXC
COPY %KOODIT% %TILAP_KOODIT% >NUL

REM Kysytään lähdetiedoston nimi tarvittaessa
if "%LAHDE%"=="" (
	SET /P LAHDETIEDOSTO=Anna tiedostonimi: %TYOHAKEMISTO%\
	SET LAHDE=%TYOHAKEMISTO%\!LAHDETIEDOSTO!
)

:uudestaan

REM Varmistetaan lähdetiedoston olemassaolo
if not exist "%LAHDE%" (
	echo Tiedostoa ei loydy!
	pause
	exit
)

REM Tunnistetaan lähdetiedoston formaatti tiedostotarkenteesta
for /F "tokens=*" %%F in ('dir /L/B "%LAHDE%"') do set FORMAATTI=%%F
set FORMAATTI=!FORMAATTI:~-4!
if not "!FORMAATTI!"==".xyz" if not "!FORMAATTI!"==".csv" if not "!FORMAATTI!"==".job" (
	echo Tiedosto ei ole .csv-, .xyz- tai .job-formaatissa!
	pause
	exit
)

REM Muodostetaan kohdetiedostolle nimi ja poistetaan mahdollinen vanha tiedosto
if "!FORMAATTI!"==".xyz" (
	for /F "tokens=1 delims=." %%K in ("%LAHDE%") do set KOHDE=%%K_mmascii.xyz
) else (
	for /F "tokens=1 delims=." %%K in ("%LAHDE%") do set KOHDE=%%K.xyz
)
if exist %KOHDE% DEL %KOHDE%

REM Asetetaan R=lähderivi
for /F "tokens=*" %%R in ('type %LAHDE%') do (

	REM Haetaan VANHA_KOODI, pistenumero ja koordinaatit lähderiv(e)iltä lähdeformaatin mukaisesti
	if !FORMAATTI!==.xyz (
		set ZC=
		for /F "tokens=1,2,3,4,5,6,7" %%T in ("%%R") do set PINTA=%%T&set VIIVA=%%U&set VANHA_KOODI=%%V&set NRO=%%W&set XC=%%X&set YC=%%Y&set ZC=%%Z
	)
	if !FORMAATTI!==.csv (
		set RIVI=%%R
		set RIVI=!RIVI:,,=, ,!
		set VANHA_KOODI=
		for /F "tokens=1,2,3,4 delims=," %%W in (^"!RIVI!^") do set NRO=%%W&set XC=%%X&set YC=%%Y&set ZC=%%Z
		for /F "tokens=5,6,7 delims=," %%T in (^"!RIVI!^") do set VANHA_KOODI=%%T&set PINTA=%%U&set VIIVA=%%V
		if "!ZC!"==" " set ZC=0.000
	)
	if !FORMAATTI!==.job (
		for /F "tokens=1,2 delims==" %%L in ("%%R") do (
			if %%L==4 set VANHA_KOODI=%%M
			if %%L==5 set NRO=%%M
			if %%L==90 set PINTA=%%M
			if %%L==91 set VIIVA=%%M
			if %%L==37 if not "!VANHA_KOODI!"=="" (
				for /F "tokens=1,2 delims=.," %%E in ("%%M") do set X68=%%E&set XDEC=%%F
				set /A X68 += 6800000
				set XC=!X68!.!XDEC!
			)
			if %%L==38 if not "!XC!"=="" (
				for /F "tokens=1,2 delims=.," %%E in ("%%M") do set Y244=%%E&set YDEC=%%F
				set /A Y244 += 24400000
				set YC=!Y244!.!YDEC!
				if not "!PINTA!"=="7" set ZC=0.0
			)
			if %%L==39 if not "!YC!"=="" if "!PINTA!"=="7" set ZC=%%M
		)
	)
	
	REM jos kaikki kentät (pl. pinta/viiva) on saatu, tulostetaan pisterivi
	if not "!VANHA_KOODI!"=="" if not "!NRO!"=="" if not "!XC!"=="" if not "!YC!"=="" if not "!ZC!"=="" (
	
		REM Asetetaan KOODI=muunnettu koodi
		for /F "tokens=*" %%I in ('type %TILAP_KOODIT%') do (
			for /F "tokens=1" %%J in ("%%I") do (
				if !VANHA_KOODI!==%%J for /F "tokens=2" %%K in ("%%I") do set KOODI=%%K
			)
		)
		
		REM Jos tuloskoodia ei löytynyt, kysytään käyttäjältä ja tallennetaan myöhempiä rivejä varten
		if "!KOODI!"=="" (
			set /P KOODI=Anna muunnos koodille !VANHA_KOODI! : 
			echo !VANHA_KOODI! !KOODI! >>%TILAP_KOODIT% 
		)
		
		if "!PINTA!"=="" set PINTA=7
		if "!PINTA!"==" " set PINTA=7
		if "!VIIVA!"=="" set VIIVA=0
		if "!VIIVA!"==" " set VIIVA=0

		REM Tulostetaan MM ASCII -muotoinen tulosrivi ja nollataan kentät
		set PINTA=        !PINTA!
		set VIIVA=        !VIIVA!
		set KOODI=        !KOODI!
		set NRO=        !NRO!
		set XC=              !XC!
		set YC=              !YC!
		set ZC=              !ZC!
		echo !PINTA:~-8!!VIIVA:~-8!!KOODI:~-8!!NRO:~-8!       1!XC:~-14!!YC:~-14!!ZC:~-14! >>%KOHDE%
		set PINTA=&set VIIVA=&set KOODI=&set VANHA_KOODI=&set NRO=&set XC=&set YC=&set ZC=
	)
)

REM Poistetaan lähdetiedosto
DEL %LAHDE%

REM Siirrytään seuraavaan lähdetiedostoon
SHIFT
if NOT "%~1"=="" (
	SET LAHDE=%~1
	goto uudestaan
)

REM Poistetaan väliaikainen kooditiedosto
DEL %TILAP_KOODIT%
