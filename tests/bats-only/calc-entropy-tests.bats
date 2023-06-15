#!/usr/bin/env bats


# Make executables ./tests/../ visible to PATH
PATH="/home/aveey/tom-project/shell-scripts/tests/batspp-only/../:$PATH"

# Enable aliases
shopt -s expand_aliases



@test "test-1" {
	testfolder="/tmp/batspp-201680/test-1"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $"bind 'set enable-bracketed-paste off'\n" "=========="
	test-1-actual 
	echo "=========" $"$ unalias -a\n$ for f in $(typeset -f | egrep '^\\w+'); do unset -f $f; done\n$ BIN_DIR=$PWD/.." "========="
	test-1-expected 
	echo "============================"
	# ???: "bind 'set enable-bracketed-paste off'\n"=$(test-1-actual)
	# ???: "$ unalias -a\n$ for f in $(typeset -f | egrep '^\\w+'); do unset -f $f; done\n$ BIN_DIR=$PWD/.."=$(test-1-expected)
	[ "$(test-1-actual)" == "$(test-1-expected)" ]
}

function test-1-actual () {
	# no-op in case content just a comment
	true

	bind 'set enable-bracketed-paste off'

}

function test-1-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ unalias -a
$ for f in $(typeset -f | egrep '^\w+'); do unset -f $f; done
$ BIN_DIR=$PWD/..
END_EXPECTED
}


@test "test-3" {
	testfolder="/tmp/batspp-201680/test-3"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $"# $ echo 'Hii'\n" "=========="
	test-3-actual 
	echo "=========" $'# | Hi?2004l' "========="
	test-3-expected 
	echo "============================"
	# ???: "# $ echo 'Hii'\n"=$(test-3-actual)
	# ???: '# | Hi?2004l'=$(test-3-expected)
	[ "$(test-3-actual)" == "$(test-3-expected)" ]
}

function test-3-actual () {
	# no-op in case content just a comment
	true


}

function test-3-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
# | Hi?2004l
END_EXPECTED
}


@test "test-4" {
	testfolder="/tmp/batspp-201680/test-4"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'calc_entropy=calc_entropy.perl\n' "=========="
	test-4-actual 
	echo "=========" $'$ simple="-simple"\n$ verbose="-verbose"\n# -or-: calc_entropy="calc_entropy.py"; simple="--simple"; verbose="--verbose"\n# Convenience alias to use <NL> for entirely blank lines (i.e., no spaces)\n$ alias encode-blank-line=\'perl -pe "s/^$/<NL>/;"\'' "========="
	test-4-expected 
	echo "============================"
	# ???: 'calc_entropy=calc_entropy.perl\n'=$(test-4-actual)
	# ???: '$ simple="-simple"\n$ verbose="-verbose"\n# -or-: calc_entropy="calc_entropy.py"; simple="--simple"; verbose="--verbose"\n# Convenience alias to use <NL> for entirely blank lines (i.e., no spaces)\n$ alias encode-blank-line=\'perl -pe "s/^$/<NL>/;"\''=$(test-4-expected)
	[ "$(test-4-actual)" == "$(test-4-expected)" ]
}

function test-4-actual () {
	# no-op in case content just a comment
	true

	calc_entropy=calc_entropy.perl

}

function test-4-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ simple="-simple"
$ verbose="-verbose"
# -or-: calc_entropy="calc_entropy.py"; simple="--simple"; verbose="--verbose"
# Convenience alias to use <NL> for entirely blank lines (i.e., no spaces)
$ alias encode-blank-line='perl -pe "s/^$/<NL>/;"'
END_EXPECTED
}


@test "test-5" {
	testfolder="/tmp/batspp-201680/test-5"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'$calc_entropy $simple .25 .25 .25 .25\n' "=========="
	test-5-actual 
	echo "=========" $'Entropy\n2.000' "========="
	test-5-expected 
	echo "============================"
	# ???: '$calc_entropy $simple .25 .25 .25 .25\n'=$(test-5-actual)
	# ???: 'Entropy\n2.000'=$(test-5-expected)
	[ "$(test-5-actual)" == "$(test-5-expected)" ]
}

function test-5-actual () {
	# no-op in case content just a comment
	true

	$calc_entropy $simple .25 .25 .25 .25

}

function test-5-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
Entropy
2.000
END_EXPECTED
}


