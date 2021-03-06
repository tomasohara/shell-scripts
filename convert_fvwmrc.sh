#!/bin/sh

# Some time ago, Martin Kraemer <Martin.Kraemer@mch.sni.de> posted an
# incomplete script to convert fvwm-1 'rc' files to fvwm-2. I've just
# recently fixed and enhanced that script; it's complete (or nearly
# so) now. This should help if you choose to convert.
# 
# I've also made a couple of other minor changes to make life easier
# for our users here: I changed the default initialization from "Read
# .fvwmrc" to "Read .fvwm2rc" (in fvwm/fvwmc), and I installed fvwm 2
# as "fvwm2". With these changes, users can easily convert at their
# leisure.
# 
# Herewith the script. It's using GNU awk (gawk), but will run with
# any "new" awk (nawk on Suns (SunOS 4, Solaris), awk on most other
# systems). If you do not use gawk, it will be case-sensitive (the
# case of the fvwm commands must match those in the script
# exactly). With gawk, it'll be case-insensitive.

#
# Convert fvwm 1.x configuration file to 2.0
#
# Originally written by Martin Kraemer <Martin.Kraemer@mch.sni.de>
# Corrected, extended, and modified by Grant McDorman <grant@isgtec.com>
# 24 May 95

echo "fvwmrc-to-2 1.7a"
if [ ! -x /usr/local/bin/gawk ];then
   echo "gawk (/usr/local/bin/gawk) missing, cannot run"
   exit 1
fi
source=${1:-$HOME/.fvwmrc}
dest=${2:-$HOME/.fvwm2rc}
if [ "$dest" != "-" ] ;then
	echo "Output to $dest"
	if [ -f $dest ] ; then
	  mv $dest $dest.bak
	  echo "Saving existing $dest as $dest.bak"
	fi
	exec >$dest
fi
AWK=gawk
cat $source | $AWK '
BEGIN   { printf ("# Trying to compile an old .fvwrc to the  new fvwm-2.0 Format\n");
	    TRUE=1; FALSE=0;

	    IGNORECASE=TRUE;

	    hiforecolor="";             dflt["hiforecolor"] = "black";
	    hibackcolor="";             dflt["hibackcolor"] = "CadetBlue";
	    hilightcolor = FALSE;

	    stdforecolor="";            dflt["stdforecolor"] = "black";
	    stdbackcolor="";            dflt["stdbackcolor"] = "grey70";

	    stickyforecolor="";         dflt["stickyforecolor"] = "black";
	    stickybackcolor="";         dflt["stickybackcolor"] = "grey85";

	    menuforecolor="";           dflt["menuforecolor"] = "black";
	    menubackcolor="";           dflt["menubackcolor"] = "grey70";
	    menustipplecolor="";        dflt["menustipplecolor"] = "grey40";
	    font="";                    dflt["font"] = "-adobe-helvetica-medium-r-*-*-18-*-*-*-*-*-iso8859-1";
	    mwmmenus="";                dflt["mwmmenus"] = "fvwm";
	    menustyle=FALSE;

	    inpopup=FALSE;
	    infunc=FALSE;
	    prefix="";

	}
/^#/    {   # Comment, pass it thru
	    print $0;
	    next
	}

/^$/    {   # Empty line, pass it thru
	    print $0;
	    next;
	}

/TogglePage/ {
		print "#! " $0 " (TogglePage not in fvwm2)";
		print "Warning: TogglePage function not in fvwm2, use EdgeScroll"\
			>"/dev/stderr";
		next;
		}
/[ 	]Restart[ 	].*[ 	]fvwm/ { gsub("fvwm", "fvwm2"); }
/GoodStuff/   {
	gsub("GoodStuff", "FvwmButtons");
	}

################ Highlight Colors ##############
/^HiBackColor[	 ]/ {
	    dflt["hibackcolor"]=hibackcolor=$2;
	    printf ("#!%s (new command=HilightColor)\n", $0);
	    if (hibackcolor != "" && hiforecolor != "" && !hilightcolor)
	    {
		printf ("\n#Set the foreground and background color for selected windows\n");
		printf ("HilightColor   %s %s\n", hiforecolor, hibackcolor);
		hilightcolor=TRUE;
	    }
	    else
		hilightcolor=FALSE;
	    next;
	}
/^HiForeColor[	 ]/  {
	    dflt["hiforecolor"]=hiforecolor=$2;
	    printf ("#!%s (new command=HilightColor)\n", $0);
	    if (hibackcolor != "" && hiforecolor != "" && !hilightcolor)
	    {
		printf ("\n#Set the foreground and background color for selected windows\n");
		printf ("HilightColor   %s %s\n", hiforecolor, hibackcolor);
		hilightcolor=TRUE;
	    }
	    else
		hilightcolor=FALSE;
	    next;
	}
