# Script for fixing CygWin mount tables
pushd f:\\
cd cygwin
cd bin
./mount --force F:\\CygWin /
./mount --force F:\\CygWin\\bin /usr/bin
./mount --force F:\\CygWin\\lib /usr/lib
./mount --force F:\\CygWin\\bin /bin
./mount
popd