@test "test-6" {
	testfolder="/tmp/batspp-201680/test-6"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'head calc_entropy.*input* | encode-blank-line\n' "=========="
	test-6-actual 
	echo "=========" $"==> calc_entropy.input <==\n# Frequency of 'between' in Penn Treebank II WSJ annotations\n24\tpp-clr\n6\tpp-dir\n4\tpp-ext\n35\tpp-loc\n2\tpp-nom\n7\tpp-prd\n42\tpp-tmp\n<NL>\n==> calc_entropy.input2 <==\n2\tabc\n4\tdef\n1\tghi\n1\tjkl\n<NL>\n==> calc_entropy.simple.input <==\n.25 .25 .25 .25\n<NL>\n==> calc_entropy.simple.input2 <==\n.47 .42 .06 .05" "========="
	test-6-expected 
	echo "============================"
	# ???: 'head calc_entropy.*input* | encode-blank-line\n'=$(test-6-actual)
	# ???: "==> calc_entropy.input <==\n# Frequency of 'between' in Penn Treebank II WSJ annotations\n24\tpp-clr\n6\tpp-dir\n4\tpp-ext\n35\tpp-loc\n2\tpp-nom\n7\tpp-prd\n42\tpp-tmp\n<NL>\n==> calc_entropy.input2 <==\n2\tabc\n4\tdef\n1\tghi\n1\tjkl\n<NL>\n==> calc_entropy.simple.input <==\n.25 .25 .25 .25\n<NL>\n==> calc_entropy.simple.input2 <==\n.47 .42 .06 .05"=$(test-6-expected)
	[ "$(test-6-actual)" == "$(test-6-expected)" ]
}

function test-6-actual () {
	# no-op in case content just a comment
	true

	head calc_entropy.*input* | encode-blank-line

}

function test-6-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
==> calc_entropy.input <==
# Frequency of 'between' in Penn Treebank II WSJ annotations
24	pp-clr
6	pp-dir
4	pp-ext
35	pp-loc
2	pp-nom
7	pp-prd
42	pp-tmp
<NL>
==> calc_entropy.input2 <==
2	abc
4	def
1	ghi
1	jkl
<NL>
==> calc_entropy.simple.input <==
.25 .25 .25 .25
<NL>
==> calc_entropy.simple.input2 <==
.47 .42 .06 .05
END_EXPECTED
}


@test "test-7" {
	testfolder="/tmp/batspp-201680/test-7"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'$calc_entropy $simple - < ./calc_entropy.simple.input\n' "=========="
	test-7-actual 
	echo "=========" $'Entropy\n2.000' "========="
	test-7-expected 
	echo "============================"
	# ???: '$calc_entropy $simple - < ./calc_entropy.simple.input\n'=$(test-7-actual)
	# ???: 'Entropy\n2.000'=$(test-7-expected)
	[ "$(test-7-actual)" == "$(test-7-expected)" ]
}

function test-7-actual () {
	# no-op in case content just a comment
	true

	$calc_entropy $simple - < ./calc_entropy.simple.input

}

function test-7-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
Entropy
2.000
END_EXPECTED
}


@test "test-8" {
	testfolder="/tmp/batspp-201680/test-8"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'$calc_entropy $simple - < ./calc_entropy.simple.input2\n' "=========="
	test-8-actual 
	echo "=========" $'Entropy\n1.497' "========="
	test-8-expected 
	echo "============================"
	# ???: '$calc_entropy $simple - < ./calc_entropy.simple.input2\n'=$(test-8-actual)
	# ???: 'Entropy\n1.497'=$(test-8-expected)
	[ "$(test-8-actual)" == "$(test-8-expected)" ]
}

function test-8-actual () {
	# no-op in case content just a comment
	true

	$calc_entropy $simple - < ./calc_entropy.simple.input2

}

function test-8-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
Entropy
1.497
END_EXPECTED
}


