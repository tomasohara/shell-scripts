# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
# updatedsc.perl: A perl script to convert the old MSBN32 *.dsc format to 
# a *.dsc format that MSBNx can read
#
# tpo: June 2002
# - downloaded from Microsoft's MSBNx web page
# - added fix for MS_label problem with belief networks
# - added reference to $servicename to quell perl warning
#

$state = "header";


my $iVbTwipsPerPixelX = 15;
my $iVbTwipsPerPixelY = 15;
my $iDscPositionOffset = 10000;
my $iPixelToHiMetric = 26.45;
my $scale = 2;

# tpo: The following was added to avoid a perl warning
# TODO: figure out what the intention of it was for
use vars qw/$servicename/;

while (<>)
{
	if (("nodes" eq $state) && (/^probability/))
	{
		$state = "prob";
	}

	# print "IN state $state, LINE: $_";


	if ("header" eq $state)
	{
		if (/(.*) network (.*)$/)
		{


			print "network $2
{
	format is \"BNFormat\";
	version is 1.0;
	creator is \"MSR DTG\" ;
}
";


			if ("trouble" eq $1)
			{
				$state = "service";
			}
			elsif ("belief" eq $1)
			{

#======================== Big Print =========================

# tpo: added following properties declaration
				print" properties
{
	type MS_label =  choice of [
			other,
            hypothesis,
            informational,
            configuration], \"Troubleshooting category\";
}

";
# ============================================
				$state = "nodes";
			}
			elsif ("diagnostic" eq $1)
			{


#======================== Big Print =========================
				print"properties
{
	type MS_category =  string, \"Usage category\";
	type MS_label =  choice of [
			other,
            hypothesis,
            informational,
            problem,
            fixobs,
            fixunobs,
            unfixable,
            configuration], \"Troubleshooting category\";
}

";
#===============================================


				$state = "nodes";
			}
			else
			{
				die "Expected known network type";
			}
		}
		else
		{
			die("Expected network line: $_");
		}
	}
	elsif ("service" eq $state)
	{
		if (/name: (.*);/)
		{
			$servicename = $1;
		}
		if (/cost: fix = (.*);/)
		{
			$servicecost = $1;


#======================== Big Print =========================
			print "properties
{
	type MS_category = string,
		\"Usage category\";
	type MS_cost_fix = real,
		\"cost to fix\";
	type MS_cost_observe = real,
		\"cost to observe\";
	type MS_label =  choice of [
			other,
            hypothesis,
            informational,
            problem,
            fixobs,
            fixunobs,
            unfixable,
            configuration], \"Troubleshooting category\";
    MS_cost_fix = $servicecost;
";
#===============================================
			$state = "nodes";
		}
	}
##	elsif ("nodes" eq $state)
	elsif (("nodes" eq $state) || ("prob" eq $state))
	{
		
		if (/label: (.*);/)
		{
			if (!($1 eq "fixable"))
			{
				print "\tMS_label = $1;\n";
			}
		}
		 elsif (/category: (.*);/)
		{
			print "\tMS_category = $1;\n";
		}
		elsif (/cost: observe = (.*);/)
		{
			print "\tMS_cost_observe = $1;\n";
		}
		elsif (/name: (.*);/)
		{
			print "\tname = $1;\n";
		}
		elsif (/type: (.*);/)
		{
			print "\tname = $1;\n";
		}
		elsif (/cost: fix = (.*), observe = (.*);/)
		{
			print "\tMS_label = fixobs;\n";
			print "\tMS_cost_fix = $1;\n";
			print "\tMS_cost_observe = $2;\n";
		}
		elsif (/cost: fix = (.*);/)
		{
			print "\tMS_cost_fix = $1;\n";
		}
		elsif (/position = \((.*), (.*)\);/)
		{
			my $x = int((($1-$iDscPositionOffset) / $iVbTwipsPerPixelX) * $iPixelToHiMetric * $scale);
			my $y = int((($2-$iDscPositionOffset) / $iVbTwipsPerPixelY) * $iPixelToHiMetric * $scale);
        
			print "\tposition = ($x, $y);\n";
		}
		else
		{
			print;
		}

	}
	elsif ("prob" eq $state)
	{
		print;
	}
	else
	{
		die "Parser in unknown state\n";
	}	

}

