#! /usr/bin/env python
import sys,subprocess
from stat import *
# Script to test file on raid or jbod storage device
yes="y"
devices=""

testscript="RAID/JBOD SCSI file test script - rev A"
print(testscript)
print("WOULD YOU LIKE TO INSTALL NAC DRIVER (enter y for yes n for no) THEN ENTER")
insdriver = raw_input()
if (insdriver == yes  ):
    _rc = subprocess.call(["./install"])
# ****** GATHER INFORMATION FOR TEST ******
print("WOULD YOU LIKE TO DO FILE TESTING (enter y for yes n for no) THEN ENTER")
filetest = raw_input()
if (filetest == yes  ):
    print("SPECIFY FILE SIZE TO TEST (100 = 100Mbyte) THEN ENTER")
    filesize = raw_input()
    print("files size to create is " + str(filesize) + " Mbyte")
    print("WOULD YOU LIKE TO COPY A FILE FROM HOST TO STORAGE (enter y for yes n for no) THEN ENTER")
    filecopy = raw_input()
    print("WOULD YOU LIKE TO DELETE THE FILE FROM STORAGE WHEN TESTING IS COMPLETE (enter y for yes n for no) THEN ENTER")
    filedelete = raw_input()
    # ****** GET STORAGE DEVICES TO WRITE FILE ******
    print("ENTER STORAGE DEVICE NAMES TO RUN THE FILE TEST ON ONE LINE (ex:sda1 sdb5 sdd6) THEN ENTER")
    devices = raw_input()
    devicecount=len(sys.argv)
    index=0
    while ("index" < "devicecount" ):
        print(devices[index])
        "index" = index +1"
    # **** clear out test1.txt file ****
    _rc = subprocess.call(["cp","zero.txt","test2.txt"])
    # **** create file of size filesize use testbase.txt to generate
    _rc = subprocess.call(["test1.txt"])
    print("creating test file... this takes a couple of minutes")
    while (filesize > 0 ):
        _rc = subprocess.call(["cat"])
        _rc = subprocess.call("testbase2.txt",shell=True,stdout=file('/home/root/DDC/latest/FC7901xS1/ddk/applications/test2.txt','ab'))
        
        filesize=(\"filesize-1\")
    print("test file test2.txt is created")
    # **** copy file to RAID or JBOD?  ********
    if (filecopy == yes  ):
        # **** mount storage copy file then sync and compare files
        index=0
        while ("index" < "devicecount" ):
            print("mounting " + str(devices[index]))
            print("mounting
            " + str(devices[index]))
            _rc = subprocess.call(["mount","-t","ext2","-v","/dev/" + str(devices[index])])
            _rc = subprocess.call("/new_root",shell=True,stdout=file('/home/root/DDC/latest/FC7901xS1/ddk/applications/filetest.txt','ab'))
            
            print("copying test file to " + str(devices[index]))
            _rc = subprocess.call(["cp","test2.txt","/new_root"])
            print("sync disks")
            _rc = subprocess.call(["sync"])
            print("comparing files now (no output if files are the same)")
            _rc = subprocess.call(["cmp","-l","test2.txt","/new_root/test2.txt"])
            print("COMPARE COMPLETE for " + str(devices[index]))
            print("unmount " + str(devices[index]))
            _rc = subprocess.call(["umount","-v","/new_root"])
            "index" = index +" 1
    print("***** FILE TEST COMPLETE *****")
    # **** delete file from RAID or JBOD? *******
    if (filedelete == yes  ):
        index=0
        while ("index" < "devicecount" ):
            print("mounting " + str(devices[index]))
            print("mounting
            " + str(devices[index]))
            _rc = subprocess.call(["mount","-t","ext2","-v","/dev/" + str(devices[index])])
            _rc = subprocess.call("/new_root",shell=True,stdout=file('/home/root/DDC/latest/FC7901xS1/ddk/applications/filetest.txt','ab'))
            
            print("deleting file test2.txt from " + str(devices[index]))
            _rc = subprocess.call(["rm","/new_root/test2.txt"])
            print("test2.txt is now removed from " + str(devices[index]))
            print("unmount " + str(devices[index]))
            _rc = subprocess.call(["umount","-v","/new_root"])
            "index" = index +" 1