@test "test-9" {
	testfolder="/tmp/batspp-201680/test-9"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'$calc_entropy $verbose $simple - < ./calc_entropy.simple.input2\n' "=========="
	test-9-actual 
	echo "=========" $'#\tprob\t-p lg(p)    max p\n#--------------------------------\n#\t0.470\t0.512\n#\t0.420\t0.526\n#\t0.060\t0.244\n#\t0.050\t0.216\n#--------------------------------\n# word\tclasses\tfreq\tentropy\tmax_prob\n#\t1.000\t1.497\t   0.470\nEntropy\n1.497' "========="
	test-9-expected 
	echo "============================"
	# ???: '$calc_entropy $verbose $simple - < ./calc_entropy.simple.input2\n'=$(test-9-actual)
	# ???: '#\tprob\t-p lg(p)    max p\n#--------------------------------\n#\t0.470\t0.512\n#\t0.420\t0.526\n#\t0.060\t0.244\n#\t0.050\t0.216\n#--------------------------------\n# word\tclasses\tfreq\tentropy\tmax_prob\n#\t1.000\t1.497\t   0.470\nEntropy\n1.497'=$(test-9-expected)
	[ "$(test-9-actual)" == "$(test-9-expected)" ]
}

function test-9-actual () {
	# no-op in case content just a comment
	true

	$calc_entropy $verbose $simple - < ./calc_entropy.simple.input2

}

function test-9-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
#	prob	-p lg(p)    max p
#--------------------------------
#	0.470	0.512
#	0.420	0.526
#	0.060	0.244
#	0.050	0.216
#--------------------------------
# word	classes	freq	entropy	max_prob
#	1.000	1.497	   0.470
Entropy
1.497
END_EXPECTED
}


@test "test-10" {
	testfolder="/tmp/batspp-201680/test-10"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'$calc_entropy - < ./calc_entropy.input\n' "=========="
	test-10-actual 
	echo "=========" $'2.230' "========="
	test-10-expected 
	echo "============================"
	# ???: '$calc_entropy - < ./calc_entropy.input\n'=$(test-10-actual)
	# ???: '2.230'=$(test-10-expected)
	[ "$(test-10-actual)" == "$(test-10-expected)" ]
}

function test-10-actual () {
	# no-op in case content just a comment
	true

	$calc_entropy - < ./calc_entropy.input

}

function test-10-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
2.230
END_EXPECTED
}


@test "test-11" {
	testfolder="/tmp/batspp-201680/test-11"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'$calc_entropy $verbose - < calc_entropy.input | encode-blank-line\n' "=========="
	test-11-actual 
	echo "=========" $'#\t\tclass\tfreq\tprob\t-p lg(p)\n#\t\tpp-tmp\t42\t0.350\t0.530\n#\t\tpp-loc\t35\t0.292\t0.518\n#\t\tpp-clr\t24\t0.200\t0.464\n#\t\tpp-prd\t7\t0.058\t0.239\n#\t\tpp-dir\t6\t0.050\t0.216\n#\t\tpp-ext\t4\t0.033\t0.164\n#\t\tpp-nom\t2\t0.017\t0.098\n#\t\ttotal\t120\t1.000\t2.230\n<NL>\n# word\tclasses\tfreq\tentropy\tmax_prob\n-\t7\t120\t2.230\t0.350' "========="
	test-11-expected 
	echo "============================"
	# ???: '$calc_entropy $verbose - < calc_entropy.input | encode-blank-line\n'=$(test-11-actual)
	# ???: '#\t\tclass\tfreq\tprob\t-p lg(p)\n#\t\tpp-tmp\t42\t0.350\t0.530\n#\t\tpp-loc\t35\t0.292\t0.518\n#\t\tpp-clr\t24\t0.200\t0.464\n#\t\tpp-prd\t7\t0.058\t0.239\n#\t\tpp-dir\t6\t0.050\t0.216\n#\t\tpp-ext\t4\t0.033\t0.164\n#\t\tpp-nom\t2\t0.017\t0.098\n#\t\ttotal\t120\t1.000\t2.230\n<NL>\n# word\tclasses\tfreq\tentropy\tmax_prob\n-\t7\t120\t2.230\t0.350'=$(test-11-expected)
	[ "$(test-11-actual)" == "$(test-11-expected)" ]
}

function test-11-actual () {
	# no-op in case content just a comment
	true

	$calc_entropy $verbose - < calc_entropy.input | encode-blank-line

}

function test-11-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
#		class	freq	prob	-p lg(p)
#		pp-tmp	42	0.350	0.530
#		pp-loc	35	0.292	0.518
#		pp-clr	24	0.200	0.464
#		pp-prd	7	0.058	0.239
#		pp-dir	6	0.050	0.216
#		pp-ext	4	0.033	0.164
#		pp-nom	2	0.017	0.098
#		total	120	1.000	2.230
<NL>
# word	classes	freq	entropy	max_prob
-	7	120	2.230	0.350
END_EXPECTED
}
