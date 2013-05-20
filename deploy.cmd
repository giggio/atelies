@echo off

:: ----------------------
:: KUDU Deployment Script
:: ----------------------

:: Prerequisites
:: -------------

:: Verify node.js installed
where node 2>nul >nul
IF %ERRORLEVEL% NEQ 0 (
  echo Missing node.js executable, please install node.js, if already installed make sure it can be reached from current environment.
  goto error
)

:: Setup
:: -----

SET NODE_VERSION=0.8.2
SET PATH=%programfiles(x86)%\nodejs\%NODE_VERSION%\;%PATH%
echo node version
call node -v
setlocal enabledelayedexpansion

SET ARTIFACTS=%~dp0%artifacts

SET DEPLOYMENT_SOURCE=%~dp0%
:: IF NOT DEFINED DEPLOYMENT_SOURCE (
::  SET DEPLOYMENT_SOURCE=%~dp0%
::)

IF NOT DEFINED DEPLOYMENT_TARGET (
  SET DEPLOYMENT_TARGET=%ARTIFACTS%\wwwroot
)

IF NOT DEFINED NEXT_MANIFEST_PATH (
  SET NEXT_MANIFEST_PATH=%ARTIFACTS%\manifest

  IF NOT DEFINED PREVIOUS_MANIFEST_PATH (
    SET PREVIOUS_MANIFEST_PATH=%ARTIFACTS%\manifest
  )
)

IF NOT DEFINED KUDU_SYNC_COMMAND (
  :: Install kudu sync
  echo Installing Kudu Sync
  call npm install kudusync -g --silent
  IF !ERRORLEVEL! NEQ 0 goto error

  :: Locally just running "kuduSync" would also work
  SET KUDU_SYNC_COMMAND=node "%appdata%\npm\node_modules\kuduSync\bin\kuduSync"
)

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Deployment
:: ----------

echo Handling node.js deployment.

:: 1. KuduSync
echo Kudu Sync from "%DEPLOYMENT_SOURCE%" to "%DEPLOYMENT_TARGET%"
call %KUDU_SYNC_COMMAND% -v 50 -f "%DEPLOYMENT_SOURCE%" -t "%DEPLOYMENT_TARGET%" -n "%NEXT_MANIFEST_PATH%" -p "%PREVIOUS_MANIFEST_PATH%" -i ".git;.hg;.deployment;deploy.cmd" 2>nul
IF !ERRORLEVEL! NEQ 0 goto error

:: 2. Install npm packages
IF EXIST "%DEPLOYMENT_TARGET%\package.json" (
  pushd %DEPLOYMENT_TARGET%
  echo Installing npm packages
  call npm install --production
  call npm install -g grunt-cli
  call npm install -g bower
  IF !ERRORLEVEL! NEQ 0 goto error
  echo Npm ran successfully.
  popd
)

echo Installing Bower components

:: 3. Baking cake
pushd %DEPLOYMENT_TARGET%
:: bower does not yet run on windows...
::call bower install
IF !ERRORLEVEL! NEQ 0 goto error
echo Bower ran successfully!
dir public\javascripts\lib
popd

echo Compile everything

:: 4. Compiling
pushd %DEPLOYMENT_TARGET%
call grunt compile
IF !ERRORLEVEL! NEQ 0 goto error
echo Compiled!
dir
dir routes
popd

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

goto end

:error
echo An error has occurred during web site deployment.
exit /b 1

:end
echo Finished successfully.