########## Sticky Colors ###########
# @@@@@@@@@@To Do@@@@@@@@@@@@@@@
/^StickyForeColor[	 ]/ {
	    dflt["stickyforecolor"]=stickyforecolor=$2;
	    printf ("#!%s (no sticky foreground color in fvwm2)\n", $0);
	    print "Warning: StickyForeColor not in fvwm2, omitted" >"/dev/stderr"
	    next;
	}
# @@@@@@@@@@To Do@@@@@@@@@@@@@@@
/^StickyBackColor[	 ]/ {
	    dflt["stickybackcolor"]=stickybackcolor=$2;
	    printf ("#!%s (no sticky background color in fvwm2)\n", $0);
	    print "Warning: StickyBackColor not in fvwm2, omitted" >"/dev/stderr"
	    next;
	}
########## Menu Colors, Style and Font ###########
/^MenuForeColor[	 ]/ {
	    dflt["menuforecolor"]=menuforecolor=$2;
	    printf ("#!%s (new command=MenuStyle)\n", $0);
	    if (menubackcolor != "" && menuforecolor != "" && menustipplecolor != "" && font != "" && mwmmenus != "" && !menustyle)
	    {
		printf ("\n#Set the foreground, background and stipple color and font for menus\n");
		printf ("MenuStyle   %s %s %s %s %s\n", menuforecolor, menubackcolor, menustipplecolor, font, mwmmenus);
		menustyle=TRUE;
	    }
	    else
		menustyle=FALSE;
	    next;
	}
/^MenuBackColor[	 ]/ {
	    dflt["menubackcolor"]=menubackcolor=$2;
	    printf ("#!%s (new command=MenuStyle)\n", $0);
	    if (menubackcolor != "" && menuforecolor != "" && menustipplecolor != "" && font != "" && mwmmenus != "" && !menustyle)
	    {
		printf ("\n#Set the foreground, background and stipple color and font for menus\n");
		printf ("MenuStyle   %s %s %s %s %s\n", menuforecolor, menubackcolor, menustipplecolor, font, mwmmenus);
		menustyle=TRUE;
	    }
	    else
		menustyle=FALSE;
	    next;
	}
/^MenuStippleColor[	 ]/ {
	    dflt["menustipplecolor"]=menustipplecolor=$2;
	    printf ("#!%s (new command=MenuStyle)\n", $0);
	    if (menubackcolor != "" && menuforecolor != "" && menustipplecolor != "" && font != "" && mwmmenus != "" && !menustyle)
	    {
		printf ("\n#Set the foreground, background and stipple color and font for menus\n");
		printf ("MenuStyle   %s %s %s %s %s\n", menuforecolor, menubackcolor, menustipplecolor, font, mwmmenus);
		menustyle=TRUE;
	    }
	    else
		menustyle=FALSE;
	    next;
	}
/^MWMMenus$/ {
	    mwmmenus="mwm";
	    printf ("#!%s (new command=MenuStyle)\n", $0);
	    if (menubackcolor != "" && menuforecolor != "" && menustipplecolor != "" && font != "" && mwmmenus != "" && !menustyle)
	    {
		printf ("\n#Set the foreground, background and stipple color and font for menus\n");
		printf ("MenuStyle   %s %s %s %s %s\n", menuforecolor, menubackcolor, menustipplecolor, font, mwmmenus);
		menustyle=TRUE;
	    }
	    else
		menustyle=FALSE;
	    next;
	}
/^Font[	 ]/ {
	    dflt["font"]=font=$2;
	    printf ("#!%s (new command=MenuStyle)\n", $0);
	    if (menubackcolor != "" && menuforecolor != "" && menustipplecolor != "" && font != "" && mwmmenus != "" && !menustyle)
	    {
		printf ("\n#Set the foreground, background and stipple color and font for menus\n");
		printf ("MenuStyle   %s %s %s %s %s\n", menuforecolor, menubackcolor, menustipplecolor, font, mwmmenus);
		menustyle=TRUE;
	    }
	    else
		menustyle=FALSE;
	    next;
	}

# @@@@@@@@@@To Do@@@@@@@@@@@@@@@
/^PagerForeColor[	 ]/ {
	    dflt["pagerforecolor"]=pagerforecolor=$2;
	    printf ("#!%s (new command=Style FvwmPager)\n", $0);
	    next;
	}
# @@@@@@@@@@To Do@@@@@@@@@@@@@@@
/^PagerBackColor[	 ]/ {
	    dflt["pagerbackcolor"]=pagerbackcolor=$2;
	    printf ("#!%s (new command=Style FvwmPager)\n", $0);
	    next;
	}

