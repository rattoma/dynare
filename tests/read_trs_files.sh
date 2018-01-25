#!/bin/bash

declare -i total=0;
declare -i total_xfail=0;
declare -i failed=0;
declare -i xpassed=0;
declare -a failed_tests=("");
declare -a xpassed_tests=("");

# Parse TRS Files
tosort=""
for file in $1 ; do
  # Find number of tests run in trs file
  ((total += `grep number-tests $file | cut -d: -f3`))

  # Find number of tests failed in trs file
  numfailed=`grep number-failed-tests $file | cut -d: -f3`
  if [ $numfailed -ne 0 ] ; then
    ((failed += $numfailed))
    for failedfile in `grep list-of-failed-tests $file | cut -d: -f3` ; do
      failed_tests=("${failed_tests[@]}" "$failedfile");
    done
  fi

  time=`grep elapsed-time $file | cut -d: -f3`
  tosort=`echo $tosort\| $file ' - ' $time:`
done
((passed=$total-$failed));

# Parse XFAIL TRS Files
for file in $2 ; do
  # Find number of tests run in xfail trs file
  ((xfail = `grep number-tests $file | cut -d: -f3`))
  ((total_xfail += $xfail))

  # Find number of tests failed in trs file
  numpassed=`grep number-failed-tests $file | cut -d: -f3`
  if [ $numpassed -eq 0 ] ; then
    ((xpassed += (($xfail - $numpassed))))
    for xpassedfile in `grep list-of-passed-tests $file | cut -d: -f3` ; do
      xpassed_tests=("${xpassed_tests[@]}" "$xpassedfile");
    done
  fi

  time=`grep elapsed-time $file | cut -d: -f3`
  tosort=`echo $tosort\| $file ' - ' $time:`
done
((xfailed=$total_xfail-$xpassed));
((total+=$total_xfail));

timing=`echo $tosort | tr ":" "\n" | sort -rn -k4 | sed -e 's/$/:/' | head -n10`

# Determine if we are parsing Matlab or Octave trs files
if [ `grep -c '.m.trs' <<< $1` -eq 0 ]; then
  prg='OCTAVE';
  outfile='run_test_octave_output.txt'
else
  prg='MATLAB';
  outfile='run_test_matlab_output.txt'
fi

# Print Output
echo '================================'             > $outfile
echo 'DYNARE MAKE CHECK '$prg' RESULTS'            >> $outfile
echo '================================'            >> $outfile
echo '| TOTAL: '$total                             >> $outfile
echo '|  PASS: '$passed                            >> $outfile
echo '|  FAIL: '$failed                            >> $outfile
echo '| XFAIL: '$xfailed                           >> $outfile
echo '| XPASS: '$xpassed                           >> $outfile
if [ $failed -gt 0 ] ; then
  echo '| LIST OF FAILED TESTS:'                   >> $outfile
  for file in ${failed_tests[@]} ; do
    if [ "$prg" == "MATLAB" ]; then
      modfile=`sed 's/\.m\.trs/\.mod/g' <<< $file` >> $outfile
    else
      modfile=`sed 's/\.o\.trs/\.mod/g' <<< $file` >> $outfile
    fi
    echo '|     * '$modfile                        >> $outfile
  done
fi
if [ $xpassed -gt 0 ] ; then
  echo '|  LIST OF XPASSED TESTS:'                 >> $outfile
  for file in ${xpassed_tests[@]} ; do
    if [ "$prg" == "MATLAB" ]; then
      modfile=`sed 's/\.m\.trs/\.mod/g' <<< $file` >> $outfile
    else
      modfile=`sed 's/\.o\.trs/\.mod/g' <<< $file` >> $outfile
    fi
    echo '|     * '$modfile                        >> $outfile
  done
fi
echo '|'                                           >> $outfile
echo '| LIST OF 10 SLOWEST TESTS:'                 >> $outfile
if [ "$prg" == "MATLAB" ]; then
    timing=`sed 's/\.m\.trs/\.mod/g' <<< $timing`
else
    timing=`sed 's/\.o\.trs/\.mod/g' <<< $timing`
fi
echo $timing | tr ':' '\n' | sed -e 's/^[ \t]*//' | \
     sed '/^$/d' | sed -e 's/^|[ ]/|     * /'      >> $outfile
echo                                               >> $outfile
