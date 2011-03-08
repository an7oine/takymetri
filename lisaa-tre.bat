@echo off
for %%f in (*) do echo %%f | c:\code\sed "s#[^ ]*#move & &_tre#; s#.xyz_tre#_tre.xyz#"