# Translate both old ButtonStyle formats to the new format:
/^ButtonStyle[	 ]/  {
	    if ($2 == ":")   # new style already
	    {
		if (NF != $4+4)
		    print "ERROR: ButtonStyle command incorrect" >"/dev/stderr";
		printf ("%s %d %d", $1, $3, $4);
		for (i=5; i<=NF; ++i)
		    printf (" %s", $i);
		printf ("\n");
	    }
	    else
	    {
		print "Note: Conversion of old ButtonStyle; values rounded" \
			>"/dev/stderr"
		printf ("#!         Old line was: %s\n", $0);
		p=index ($3,"x");
		x=substr($3,1,p-1)/2;
		y=substr($3,p+1)/2;
		printf ("%s %s 5 %dx%d@0 %dx%d@0 %dx%d@0 %dx%d@1 %dx%d@1\n",
		    $1, $2, 50-x,50+y, 50+x,50+y, 50-x,50-y, 50+x,50-y,
		    50-x,50+y);
	    }
	    next;
	}

########## Standard Colors ###########
/^StdForeColor[	 ]/ {
	    dflt["stdforecolor"]=stdforecolor=$2;
	    printf ("#!%s (new command=Style \"*\" Color f/b)\n", $0);
	    print "Style \"*\" ForeColor " $2;
	    next;
	}
/^StdBackColor[	 ]/ {
	    dflt["stdbackcolor"]=stdbackcolor=$2;
	    printf ("#!%s (new command=Style \"*\" Color f/b)\n)\n", $0);
	    print "Style \"*\" BackColor " $2;
	    next;
	}
/^IconBox[	 ]/ {
	    print "Style \"*\" " $0;
	    next;
	}
/^MWMFunctionHints$/ { printf ("Style \"*\" MWMFunctions\n"); next; }
/^MWMDecor$/         { printf ("Style \"*\" MWMDecor\n"); next; }
/^MWMDecorHints$/         { printf ("Style \"*\" MWMDecor\n"); next; }
/^MWMBorder$/        { printf ("Style \"*\" MWMBorder\n"); next; }
/^MWMButtons$/       { printf ("Style \"*\" MWMButtons\n"); next; }
/^MWMHintOverride$/  { printf ("Style \"*\" HintOverride\n"); next; }
/^RandomPlacement$/ { print "Style \"*\" " $0; next; }
/^SmartPlacement$/ { print "Style \"*\" " $0; next; }
/^BorderWidth$/ { print "Style \"*\" " $0; next; }
/^HandleWidth$/ { print "Style \"*\" " $0; next; }
/^NoPPosition$/ { print "Style \"*\" " $0; next; }
/^DecorateTransients$/ { print "Style \"*\" DecorateTransient"; next; }
/^SuppressIcons$/      { print "Style \"*\" NoIcon"; next; }
/^StickyIcons$/      { print "Style \"*\" StickyIcon"; next; }

/^AutoRaise[	 ]/	{ print "#! " $0 " (use Module FvwmAuto)";
			  print "AddToFunc \"InitFunction\" \"I\" Module FvwmAuto " $2;
			  next;
			}
/^ModulePath[	 ]/    { print "ModulePath /isg/proj/x11/contrib/clients/fvwm2"; next; }
/^PixmapPath[	 ]/    { print $0; next; }
/^IconPath[	 ]/      { print $0; next; }
/^Style[	 ]/         { print $0; next; }
/^Key[	 ]/           { print $0; next; }
/^Mouse[	 ]/         {
	if (sub("[ 	]Pop[uU]p[ 	]", " Menu "))
	{
	    if (!warn["Mouse"])
	    {
		print "Note: Setting mouse bindings to sticky menus">"/dev/stderr";
		warn["Mouse"] = TRUE;
	    }
	    sub("$", " Nop");
	}
	 print $0; next; }
/^WindowFont[	 ]/    { print $0; next; }
/^IconFont[	 ]/      { print $0; next; }
/^Stubborn/ {
	print "#! " $0;
	print "Warning: " $1 " not in Fvwm2, command dropped">"/dev/stderr";
	next;
 }
/^ClickTime[	 ]/	{ print $0; next; }
/^OpaqueMove[	 ]/	{ print "OpaqueMoveSize " $2; next; }
/^EdgeScroll[	 ]/	{ print $0; next; }
/^EdgeResistance[	 ]/ { print $0; next; }
/^DeskTopSize[	 ]/ { print $0; next; }
/^DeskTopScale/ {
	print "#! " $0;
	print "Warning: " $1 " not in Fvwm2, command dropped">"/dev/stderr";
	next;
 }
