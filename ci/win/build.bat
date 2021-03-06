setlocal enabledelayedexpansion

set VS_WHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere
echo %VS_WHERE%

for /f "usebackq tokens=*" %%i in (`"%VS_WHERE%" -latest -requires Microsoft.Component.MSBuild -find MSBuild\**\Bin\MSBuild.exe`) do (
  set MSBUILD_EXE=%%i
)
echo %MSBUILD_EXE%

echo on
cd "%~dp0..\..%"
set ROOT=%cd%

cd "%ROOT%/modules/JUCE"
for /f "usebackq tokens=*" %%i in (`git rev-parse HEAD`) do (
  set HASH=%%i
)

echo Hash: %HASH%

cd "%ROOT%\modules\JUCE\extras\Projucer\Builds\VisualStudio2019"
"%MSBUILD_EXE%" Projucer.sln /p:VisualStudioVersion=16.0 /m /t:Build /p:Configuration=Release /p:Platform=x64 /p:PreferredToolArchitecture=x64 
if %errorlevel% neq 0 exit /b %errorlevel%

mkdir "%ROOT%\ci\win\bin"
copy "%ROOT%\modules\JUCE\extras\Projucer\Builds\VisualStudio2019\x64\Release\App\Projucer.exe" "%ROOT%\ci\win\bin"

cd "%ROOT%\ci\win\bin"
"%ROOT%\bin\zip.exe" -r Projucer.zip Projucer.exe

dir
curl -F "files=@%ROOT%\ci\win\bin\Projucer.zip" "https://projucer.rabien.com/set_projucer.php?os=win&key=%APIKEY%&hash=%HASH%"