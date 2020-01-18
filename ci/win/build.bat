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

cd "%ROOT%\modules\JUCE\extras\Projucer\Builds\VisualStudio2019"
"%MSBUILD_EXE%" Projucer.sln /p:VisualStudioVersion=16.0 /m /t:Build /p:Configuration=Release /p:Platform=x64 /p:PreferredToolArchitecture=x64 
if %errorlevel% neq 0 exit /b %errorlevel%

mkdir "%ROOT%\ci\win\bin"
copy cd "%ROOT%\modules\JUCE\extras\Projucer\Builds\VisualStudio2019\x64\Release\App\Demo.exe "%ROOT%\ci\win\bin"

-r Projucer.zip Projucer.exe