/^WindowListSkip[	 ]/ { print "#! $0 [deleted]";
		if (warned[$1]==FALSE)
		{
		print "Warning: " $1 " commented out, obsolete" >"/dev/stderr";
		warned[$1] = TRUE;
		}
		next;
	}
/^Pager/ { print "#! $0 [deleted]";
		if (warned[$1]==FALSE)
		{
		print "Warning: " $1 " commented out, obsolete (use FvwmPager)" >"/dev/stderr";
		warned[$1] = TRUE;
		}
		next;
	}

/^PagingDefault[ 	]/ { 
	print "#! " $0 " (use EdgeScroll 0 0)"; next;
	print "Warning: PagingDefault not in Fvwm2, use EdgeScroll 0 0">"/dev/stderr";
 }

/^\*FvwmButtons/   {
	sub("[ 	]Swallow[ 	]*[^ 	]*", "& Exec");
	print $0;
	if (length($0) > 199)
	{
	    print "Warning: line too long" >"/dev/stderr";
	    print ">> " $0 >"/dev/stderr";
	}
	if (!warn["GoodStuff"])
	{
	    print "Note: GoodStuff renamed to FvwmButtons" >"/dev/stderr";
	    warn["GoodStuff"]=TRUE;
	}
	next; }

/^\*/   {   # other Module Configuration commands are passed thru
	    print $0;
	    next;
	}

/^Function[	 ]/ {
	    if (inpopup)
		print "ERROR: EndPopup missing", "at ", FNR  >"/dev/stderr";
	    inpopup=FALSE;
	    if (infunction)
		print "ERROR: EndFunction missing", "at ", FNR >"/dev/stderr";
	    infunction=TRUE;
	    prefix="AddToFunc " $2;
	    next;
	}
/^EndFunction$/ {
	    if (!infunction)
		print "ERROR: EndFunction outside of function", "at ", FNR >"/dev/stderr";
	    infunction=FALSE;
	    prefix="";
	    next;
	}

/^Popup[	 ]/ {
	    if (inpopup)
		print "ERROR: EndPopup missing", "at ", FNR >"/dev/stderr";
	    if (infunction)
		print "ERROR: EndFunction missing", "at ", FNR >"/dev/stderr";
	    infunction=FALSE;
	    inpopup=TRUE;
	    prefix="AddToMenu " $2;
	    next;
	}
/^EndPopup$/ {
	    if (!inpopup)
		print "ERROR: EndPopup outside of popup", "at ", FNR >"/dev/stderr";
	    inpopup=FALSE;
	    prefix="";
	    next;
	}

	{
	    if (infunction)
	    {
	    #gsub("[ 	]PopUp[ 	]", " "); }
		if ($2 == "\"Motion\"")
		    context="\"M\"";
		else if ($2 == "\"Click\"")
		    context="\"C\"";
		else if ($2 == "\"DoubleClick\"")
		    context="\"D\"";
		else context=$2;

		printf "%s", prefix " " context " " $1;
		for (i=3; i<=NF; ++i)
		    printf (" %s", $i);
		printf ("\n");
		prefix="+             ";
		next;
	    }
	    else if (inpopup)
	    {
		# not going to handle escaped quotes
		label=$2;
		first=3;
		quoted=substr(label, 1, 1)=="\"" &&
			substr(label, length(label), 1)!="\"";
		for (i=3;i<=NF && quoted;i++)
		{
		    label=label " " $i;
		    quoted=substr(label, length(label), 1)!="\"";
		    first=i + 1;
		}

		printf ("%s %s %s", prefix, label, $1);
		for (i=first; i<=NF; ++i)
		    printf (" %s", $i);
		printf ("\n");
		prefix="+             ";
		next;
	    }

	    if (warned[$1]==FALSE)
	    {
		printf ("#!WARNING: Keyword \"%s\" not handled yet\n", $1);
		warned[$1]=TRUE;
		print "Warning: Unknown keyword "$1" passed through">"/dev/stderr";
	    }
	    print $0;
	    next;
	}

END     {
	    if (!menustyle)
	    {
		printf ("\n#Set the foreground, background and stipple color and font for menus\n");
		printf ("MenuStyle   %s %s %s %s %s\n", dflt["menuforecolor"], dflt["menubackcolor"], dflt["menustipplecolor"], dflt["font"], dflt["mwmmenus"]);
	    }
	    if (!hilightcolor)
	    {
		printf ("\n#Set the foreground and background color for selected windows\n");
		printf ("HilightColor   %s %s\n", dflt["hiforecolor"], dflt["hibackcolor"]);
	    }
	}
'
exit

