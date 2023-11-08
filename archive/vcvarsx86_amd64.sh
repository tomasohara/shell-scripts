# vcvarsx86_amd64.sh: Settings based on vcvarsx86_amd64.bat
#
# usage:
# source ~/bin/vcvarsx86_amd64.sh
#

# Following are just for MSVC (thus backslahes in paths)
export DevEnvDir='C:\Program Files (x86)\Microsoft Visual Studio 9.0\Common7\IDE'
export Framework35Version='v3.5'
export FrameworkDir='C:\Windows\Microsoft.NET\Framework'
export FrameworkVersion='v2.0.50727'
export VCINSTALLDIR='C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC'
export VSINSTALLDIR='C:\Program Files (x86)\Microsoft Visual Studio 9.0'
export WindowsSdkDir='C:\Program Files\\Microsoft SDKs\Windows\v6.0A'
#
export LIB='C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\ATLMFC\LIB\amd64;C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\LIB\amd64;C:\Program Files\\Microsoft SDKs\Windows\v6.0A\lib\x64;'
export LIBPATH='C:\Windows\Microsoft.NET\Framework64\v3.5;C:\Windows\Microsoft.NET\Framework64\v2.0.50727;C:\Windows\Microsoft.NET\Framework\v3.5;C:\Windows\Microsoft.NET\Framework\v2.0.50727;C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\ATLMFC\LIB\amd64;C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\LIB\amd64;'
export INCLUDE='C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\ATLMFC\INCLUDE;C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\INCLUDE;C:\Program Files\\Microsoft SDKs\Windows\v6.0A\include;'

# Following is for cygwin (this forward slashes in path)
# TODO: determine Cygwin prefix via cygpath
export PATH="/C/Program Files (x86)/Microsoft Visual Studio 9.0/Common7/IDE:/C/Program Files (x86)/Microsoft Visual Studio 9.0/VC/BIN/x86_amd64:/C/Program Files (x86)/Microsoft Visual Studio 9.0/VC/BIN:/C/Program Files (x86)/Microsoft Visual Studio 9.0/Common7/Tools:/C/Windows/Microsoft.NET/Framework/v3.5:/C/Windows/Microsoft.NET/Framework/v2.0.50727:/C/Program Files (x86)/Microsoft Visual Studio 9.0/VC/VCPackages:/C/Program Files//Microsoft SDKs/Windows/v6.0A/bin:$PATH"
