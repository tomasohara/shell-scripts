#! /usr/bin/env python
#
# Tests for tpo_count_it.py module
#
# NOTE: some parameters depends directly on other parameters,
#       so its testing is omitted.


"""Tests for tpo_count_it.py module"""


# Standart packages
import unittest

# Local packages
from mezcla.unittest_wrapper import TestWrapper
from mezcla import glue_helpers as gh

#OLD: SCRIPT = './../tpo_count_it.py'
script_name = '../tpo_count_it.py'
SCRIPT = gh.resolve_path(script_name)


class TestIt(TestWrapper):
    """Class for testcase definition"""


    def test_count_extensions(self):
        """test count files with same extension"""
        # NOTE: this is an exaggerated number of files, can be reduced
        input_string   = ('acl.sh add_arrows.sh add_frequencies.perl adhoc-rainbow-test.sh ai-cat-guesser.perl all_script_alias.sh alt-randomize-lines.perl'
                          'anaconda-aliases.bash analyze-relation-searches.perl anova.lisp archive_file.perl archive-tpo-settings.sh ascii2network.perl'
                          'backup-aliases.sh bad-telnet.perl bash-timeout.sh batch-nvidia-smi.sh belief_network.perl bib2text.perl bibitem2bib.perl'
                          'bookmark2ascii.perl browse-db-file.perl build-pattern.sh calc_cooccurrence.perl calc_divergence.perl calc_entropy.perl'
                          'calc_multi_x2.perl calculate_weights.perl calc_x2.perl categorizer.perl check_annots.perl check_confusion.perl check_errors.perl'
                          'check_permissions.perl check_scripts.sh check_wn_polysemy_db.perl chordie-to-chord.perl clisp.sh cmd.sh common.perl common_setenv.sh'
                          'compare-log-output.sh compare_similarity.perl compare_tags.sh compare_wsd_results.perl conflate_frequency.perl consolidate_dso.perl'
                          'consolidate_dso.sh convera-setup.bash convert_fvwmrc.sh convert_sense_IDs.perl convert-todo-to-outlook.perl convert-xwn-sense-tags.perl'
                          'cooccurrence.perl copy-readonly.sh count_bigrams.perl count_it.perl count_tags.perl create-reuters-source.perl create_wn_polysemy_db.perl'
                          'crl_setup.sh cs-load.sh cs_setup.bash cs_setup.sh cut.perl cyc_setup.bash cygwin-tkdiff.sh _debug-prep_brill.perl decode-utf8.perl'
                          'derive_contexts.perl derive_roots.perl determine_unix_shell.perl diagnose-collocations.perl diff.sh diff-wb.sh disambig_entries.perl'
                          'disambiguate-parses.perl disambiguate_text.perl dispdict.perl do-adhoc-factotum-experiments.sh dobackup.sh do-cygwin-mount.sh do_diff.sh'
                          'do_eval.sh do_exp1.sh domainname.sh do_rcsdiff.sh do_regression.perl do_setup.bash do_setup.sh do_simple.sh do_tex.sh dot.sh dotty.sh'
                          'download_html_dir.perl download-wiki-category.perl dso2sgml.perl dump_links.perl echo.perl echo.sh encode-UTF-8.perl english.perl'
                          'ensure-label-studio-running.sh est_cue_validities.perl eval_misc.perl eval_naive_bayes.perl eval-wiki-categorization.perl'
                          'example-test-support.perl exec.sh extract_all_versions.perl extract_conj.perl extract-differentia.perl extract_factotum_relations.perl'
                          'extract-hypernyms.perl extract_lex_rels.perl extract_linkages.perl extract_matches.perl extract_merge_subset.sh extract_roget_categories.perl'
                          'fix-tpo-permissions.sh foreach.perl g2.sh generic_make_links.sh get_collocations.sh get_it.sh get_last_revision.sh get_wsd_collocations.sh'
                          'git-aliases.bash graphling.perl grunoff.sh indexing-aliases.bash indirect_start_hugin_server.sh is_solaris.sh it.perl kdiff.sh somedir'
                          'kill_all_graphling_jobs.sh kill_em.sh k_vec.perl label-studio.bash lbformat.perl ldoce_lookup.sh lexrel2network.perl LICENSE.txt lispl'
                          'reorganize-dir.sh testsdir resolve_wn_sense_key.perl __pycache__ rev_diff.sh er.sh xterm.sh xv.sh xwn.sh')
        expected_result = 'perl\t65\nsh\t57\nbash\t8\nlisp\t1\ntxt\t1'
        self.assertEqual(gh.run(f'echo "{input_string}" | tr " " "\\n" | {SCRIPT} "\\.([^\\.]+)$"'), expected_result)


    def test_count_numbers(self):
        """test count digits from pipe"""
        self.assertEqual(gh.run(f'echo "12 34 56 78" | {SCRIPT} "\\d\\d" | wc -l'), '4')


    def test_parenthesis_check_digits(self):
        """test parenthesis check counting digits from file """
        input_string    = ('specified by section 6 of the GNU manner specified by section 6 of the GNU GPL'
                           'specified by section 6 of the GNU GPL for conveying Corresponding Source.'
                           'Exception to Section 3 of without being bound by section 3 of the ')
        expected_result = '6\t3\n3\t2'
        self.assertEqual(gh.run(f'echo "{input_string}" | {SCRIPT} --i "section (\\d+)"'), expected_result)


    def test_parenthesis_check_words(self):
        """test parenthesis check counting words from file"""
        input_string    = ('A suitable mechanism is one that (a) uses at run time a copy'
                           'users computer system, and (b) will operate properly with a')
        expected_result = '(a)\t1\n(b)\t1'
        self.assertEqual(gh.run(f'echo "{input_string}" | {SCRIPT} "\\(\\w+\\)"'), expected_result)


    def test_differences_suffixes_lookahead(self):
        """test for differences using optional suffixes vs. lookahead (e.g., '\\w{3}((, )|$)' vs. '\\w{3}(?=(, )|$)' """
        ## WORK-IN-PROGRESS


    def test_input_from_file(self):
        """test count patterns from file"""
        input_text      = 'dog\ndog\ncat\ncat\ndog\ndog\ncat\nfish\nfish'
        input_file      = '/tmp/test_file.txt'
        expected_result = 'dog\t4\ncat\t3\nfish\t2'
        gh.run(f'touch {input_file} && echo "{input_text}" > {input_file}')
        self.assertEqual(gh.run(f'{SCRIPT} "\\w+" {input_file}'), expected_result)


    def test_get_pattern_from_file(self):
        """test get pattern from file"""
        pattern_file    = '/tmp/test_pattern_file.txt'
        input_string    = 'dog dog cat cat dog dog cat fish fish'
        expected_result = 'dog\t4\ncat\t3\nfish\t2'
        gh.run(f'touch {pattern_file} && echo -n "\\w+" > {pattern_file}')
        self.assertEqual(gh.run(f'echo "{input_string}" | {SCRIPT} {pattern_file}'), expected_result)


    def test_ignore_case(self):
        """test ignore case option"""
        input_string    = 'BiRd doG cat Cat Dog dOg dog BiRd BiRd Bird BiRd ocean caT oceaN'
        expected_result = 'bird\t5\ndog\t4\ncat\t3\nocean\t2'
        self.assertEqual(gh.run(f'echo "{input_string}" | {SCRIPT} --i "[a-z]+"'), expected_result)
        self.assertEqual(gh.run(f'echo "{input_string}" | {SCRIPT} --ignore_case "[a-z]+"'), expected_result)


    def test_preserve(self):
        """test preserve option"""
        input_string    = 'BiRd doG cat Cat Dog dOg dog BiRd BiRd Bird BiRd ocean caT oceaN'
        expected_result = 'BiRd\t4\ndoG\t1\ncat\t1\nCat\t1\nDog\t1\ndOg\t1\ndog\t1\nBird\t1\nocean\t1\ncaT\t1\noceaN\t1'
        self.assertEqual(gh.run(f'echo "{input_string}" | {SCRIPT} "\\w+"'), expected_result)
        self.assertNotEqual(gh.run(f'echo "{input_string}" | {SCRIPT} --i "\\w+"'), expected_result)
        self.assertEqual(gh.run(f'echo "{input_string}" | {SCRIPT} --i --preserve "\\w+"'), expected_result)


    def test_freq_first(self):
        """test show freq first option"""
        input_string        = 'dog dog cat cat dog dog cat fish fish'
        expected_result     = '4\tdog\n3\tcat\n2\tfish'
        not_expected_result = 'dog\t4\ncat\t3\nfish\t2'
        self.assertEqual(gh.run(f'echo "{input_string}" | {SCRIPT} --freq_first "\\w+"'), expected_result)
        self.assertNotEqual(gh.run(f'echo "{input_string}" | {SCRIPT} --freq_first "\\w+"'), not_expected_result)


    def test_alpha(self):
        """test sort alpha option"""
        input_string        = 'hello this is a test'
        expected_result     = 'a\t1\ne\t2\nh\t2\ni\t2\nl\t2\no\t1\ns\t3\nt\t3'
        not_expected_result = 't\t3\ns\t3\ne\t2\nh\t2\ni\t2\nl\t2\na\t1\no\t1'
        self.assertEqual(gh.run(f'echo "{input_string}" | {SCRIPT} --alpha "\\w"'), expected_result)
        self.assertNotEqual(gh.run(f'echo "{input_string}" | {SCRIPT} --alpha "\\w"'), not_expected_result)


    def test_compact(self):
        """test compact option"""
        input_string    = '   this  ,    words   ,    only   ,    have   ,    one  ,    whitespaces  '
        expected_result = ' this \t1\n words \t1\n only \t1\n have \t1\n one \t1\n whitespaces \t1'
        self.assertEqual(gh.run(f'echo "{input_string}" | {SCRIPT} --compact "[^,]+"'), expected_result)


    def test_occurrences(self):
        """test count occurrences option"""
        input_string    = 'hello this is a test'
        expected_result = 'total occurrence count is 16'
        self.assertEqual(gh.run(f'echo "{input_string}" | {SCRIPT} --occurrences "\\w" | head -n 1'), expected_result)


    def test_occurrence_field(self):
        """test ocurrence field option"""
        input_string    = 'neo@hotmail.com\nmorfeo@gmail.com\ntrinity@gmail.com\nsmith@hotmail.com\ncypher@hotmail.com\ndozer@yahoo.com'
        expected_result = 'hotmail.com\t3\ngmail.com\t2\nyahoo.com\t1'
        self.assertEqual(gh.run(f'echo "{input_string}" | {SCRIPT} --occurrence_field 2 "(\\w+)@(.*$)"'), expected_result)


    def test_percents(self):
        """test show percents option"""
        input_string    = 'dog dog cat cat dog dog cat fish fish'
        expected_result = 'dog\t4\t0.444\ncat\t3\t0.333\nfish\t2\t0.222'
        self.assertEqual(gh.run(f'echo "{input_string}" | {SCRIPT} --percents "\\w+"'), expected_result)


    def test_min2_multiple_nonsingleton_nonsingletons(self):
        """test omit cases that occur once with options: min2 multiple nonsingleton nonsingletons"""
        input_string    = 'dog dog cat cat dog dog cat fish fish ocean monkeys plane ship'
        expected_result = 'dog\t4\ncat\t3\nfish\t2'
        self.assertEqual(gh.run(f'echo "{input_string}" | {SCRIPT} --min2 "\\w+"'), expected_result)
        self.assertEqual(gh.run(f'echo "{input_string}" | {SCRIPT} --multiple "\\w+"'), expected_result)
        self.assertEqual(gh.run(f'echo "{input_string}" | {SCRIPT} --nonsingleton "\\w+"'), expected_result)
        self.assertEqual(gh.run(f'echo "{input_string}" | {SCRIPT} --nonsingletons "\\w+"'), expected_result)


    def test_min_freq(self):
        """test min freq option"""
        input_string    = 'dog dog cat dog dog cat dog dog cat fish cat fish monkey monkey cat fish'
        expected_result = 'dog\t6\ncat\t5'
        self.assertEqual(gh.run(f'echo "{input_string}" | {SCRIPT} --min_freq 4 "\\w+"'), expected_result)


    def test_trim(self):
        """test trim whitespaces option"""
        input_string    = ' this , words , not , have , whitespaces '
        expected_result = 'this\t1\nwords\t1\nnot\t1\nhave\t1\nwhitespaces\t1'
        self.assertEqual(gh.run(f'echo "{input_string}" | {SCRIPT} --trim "[^,]+"'), expected_result)


    def test_unaccent(self):
        """test unaccent option"""
        input_string    = 'dog dóg cat cát dog dog cát fish físh'
        expected_result = 'dog\t4\ncat\t3\nfish\t2'
        self.assertEqual(gh.run(f'echo "{input_string}" | {SCRIPT} --unaccent "\\w+"'), expected_result)


    def test_chomp(self):
        """test strip newline at end with option: chomp"""
        ## WORK-IN-PROGRESS


    def test_restore(self):
        """test restore option"""
        ## WORK-IN-PROGRESS


    def test_multi_per_line(self):
        """test multi per line option"""
        ## WORK-IN-PROGRESS


    def test_one_per_line(self):
        """test one per line"""
        ## WORK-IN-PROGRESS


if __name__ == '__main__':
    unittest.main()
