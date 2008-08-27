if "%1"=="" goto ei_param

X:
cd \xpower\Local\takymetri
copy %1 .
echo "%1" | c:\code\sed "s#[^\\]*\\##g" | starttakym.bat
if errorlevel 1 pause
exit

:ei_param
echo (ajetaan: TAKY-SIIRTO c:\...\tiedosto.xyz)
pause