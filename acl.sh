#!/bin/sh
#
# acl.sh: runs Allegro Common Lisp with LD_ASSUME_KERNEL set to 2.4.1
#
# NOTE:
# Use alisp, which is the normal lisp executable. (mlisp is a version that
# allows for case-sensitive symbols.)
#
#------------------------------------------------------------------------
# Startup options 
# (from http://www.franz.com/support/documentation/6.1/doc/startup.htm
# 
# +c Start ACL without a console window. Normally, there is a console window to read/write standard I/O. If you close the console window, the Lisp will be killed. 
# 
# +cm Start the console window in a minimized state.  
# 
# +cn Start the console window, but don't activate the console window. This allows Lisp to be started so as to not interfere with the currently selected window.  
# 
# +cx Start the console in a hidden state. Double-clicking on the tray icon will make the console visible. See also the right-click menu on the tray icon. 
# 
# +cc Causes any earlier +c, +cm, +cn, or +cx argument, including those specified as a resource, to be ignored. (The purpose of this argument is to overide such arguments specified as resources, see the section on Resources in delivery.htm.) Any of +c, +cm, +cn, or +cx can be specified and will be effective after +cc. 
# 
# +p Preserve the console window. Without this switch the console window goes away when Lisp exits with a zero exit status. If ACL is exiting unexpectedly you can use this switch to keep the window around to find out what it printed before it died. This is the opposite of the +M argument. 
# 
# +R Don't put the ACL icon in the tray. 
# 
# +RR Do put the ACL icon in the tray. This argument is useful when +R (described just above) is in a resource command line and you wish to override it. It is not necessary to specify this argument unless +R is specified in a resource. See Resources in delivery.htm. 
# 
# +s scriptfile Standard input is initially bound to this file. When the file is completely read, standard input reverts to the console window, if there is one. 
# 
# +M When this argument is present the console window does not need to be closed manually when Lisp exits with a non-zero exit status. This is the opposite of the +p argument. 
# 
# +d dll-name Use the given ACL dll instead of the default acl<version>.dll. 
# 
# +t title Sets the title of the console to title. 
# 
# +B Use no splash screen (a window that appears very quickly to let you know that Lisp is starting).  
# 
# +b text Make the splash screen display text instead of the default bitmap. text just appears in a gray box. 
# 
# +Bt Put up splash screen while Lisp is initializing. The splash screen is stored in the image file. See the description of set-splash-bitmap. 
# 
# -: UNIX only. Causes the Lisp shared library (libacl<version>.so or libacl<version>.sl) to be searched for in a system-dependent way. On Solaris 2 this means using the environment variable LD_LIBRARY_PATH; other systems might use other ways.
# 
# This argument must precede all others. (This argument is processed by the executable before the image file is loaded.)
#   
# -I image-file Specifies the image file to use. This image must have been created with dumplisp or its relative build-lisp-image (or generate-application). 
# 
# The filename of the image file must have an extension (the standard extension is dxl but any extension will do). If the extension is dxl, the image can be specified without .dxl, so these are equivalent:
# 
# mlisp -I foo.dxl
# 
# mlisp -I foo
# 
# If the extension is something other than dxl, it must be specified:
# 
# mlisp -I foo.xxx
# 
# mlisp.exe (Windows) or mlisp (Unix) handles the -I command line argument specially: if mlisp.exe/mlisp is started without an image file (i.e., no -I argument), then it will first look for an image file with the name of the executable and the type dxl in the current directory, then in the same directory as the executable file. (On Windows, these two directories are often the same but need not be, particularly if you are starting from a DOS prompt. On Unix, the current directory is the result of pwd typed to the prompt used to start Allegro CL.)
# 
# That is, if you start c:\x\y\z\mlisp.exe it will look for the image file c:\x\y\z\mlisp.dxl. If it fails to find that image file it will prompt for an image file. Note: you can change the name of mlisp.exe/mlisp if you are delivering an application. If you change mlisp.exe/mlisp to myapp.exe/myapp then when myapp.exe/myapp starts it will look for myapp.dxl.
# 
# If more than one I argument is specified, the first (leftmost) is used and the remainder are ignored. (This means that if a I argument is specified as a resource, it cannot be overridden. See the section on Resources in delivery.htm for information on resources.)
#   
# -q Read working directory .clinit.cl or clinit.cl and sys:siteinit.cl, but do not read ~/.clinit.cl or ~/clinit.cl unless ~ is also the working directory. On Unix, the working directory is specified to Emacs, or, the current directory if starting in a shell. On Windows, the current directory is usually the directory containing the executable (.exe) file that is invoked, but may be something different, such as a directory specified in Start In field of a shortcut. On Unix ~ refers to the user's home directory. On Windows, the home directory is the directory which is the value of the HOME environment variable, or C:\ if HOME is unset. 
# 
# sys:siteinit.cl is hardwired in the system. The actual names of the other initialization files are in a list which is the value of *init-file-names*, whose initial value is (.clinit.cl clinit.cl)  that is clinit.cl with and without a leading dot.
# 
# Do not also specify -qq.
#   
# -qq Do not read sys:siteinit.cl or any initialization file. Do not also specify -q.  
# -C file evaluates (compile-file file)  
# -d file Causes dribbling to file.  
# -H directory Sets the Allegro directory location (the translation of the sys: logical host, the location where Lisp library files will be looked for). If this argument is unspecified, the Allegro directory location is the directory where the executable (mlisp.exe/mlisp) is located.  
# -kill Evaluates (exit 0). That is, Lisp exits. Presumably you have other arguments which do things (like C compiling a file) earlier in the list of command line arguments. Thus
# 
# mlisp.exe C foo.cl kill
# 
# will start Allegro CL, compile foo.cl, and exit.
#   
# -L file Evaluates (load (string file)). Only one file per L argument but as many L arguments as desired can be specified. The L arguments are processed from left to right. 1, 4 
# -locale locale-name Sets the initial locale (the initial value of *locale*) to the locale named by locale-name, which must be the name of a locale available on the machine. See The initial locale when Allegro CL starts up and External formats and locales, both in iacl.htm for details. 1, 4 
# -Q Unused in 6.0/6.1. In 5.0.1 and earlier, this argument suppressed printing the name of the image and library file, but starting in 6.0, those filenames are not printed in any case. This argument will likely be removed in a later release but is kept in 6.0/6.1 for backward compatibility.  
# -W Evaluates (setq *break-on-warnings* t)  
# -e form Evaluates form. 1, 2, 3, 4 
# -batch Run in batch mode: input comes from standard input, exit when an EOF is read. Exit on any error (but print a backtrace to *error-output* if -backtrace-on-error also specified). 5 
# -backtrace-on-error Print a complete backtrace (as printed by :zoom :all t :count t) whenever an error occurs. 6 
# -compat-crlf When specified, #\return #\linefeed translates to '13 10' (as it did in release 5.0.1) instead of '13 13 10' (as it will in release 6.0/6.1 without this option). See #\newline Discussion in iacl.htm for details. Only users with code from Allegro CL 5.0/5.0.1 for Windows should even consider using this option, and most of those do not need it. 6 
# -! Please see Special Note on the -! command-line argument below. This argument should only be used in unusual debugging situations and should never be used in ordinary situations.  
# -project  project-lpr-file [Windows when running the Integrated Development Environment only] have the project specified by the indicated project .lpr file be the current project when the IDE is started. See About IDE startup in cgide.htm. 
# 

# Uncomment the line(s) below for tracing (verbose shows command before and after, xtrace just shows it after):
#  
## set -o xtrace
## set -o verbose

if [ "$ACL" = "" ]; then export ACL=/usr/local/acl/acl62; fi

# Run Allegro using the Linux kernel 2.4.1 compatibility mode
export LD_ASSUME_KERNEL=2.4.1
set -o xtrace
$ACL/alisp "$@"
