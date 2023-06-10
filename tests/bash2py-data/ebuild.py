#! /usr/bin/env python
import sys,os,subprocess
from stat import *
if (len(sys.argv) != 2  ):
    print("Please specify ebuild file and unpack, compile or all")
    exit(1)
_rc = subprocess.call(["source","/etc/ebuild.conf"])
if (('"$DISTDIR"' not in globals()) ):
    # set DISTDIR to /usr/src/distfiles if not already set
    DISTDIR="/usr/src/distfiles"
os.environ['DISTDIR'] = DISTDIR
def ebuild_unpack () :
    global ORIGDIR
    global WORKDIR
    global DISTDIR
    global A

    #make sure we're in the right directory 
    os.chdir(ORIGDIR)
    if (S_ISDIR(os.stat(WORKDIR ).st_mode) ):
        _rc = subprocess.call(["rm","-rf",WORKDIR])
    _rc = subprocess.call(["mkdir",WORKDIR])
    os.chdir(WORKDIR)
    if ( not os.path.isfile(str(DISTDIR) + "/" + str(A) ) ):
        print(str(DISTDIR) + "/" + str(A) + " does not exist.  Please download first.")
        exit(1)
    _rc = subprocess.call(["tar","xzf",str(DISTDIR) + "/" + str(A)])
    print("Unpacked " + str(DISTDIR) + "/" + str(A) + ".")

#source is now correctly unpacked
def user_compile () :
    global MAKEOPTS
    global MAKE

    #we're already in ${SRCDIR}
    if (os.path.isfile("configure" ) ):
        #run configure script if it exists
        _rc = subprocess.call(["./configure","--prefix"="/usr"])
    #run make
    _rc = subprocess.call(["make",MAKEOPTS,MAKE="make " + str(MAKEOPTS)])

def ebuild_compile () :
    global SRCDIR

    if ( not S_ISDIR(os.stat(str(SRCDIR) ).st_mode) ):
        print(str(SRCDIR) + " does not exist -- please unpack first.")
        exit(1)
    #make sure we're in the right directory  
    os.chdir(SRCDIR)
    user_compile()

os.environ['ORIGDIR'] = os.popen("pwd").read()
os.environ['WORKDIR'] = str(ORIGDIR) + "/work"
if (os.path.isfile(str(sys.argv[1]) ) ):
    _rc = subprocess.call(["source",sys.argv[1]])
else:
    print("Ebuild file " + str(sys.argv[1]) + " not found.")
    exit(1)
os.environ['SRCDIR'] = str(WORKDIR) + "/" + str(P)

if ( str(sys.argv[2]) == 'unpack'):
    ebuild_unpack()
elif ( str(sys.argv[2]) == 'compile'):
    ebuild_compile()
elif ( str(sys.argv[2]) == 'all'):
    ebuild_unpack()
    ebuild_compile()
else:
    print("Please specify unpack, compile or all as the second arg")
    exit(1)
