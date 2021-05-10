#! /bin/bash
#
# vcvars.sh: sets up MS Visual C++ environment, based on VCVARS32.BAT.
#
# usage:
# source vcvars.sh
#
# TODO: have -verbose option (default from command-line)
#

# setup-VC-env(): Sets up MSVC environment assuming VC_base_dir set to base
# directory (e.g., c:\Program Files\Microsoft Visual Studio) and that
# VcOsDir set to WIN95 or WINNT.
#
function setup-VC-env {
    VSCommonDir=`cygpath -d "$VC_base_dir\Common"`
    MSDevDir=`cygpath -d "$VSCommonDir\msdev98"`
    MSVCDir=`cygpath -d "$VC_base_dir\VC98"`
    
    # For CygWin paths must be in Unix format
    # NOTE: VC prepended to path so that link doesn't resolve to Unix command.
    Unix_VSCommonDir=`cygpath -u "$VSCommonDir"`
    Unix_MSDevDir=`cygpath -u "$MSDevDir"`
    Unix_MSVCDir=`cygpath -u "$MSVCDir"`
    ## TODO: echo "old PATH: $PATH"
    export PATH="$Unix_MSDevDir/BIN:$Unix_MSVCDir/BIN:$Unix_VSCommonDir/TOOLS/$VcOsDir:$Unix_VSCommonDir/TOOLS:$PATH"
    ## TODO: echo "new PATH: $PATH"
    
    # For VC++, paths must be in DOS formatt
    export INCLUDE="$MSVCDir\\ATL\INCLUDE;$MSVCDir\\INCLUDE;$MSVCDir\\MFC\INCLUDE;$INCLUDE"
    export LIB="$MSVCDir\\LIB;$MSVCDir\\MFC\\LIB;$LIB"
    ## TODO: echo "INCLUDE: $INCLUDE"
    ## TODO: echo "LIB: $LIB"
    
}

#------------------------------------------------------------------------

# Determine base directories
VcOsDir=WIN95
if [ "$OS" = "Windows_NT" ]; then VcOsDir=WINNT; fi
#
## VSCommonDir='C:\PROGRA~1\MIAF9D~1\Common'
## MSDevDir='C:\PROGRA~1\MIAF9D~1\Common\msdev98'
## MSVCDir='C:\PROGRA~1\MIAF9D~1\VC98'
VC_base_dir="c:\Program Files\Microsoft Visual Studio"
if [ ! -d "$VC_base_dir" ]; then
    echo "VC base directory not found: $VC_base_dir"
else 
    setup-VC-env;
fi

