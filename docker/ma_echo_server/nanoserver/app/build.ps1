#
# Copyright (c) 2019 Marat Abrarov (abrarov@gmail.com)
#
# Distributed under the Boost Software License, Version 1.0. (See accompanying
# file LICENSE or copy at http://www.boost.org/LICENSE_1_0.txt)
#

# Stop immediately if any error happens
$ErrorActionPreference = "Stop"

# Enable all versions of TLS
[System.Net.ServicePointManager]::SecurityProtocol = @("Tls12","Tls11","Tls","Ssl3")

& choco install git -y --no-progress --version "${env:GIT_VERSION}" --force -params "'/NoShellIntegration /NoGuiHereIntegration /NoShellHereIntegration'"
if (${LastExitCode} -ne 0) {
  throw "Failed to install Git ${env:GIT_VERSION}"
}

$cmake_archive_base_name = "cmake-${env:CMAKE_VERSION}-win64-x64"
$env:CMAKE_HOME = "${env:DEPENDENCIES_FOLDER}\${cmake_archive_base_name}"
if (!(Test-Path -Path "${env:CMAKE_HOME}")) {
  Write-Host "CMake ${env:CMAKE_VERSION} not found at ${env:CMAKE_HOME}"
  $cmake_archive_name = "${cmake_archive_base_name}.zip"
  $cmake_archive_file = "${env:DOWNLOADS_FOLDER}\${cmake_archive_name}"
  $cmake_download_url = "${env:CMAKE_URL}/v${env:CMAKE_VERSION}/${cmake_archive_name}"
  if (!(Test-Path -Path "${cmake_archive_file}")) {
    Write-Host "Going to download CMake ${env:CMAKE_VERSION} archive from ${cmake_download_url} to ${cmake_archive_file}"
    if (!(Test-Path -Path "${env:DOWNLOADS_FOLDER}")) {
      New-Item -Path "${env:DOWNLOADS_FOLDER}" -ItemType "directory" | out-null
    }
    (New-Object System.Net.WebClient).DownloadFile("${cmake_download_url}", "${cmake_archive_file}")
    Write-Host "Downloading of CMake completed successfully"
  }
  if (!(Test-Path -Path "${env:DEPENDENCIES_FOLDER}")) {
    New-Item -Path "${env:DEPENDENCIES_FOLDER}" -ItemType "directory" | out-null
  }
  Write-Host "Extracting CMake ${env:CMAKE_VERSION} from ${cmake_archive_file} to ${env:DEPENDENCIES_FOLDER}"
  & "${env:SEVEN_ZIP_HOME}\7z.exe" x "${cmake_archive_file}" -o"${env:DEPENDENCIES_FOLDER}" -aoa -y -bd | out-null
  if (${LastExitCode} -ne 0) {
    throw "Extracting CMake failed with exit code ${LastExitCode}"
  }
  Write-Host "Extracting of CMake completed successfully"
}
Write-Host "CMake ${env:CMAKE_VERSION} is located at ${env:CMAKE_HOME}"

$boost_version_suffix = "-${env:BOOST_VERSION}"
$boost_platform_suffix = "-x64"
$boost_toolchain_suffix = ""
switch (${env:MSVC_VERSION}) {
  "14.0" {
    $boost_toolchain_suffix = "-vs2015"
  }
  default {
    throw "Unsupported MSVC version for Boost: ${env:MSVC_VERSION}"
  }
}
$boost_install_folder = "${env:DEPENDENCIES_DIR}\boost${boost_version_suffix}${boost_platform_suffix}${boost_toolchain_suffix}"
if (!(Test-Path -Path "${boost_install_folder}")) {
  $boost_archive_name = "boost${boost_version_suffix}${boost_platform_suffix}${boost_toolchain_suffix}.7z"
  $boost_archive_file = "${env:DOWNLOADS_DIR}\${boost_archive_name}"
  if (!(Test-Path -Path "${boost_archive_file}")) {
    $boost_download_url = "${env:BOOST_URL}/${env:BOOST_VERSION}/${boost_archive_name}"
    if (!(Test-Path -Path "${env:DOWNLOADS_DIR}")) {
      New-Item -Path "${env:DOWNLOADS_DIR}" -ItemType "directory" | out-null
    }
    Write-Host "Going to download Boost from ${boost_download_url} to ${boost_archive_file}"
    (New-Object System.Net.WebClient).DownloadFile("${boost_download_url}", "${boost_archive_file}")
    Write-Host "Downloading of Boost completed successfully"
  }
  Write-Host "Extracting Boost from ${boost_archive_file} to ${env:DEPENDENCIES_DIR}"
  if (!(Test-Path -Path "${env:DEPENDENCIES_DIR}")) {
    New-Item -Path "${env:DEPENDENCIES_DIR}" -ItemType "directory" | out-null
  }
  & "${env:SEVEN_ZIP_HOME}\7z.exe" x "${boost_archive_file}" -o"${env:DEPENDENCIES_DIR}" -aoa -y -bd | out-null
  if (${LastExitCode} -ne 0) {
    throw "Extracting of Boost failed with exit code ${LastExitCode}"
  }
  Write-Host "Extracting of Boost completed successfully"
}
Write-Host "Boost ${env:BOOST_VERSION} is located at ${boost_install_folder}"
$boost_include_folder_version_suffix = "-${env:BOOST_VERSION}" -replace "([\d]+)\.([\d]+)(\.[\d]+)*", '$1_$2'
$env:BOOST_INCLUDE_DIR = "${boost_install_folder}\include\boost${boost_include_folder_version_suffix}"
$env:BOOST_LIBRARY_DIR = "${boost_install_folder}\lib"

$env:MSVS_INSTALL_DIR = &vswhere --% -legacy -latest -version [14.0,15.0) -property installationPath
$env:MSVC_BUILD_DIR = "${env:MSVS_INSTALL_DIR}VC"
$env:MSVC_CMD_BOOTSTRAP = "vcvarsall.bat"
$env:MSVC_CMD_BOOTSTRAP_OPTIONS = "amd64"

New-Item -Path "${env:SOURCE_DIR}" -ItemType "directory" | out-null
git clone https://github.com/mabrarov/asio_samples.git "${env:SOURCE_DIR}"
Set-Location -Path "${env:SOURCE_DIR}"
git checkout "${env:MA_REVISION}"

New-Item -Path "${env:BUILD_DIR}" -ItemType "directory" | out-null
Set-Location -Path "${env:BUILD_DIR}"

& "${PSScriptRoot}\build.bat"
if (${LastExitCode} -ne 0) {
  throw "Failed to build"
}
