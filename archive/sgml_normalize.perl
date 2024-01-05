# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl

#  Normalize the SGML tag usage for the MUC-6 project
#
#  The current flex-based taggers use a SGML-like convention
#  of <\tag>...<\endtag> instead of the traditional <tag>...</tag>
#  usage.
#
#  In addition, attributes are specified separately from the starting
#  tag through a {type=(x)} non-SGML tag. These need to be placed
#  within the starting tag (<tag type="x").
#  

# Process each line of the input stream
while (<>) {
    # Reconcile the start/end tag convention w/ standard SGML
    s/<\\end/<\//g;		# change <\endxyz> to </xyz>
    s/<\\/</g;			# change <\xyz> to <xyz>

    # Move the {type([...])} attribute specification into the starting
    # tag as <xyz type="[...]">. 
    #   Ex:   <cs>is{type([[is, [presv]]])}</cs>
    #     =>  <cs type="[[is, [presv]]]">is</cs>
    #   (Note: assumes above subst's)
    s/<(\w+)>([^<>{]+){(\w+)\(([^}]+)\)}/<\1 \3="\4">\2/g;

    # Output the revised line
    print;
}
