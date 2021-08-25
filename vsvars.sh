#! /bin/bash
#
# vsvars.sh: sets up MS Visual C++ environment, based on VSVARS32.BAT.
#
# usage:
# source ~/bin/vsvars.sh
#
#........................................................................
# Notes:
#
# $ pwd
# /c/Program Files/Microsoft Visual Studio .NET 2003
#
# 
# $ find -iname include
# ./Vc7/atlmfc/include
# ./Vc7/include
# ./Vc7/PlatformSDK/Include
# ./Visual Studio SDKs/DIA SDK/include
# 
# $ find -iname lib
# ./SDK/v1.1/Lib
# ./Vc7/atlmfc/lib
# ./Vc7/lib
# ./Vc7/PlatformSDK/Lib
# ./Vc7/PlatformSDK/Misc/Icmp/Lib
# ./Visual Studio SDKs/DIA SDK/lib
# 
#........................................................................
# TODO: have -verbose option (default from command-line)
#

# setup-VS-env(): Sets up MSVS environment assuming VS_base_dir set to base
# directory (e.g., c:\Program Files\Microsoft Visual Studio 8) and that
# VsOsDir set to WIN95 or WINNT.
#
function setup-VS-env {
    VSCommonDir=`cygpath -d "$VS_base_dir\Common7"`
    ## MSDevDir=`cygpath -d "$VSCommonDir\msdev98"`
    ## TODO: find what directory to use for old msdev98 dir (or if no longer needed)
    MSDevDir=`cygpath -d "$VSCommonDir\IDE"`
    export VSINSTALLDIR="$MSDevDir"
    MSVSDir=`cygpath -d "$VS_base_dir\VC7"`
    
    # For CygWin paths must be in Unix format
    # NOTE: VS prepended to path so that link doesn't resolve to Unix command.
    Unix_VSCommonDir=`cygpath -u "$VSCommonDir"`
    Unix_MSDevDir=`cygpath -u "$MSDevDir"`
    Unix_MSVSDir=`cygpath -u "$MSVSDir"`
    ## TODO: echo "old PATH: $PATH"
    ## export PATH="$Unix_MSDevDir/BIN:$Unix_MSVSDir/BIN:$Unix_VSCommonDir/TOOLS/$VsOsDir:$Unix_VSCommonDir/TOOLS:$PATH"
    export PATH="$Unix_MSDevDir:$Unix_MSVSDir/BIN:$Unix_VSCommonDir/TOOLS/$VsOsDir:$Unix_VSCommonDir/TOOLS:$PATH"
    ## TODO: echo "new PATH: $PATH"
    
    # For VS++, paths must be in DOS formatt
    export INCLUDE="$MSVSDir\\INCLUDE;$MSVSDir\\PlatformSDK\\INCLUDE;$MSVSDir\\ATLMFC\INCLUDE;$INCLUDE"
    export LIB="$MSVSDir\\LIB;$MSVSDir\\PlatformSDK\\LIB;$MSVSDir\\ATLMFC\\LIB;$LIB"
    ## TODO: echo "INCLUDE: $INCLUDE"
    ## TODO: echo "LIB: $LIB"
}

#------------------------------------------------------------------------

# Determine base directories
VsOsDir=WIN95
if [ "$OS" = "Windows_NT" ]; then VsOsDir=WINNT; fi
#
VS_base_dir="c:\Program Files\Microsoft Visual Studio .NET 2003"
export VCINSTALLDIR="$VS_base_dir"
if [ ! -d "$VS_base_dir" ]; then
    echo "VS base directory not found: $VS_base_dir"
else 
    setup-VS-env;
fi

