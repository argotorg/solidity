$ErrorActionPreference = "Stop"

# Initialize Visual Studio environment
$vcvarsall = "C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build\vcvarsall.bat"
if (Test-Path $vcvarsall) {
    cmd.exe /c "`"$vcvarsall`" amd64 && set" |
    ForEach-Object {
        if ($_ -match "=") {
            $v = $_.split("=", 2); set-item -force -path "ENV:\$($v[0])" -value "$($v[1])"
        }
    }
} else {
    Write-Host "Warning: vcvarsall.bat not found at $vcvarsall. Assuming compilers are in the PATH."
}

cd "$PSScriptRoot\.."

if ("$Env:FORCE_RELEASE" -Or "$Env:CIRCLE_TAG") {
	New-Item prerelease.txt -type file
	Write-Host "Building release version."
}
else {
	# Use last commit date rather than build date to avoid ending up with builds for
	# different platforms having different version strings (and therefore producing different bytecode)
	# if the CI is triggered just before midnight.
	$last_commit_timestamp = git log -1 --date=unix --format=%cd HEAD
	$last_commit_date = (Get-Date -Date "1970-01-01 00:00:00Z").toUniversalTime().addSeconds($last_commit_timestamp).ToString("yyyy.M.d")
	-join("ci.", $last_commit_date) | out-file -encoding ascii prerelease.txt
}

mkdir build
cd build
$boost_dir=(Resolve-Path $PSScriptRoot\..\deps\boost\lib\cmake\Boost-*)

# Configure CMake with sccache if available
$sccachePath = Get-Command sccache -ErrorAction SilentlyContinue
if ($sccachePath) {
    Write-Host "Configuring build to use sccache with Ninja generator"
    # Use Ninja generator which supports compiler launchers
    $cmakeArgs = @(
        "-G", "Ninja",
        "-DBoost_DIR=$boost_dir\",
        "-DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded",
        "-DCMAKE_INSTALL_PREFIX=$PSScriptRoot\..\upload",
        "-DCMAKE_CXX_COMPILER_LAUNCHER=sccache",
        "-DCMAKE_C_COMPILER_LAUNCHER=sccache"
    )
} else {
    Write-Host "sccache not found, using Visual Studio generator without cache"
    $cmakeArgs = @(
        "-G", "Visual Studio 16 2019",
        "-DBoost_DIR=$boost_dir\",
        "-DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded",
        "-DCMAKE_INSTALL_PREFIX=$PSScriptRoot\..\upload"
    )
}

..\deps\cmake\bin\cmake @cmakeArgs ..
if ( -not $? ) { throw "CMake configure failed." }
..\deps\cmake\bin\cmake --build . --config Release -j 10
if ( -not $? ) { throw "Build failed." }
..\deps\cmake\bin\cmake --build . -j 10 --target install --config Release
if ( -not $? ) { throw "Install target failed." }
