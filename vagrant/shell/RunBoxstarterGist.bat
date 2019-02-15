copy "%systemdrive%\vagrant\shell\BoxStarterGist.txt" "%temp%\BoxStarterGist.txt"

@powershell -NoProfile -ExecutionPolicy Bypass -Command "Install-BoxStarterPackage -PackageName %temp%\\BoxstarterGist.txt" 