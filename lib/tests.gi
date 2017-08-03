#############################################################################
##
##  LINBOXING - tests.gi
##  GAP-LinBox test routines
##  Paul Smith
##
##  Copyright (C)  2007-2008
##  Paul Smith
##  National University of Ireland Galway
##
##  This file is part of the linboxing GAP package.
## 
##  The linboxing package is free software; you can redistribute it and/or 
##  modify it under the terms of the GNU General Public License as published by
##  the Free Software Foundation; either version 2 of the License, or (at your 
##  option) any later version.
## 
##  The linboxing package is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of 
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General 
##  Public License for more details.
## 
##  You should have received a copy of the GNU General Public License along 
##  with this program.  If not, see <http://www.gnu.org/licenses/>.
## 
##  $Id: tests.gi 95 2008-01-31 15:36:50Z pas $
##
#############################################################################

if not IsBound(LinBox) then
  InstallGlobalFunction(TestLinboxing,
    function()
      Print("ERROR! The linboxing kernel module has not been sucessfully loaded.");  
    end);
else

  #####################################################################
  ##  <#GAPDoc Label="LinBox.TEST_INT_CONVERSION_manInt">
  ##  <ManSection>
  ##  <Func Name="LinBox.TEST_INT_CONVERSION" Arg="z"/>
  ##
  ##  <Description>
  ##  Convert the integer <A>z</A> into the internal LinBox format and 
  ##  back again, returning the result.
  ##  </Description>
  ##  </ManSection>
  ##  <#/GAPDoc>
  #####################################################################
  LinBox.TEST_INT_CONVERSION := function(z)
  
    local elm, x, id;
      
    if not IsInt(z) then
      Error("<z> must be an integer");
    fi;
    
    return LinBox.TEST_INT_CONVERSION_INTERNAL(z, LinBox.FIELD_DATA([[1]]));
  end;
  #####################################################################
  
  #####################################################################
  ##  <#GAPDoc Label="LinBox.TEST_VECTOR_CONVERSION_manInt">
  ##  <ManSection>
  ##  <Func Name="LinBox.TEST_VECTOR_CONVERSION" Arg="v"/>
  ##
  ##  <Description>
  ##  Convert the vector <A>v</A> into the internal LinBox format and 
  ##  back again, returning the result.
  ##  </Description>
  ##  </ManSection>
  ##  <#/GAPDoc>
  #####################################################################
  LinBox.TEST_VECTOR_CONVERSION := function(v)
  
    local elm, x, id;
      
    if not IsVector(v) then
      Error("<v> must be a matrix");
    fi;
    
    return LinBox.TEST_VECTOR_CONVERSION_INTERNAL(v, LinBox.FIELD_DATA([v]));
  end;
  #####################################################################
  
  #####################################################################
##  <#GAPDoc Label="LinBox.TEST_MATRIX_CONVERSION_manInt">
##  <ManSection>
##  <Func Name="LinBox.TEST_MATRIX_CONVERSION" Arg="M"/>
##
##  <Description>
##  Convert the matrix <A>M</A> into the internal LinBox format and 
##  back again, returning the result.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
#####################################################################
LinBox.TEST_MATRIX_CONVERSION := function(M)

  local elm, x, id;
    
  if not IsMatrix(M) then
    Error("<M> must be a matrix");
  fi;
  

  return LinBox.TEST_MATRIX_CONVERSION_INTERNAL(M, LinBox.FIELD_DATA(M));
end;
#####################################################################
  

#####################################################################
##  <#GAPDoc Label="TestLinboxing_manMisc">
##  <ManSection>
##  <Func Name="TestLinboxing" Arg="[num-tests]"/>
##
##  <Description>
##  Test the installation of &linboxing; and print profiling information.
##  This tries all the &linboxing; package's algorithms with random vectors and 
##  matrices over random fields (covering all the distinct supported field 
##  types). The results are compared with the equivalent &GAP; functions, and 
##  the relative times displayed. 
##  <P/>
##  The optional argument <A>num-tests</A> specifies how many times to run each 
##  test: the default is 5 times.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
#####################################################################
InstallGlobalFunction(TestLinboxing,
  function(arg)
    local p, M, m, n, i, j, v, F,
    dettime, ranktime, tracetime, solvetime, 
    NumTests, SmallMat, LargeMat,
    testdata, ntests, fielddata, nfields, results, f, s, failed, passed,
    rs,
    time, slower, faster, equal,
    OK, AllOK,
    RANDOM_SMALL_FIELD, RANDOM_LARGE_FIELD, INTEGERS,
    RANDOM_SQUARE_MAT, RANDOM_MAT,
    TEST_DETERMINANT,
    TEST_RANK,
    TEST_TRACE,
    TEST_SOLUTIONMAT,
    RUN_TESTS,
    PASS_FAIL_STRING, 
    FACTOR_STRING, 
    FASTER_SLOWER;

    if Length(arg) = 1 then
      NumTests := arg[1];
    else
      NumTests := 5;
    fi;  
    #LinBox.SetMessages(false);

    failed := [];
    passed := [];
    AllOK := true;

    ###################################################
    ## Returns "PASSED" if pass is true, or "FAILED" otherwise
    PASS_FAIL_STRING := function(pass)
      if pass then
        return "PASSED";
      else
        return "FAILED";
      fi;
      return pass;
    end;
    ###################################################

    ###################################################
    ## return a random prime field of size less than 256
    RANDOM_SMALL_FIELD := function()
      local p;
      p := NextPrimeInt(Random([1..250]));
      return GF(p);
    end;
    ###################################################

    ###################################################
    ## return a random prime field of size between 256 and 65536
    RANDOM_LARGE_FIELD := function()
      local p;
      p := NextPrimeInt(Random([256..65520]));
      return GF(p);
    end;
    ###################################################

    ###################################################
    ## return the integers. Defined to match the look of RANDOM_SMALL_FIELD
    INTEGERS := function()
      return Integers;
    end;
    ###################################################

    ###################################################
    ## return a random square matrix
    ##  m - The maximum size
    ##  F - The field
    RANDOM_SQUARE_MAT := function(m, F)
      m := Random([Int(m/10+1)..m]);
      Print("Random ", m, "x", m, " matrix over ", F, ": ");
      return RandomMat(m, m, F);
    end;
    ###################################################

    ###################################################
    ## return a random matrix
    ##  m - The maximum size
    ##  F - The field
    RANDOM_MAT := function(m, F)
      local n;
      m := Random([Int(m/10+1)..m]);
      n := Random([Int(m/10+1)..m]);
      Print("Random ", m, "x", n, " matrix over ", F, ": ");
      return RandomMat(m, n, F);
    end;
    ###################################################
  
    ## First test that the conversions work
    ## Check small integers
    rs := GlobalMersenneTwister;
    Print("Testing GAP-LinBox-GAP data conversion\n");
    Print("======================================\n");
    Print("\n");

    if IsSmallIntRep(LinBox.MAX_GAP_SMALL_INT()) and
    not IsSmallIntRep(LinBox.MAX_GAP_SMALL_INT() + 1) then
      Print("The maximum small integer is ", LinBox.MAX_GAP_SMALL_INT(), "\n");
      Add(passed, "Size of small integer\n");
    else
      Print("ERROR: The LinBox kernel module  has the wrong maximum small integer\n");
      Add(failed, "Size of small integer wrong\n");
      AllOK := false;
    fi;
  
    ###################
    Print("\n - Small Integers\n");
    OK := true;
    for i in [1..NumTests] do
      j := Random(rs, -LinBox.MAX_GAP_SMALL_INT(), LinBox.MAX_GAP_SMALL_INT());
      Print(j, ": ");
      if not LinBox.TEST_INT_CONVERSION(j) = j then
        OK := false;
        AllOK := false;
        Print("FAILED\n");
      else;
        Print("OK\n");
      fi;
    od;
    Print(PASS_FAIL_STRING(OK), "\n");
    if OK then
      Add(passed, "Small integer GAP-LinBox-GAP conversion\n");
    else
      Add(failed, "Small integer GAP-LinBox-GAP conversion\n");
    fi;
    
    ###################
    Print("\n - Large Integers\n");
    OK := true;
    for i in [1..NumTests] do
      p := Random([2..1000]);
      j := Random(rs, LinBox.MAX_GAP_SMALL_INT(), LinBox.MAX_GAP_SMALL_INT()^p);
      s := String(j);
      Print("Random ", Length(s), "-digit integer: ");
      if Random([1..2]) = 1 then
        j := j * -1;
      fi;
      if not LinBox.TEST_INT_CONVERSION(j) = j then
        OK := false;
        AllOK := false;
        Print("FAILED\n");
      else;
        Print("OK\n");
      fi;
    od;
    Print(PASS_FAIL_STRING(OK), "\n");
    if OK then
      Add(passed, "Large integer GAP-LinBox-GAP conversion\n");
    else
      Add(failed, "Large integer GAP-LinBox-GAP conversion\n");
    fi;

    ###################
    Print("\n - Vectors of integers\n");
    OK := true;
    for i in [1..NumTests] do
      v := RandomMat(1, Random([2..500]), Integers)[1];
      Print("Random ", Length(v), "-vector over the Integers: ");
      if not LinBox.TEST_VECTOR_CONVERSION(v) = v then
        OK := false;
        AllOK := false;
        Print("FAILED\n");
      else;
        Print("OK\n");
      fi;
    od;
    Print(PASS_FAIL_STRING(OK), "\n");
    if OK then
      Add(passed, "Integer vector GAP-LinBox-GAP conversion\n");
    else
      Add(failed, "Integer vector GAP-LinBox-GAP conversion\n");
    fi;

    ###################
    Print("\n - Vectors of finite field elements\n");
    OK := true;
    for i in [1..NumTests] do
      if Random([1,2]) = 1 then
        F := RANDOM_SMALL_FIELD();
      else
        F := RANDOM_LARGE_FIELD();
      fi;
      v := RandomMat(1, Random([2..500]), F)[1];
      Print("Random ", Length(v), "-vector over ", F, ": ");
      if not LinBox.TEST_VECTOR_CONVERSION(v) = v then
        OK := false;
        AllOK := false;
        Print("FAILED\n");
      else;
        Print("OK\n");
      fi;
    od;
    Print(PASS_FAIL_STRING(OK), "\n");
    if OK then
      Add(passed, "Finite-field vector GAP-LinBox-GAP conversion\n");
    else
      Add(failed, "Finite-field vector GAP-LinBox-GAP conversion\n");
    fi;


    ###################
    Print("\n - Matrices of integers\n");
    OK := true;
    for i in [1..NumTests] do
      M := RANDOM_MAT(250, Integers);
      if not LinBox.TEST_MATRIX_CONVERSION(M) = M then
        OK := false;
        AllOK := false;
        Print("FAILED\n");
      else;
        Print("OK\n");
      fi;
    od;
    Print(PASS_FAIL_STRING(OK), "\n");
    if OK then
      Add(passed, "Integer matrix GAP-LinBox-GAP conversion\n");
    else
      Add(failed, "Integer matrix GAP-LinBox-GAP conversion\n");
    fi;

    ###################
    Print("\n - Matrices of finite field elements\n");
    OK := true;
    for i in [1..NumTests] do
      if Random([1,2]) = 1 then
        M := RANDOM_MAT(250, RANDOM_SMALL_FIELD());
      else
        M := RANDOM_MAT(250, RANDOM_LARGE_FIELD());
      fi;
      if not LinBox.TEST_MATRIX_CONVERSION(M) = M then
        OK := false;
        AllOK := false;
        Print("FAILED\n");
      else;
        Print("OK\n");
      fi;
    od;
    Print(PASS_FAIL_STRING(OK), "\n");
    if OK then
      Add(passed, "Finite-field matrix GAP-LinBox-GAP conversion\n");
    else
      Add(failed, "Finite-field matrix GAP-LinBox-GAP conversion\n");
    fi;


    
    ###################################################
    ## Test the LinBox determinant function
    ##   F - the field to use
    ##   m - the maximum matrix size to use
    ##   time - list to fill in with the GAP and LinBox time respectively
    ##  returns true if the test succeeded, or false otherwise
    TEST_DETERMINANT := function(F, m, time)
      local A, GAPans, LBans;

      A := RANDOM_SQUARE_MAT(m, F);
    
      time[1] := time[1] - Runtime();
      if F = Integers then 
        GAPans := DeterminantIntMat(A);
      else
        GAPans := DeterminantMat(A);
      fi;        
      time[1] := time[1] + Runtime();

      time[2] := time[2] - Runtime();
      LBans := LinBox.DeterminantMat(A);
      time[2] := time[2] + Runtime();
      if GAPans = LBans then
        Print("determinant ", GAPans, "\n");
        return true;
      else
        Print("ERROR: determinants do not agree\n");
        return false;
      fi;

    end;
    ###################################################

    ###################################################
    ## Test the LinBox rank function
    ##   F - the field to use
    ##   m - the maximum matrix size to use
    ##   time - list to fill in with the GAP and LinBox time respectively
    ##  returns true if the test succeeded, or false otherwise
    TEST_RANK := function(F, m, time)
      local A, GAPans, LBans;

      A := RANDOM_MAT(m, F);
  
      time[1] := time[1] - Runtime();
      GAPans := RankMat(A);
      time[1] := time[1] + Runtime();
      time[2] := time[2] - Runtime();
      LBans := LinBox.RankMat(A);
      time[2] := time[2] + Runtime();
      if GAPans = LBans then
        Print("rank ", GAPans, "\n");
        return true;
      else
        Print("ERROR: ranks do not agree\n");
        return false;
      fi;

    end;
    ###################################################

    ###################################################
    ## Test the LinBox trace function
    ##   F - the field to use
    ##   m - the maximum matrix size to use
    ##   time - list to fill in with the GAP and LinBox time respectively
    ##  returns true if the test succeeded, or false otherwise
    TEST_TRACE := function(F, m, time)
      local A, GAPans, LBans;

      A := RANDOM_SQUARE_MAT(m, F);

      time[1] := time[1] - Runtime();
      GAPans := TraceMat(A);
      time[1] := time[1] + Runtime();

      time[2] := time[2] - Runtime();
      LBans := LinBox.TraceMat(A);
      time[2] := time[2] + Runtime();
      if GAPans = LBans then
        Print("trace ", GAPans, "\n");
        return true;
      else
        Print("ERROR: traces do not agree\n");
        return false;
      fi;

    end;
    ###################################################

    ###################################################
    ## Test the LinBox SolutionMat function
    ##   F - the field to use
    ##   m - the maximum matrix size to use
    ##   time - list to fill in with the GAP and LinBox time respectively
    ##  returns true if the test succeeded, or false otherwise
    TEST_SOLUTIONMAT := function(F, m, time)
      local A, b, GAPans, LBans, I, n;

      A := RANDOM_MAT(m, F);
      # make sure that about a quarter have no solution
      if Random([1..4]) = 1 then
        n := Length(A[1]);
        I := IdentityMat(n, F);
        I[n][n] := Zero(F);
        A := A*I;
      fi;
      b := RandomMat(1, Length(A[1]), F)[1];
    
      time[1] := time[1] - Runtime();
      GAPans := SolutionMat(A, b);
      time[1] := time[1] + Runtime();

      time[2] := time[2] - Runtime();
      LBans := LinBox.SolutionMat(A, b);
      time[2] := time[2] + Runtime();
      if LBans = fail then
        if GAPans = fail then
          Print("no solution - OK\n");
          return true;
        else
          Print("ERROR: GAP found a solution but LinBox returned fail\n");
          return false;
        fi;
      else
        if LBans*A = b then
          Print("solution OK\n");
          return true;
        else
          if GAPans = fail then
            Print("ERROR: LinBox found an incorrect solution when GAP returned fail\n");
            return false;
          else
            Print("ERROR: LinBox found an incorrect solution\n");
            return false;
          fi; 
        fi;
      fi;
    end;
    ###################################################


    ###################################################
    ## Convert a fraction, given as a numerator and denominator,
    ## into a decimal string with one decimal place
    FACTOR_STRING := function(num, den)
      local f, s, l;

      if den = 0 then
        if num = 0 then
          return "undefined";
        else
          return "infinite";
        fi;
      fi;

      f := Int(num * 10 / den + 1/2);
      if IsInt(f/10) then
        return Concatenation(String(f/10), ".0");
      elif f < 10 then
        return Concatenation("0.", String(f));
      else
        s := String(f);
        l := Length(s);
        return Concatenation(s{[1..(l-1)]}, ".", s{[l]});
      fi;
    end;
    ###################################################

    ###################################################
    ## Returns 1 if LinBox is faster, -1 if it is slower,
    ## or 0 if they are the same to within a tenth.
    FASTER_SLOWER := function(time)
      local f;

      if time[2] = 0 then
        if time[1] = 0 then
          return 0;
        else
          return 1;
        fi;
      fi;

      f := time[1]/time[2];
      if f >= (11/10) then
        return 1;
      elif f <= (9/10) then
        return -1;
      else
        return 0;
      fi;
    end;
    ###################################################

    ###################################################
    ## Run a number of tests using a given function, and
    ## print some feedback
    ##  func_name - The GAP function name to test
    ##  test_func - The function to run the test
    ##  field_func - The function to return the field to use
    ##  mat_size - The maximum matrix size, to pass to test_func
    ##  num_tests - The number of tests to run
    ## Returns a list containing in the first place true/false indicating
    ## whether all the tests passed or not, and then the total times taken for 
    ## the GAP and LinBox versions respectively.
    RUN_TESTS := function(func_name, test_func, field_func, mat_size, num_tests)
      local time, i, AllOK;

      AllOK := true;
      time := [0, 0];

      Print("\n");
      Print(" - ", func_name, "\n");
      for i in [1..num_tests] do
        if not test_func(field_func(), mat_size, time) then
          AllOK := false;
        fi;
      od;

      Print(func_name, " took ", time[1], "\n");
      Print("LinBox.", func_name, " took ", time[2], "\n");

      Print("Test ", PASS_FAIL_STRING(AllOK), "\n");

      return [AllOK, time[1], time[2]];
    end;
    ###################################################


    # A data structure detailing which fields to use to test with
    # The elements here are
    # fielddata[i][1] := name for main test loop
    # fielddata[i][1] := name for summary results
    # fielddata[i][1] := function to generate random field
    fielddata := [
    ["prime fields (size < 256)", "Small finite fields", RANDOM_SMALL_FIELD],
    ["prime fields (size < 65536)", "Large finite fields", RANDOM_LARGE_FIELD],
    ["integers", "Integers", INTEGERS]
    ];
    nfields := Length(fielddata);
    results := [];
    for i in [1..nfields] do
      results[i] := [];
    od;

    # The testdata list consists of lists with the following entries
    # testdata[i][1] := string with function name
    # testdata[i][2] := test function to call
    # testdata[i][3] := list of the sizes to send to the function for [small field, large field, int] respectively
    # testdata[i][4] := list of the number of tests to use in each case 
    testdata := [];
    Add(testdata, ["DeterminantMat", TEST_DETERMINANT, [500, 175, 125], [NumTests, NumTests, NumTests]]);
    Add(testdata, ["RankMat", TEST_RANK, [500, 175, 125], [NumTests, NumTests, NumTests]]);
    Add(testdata, ["TraceMat", TEST_TRACE, [500, 175, 125], [NumTests, NumTests, NumTests]]);
    Add(testdata, ["SolutionMat", TEST_SOLUTIONMAT, [500, 175, 125], [NumTests, NumTests, NumTests]]);
    ntests := Length(testdata);

    # Check that the testdata have the right number of field entries
    for i in [1..ntests] do
      if Length(testdata[i][3]) <> nfields or Length(testdata[i][4]) <> nfields then
        Error("the data structures defining the testdata are wrong! Please contact the maintainer");
      fi;
    od;


    # Now do the tests
    for f in [1..nfields] do

      Print("\n");
      s := Concatenation("Testing ", fielddata[f][1]);
      Print(s, "\n");
      for i in [1..Length(s)] do
        Print("=");
      od;
      Print("\n");

      for i in [1..ntests] do
        results[f][i] := CallFuncList(RUN_TESTS,
          [testdata[i][1], testdata[i][2], fielddata[f][3], testdata[i][3][f], testdata[i][4][f]]);
      od;
    od;


    Print("\n");
    Print("Summary Results\n");
    Print("===============\n");
    Print("\n");

    for f in [1..nfields] do
      for i in [1..ntests] do
        s := Concatenation(fielddata[f][2], " - ", testdata[i][1], "\n");
        if results[f][i][1] = true then
          Add(passed, s);
        else
          Add(failed, s);
        fi;
      od;
    od;

    Print("PASSED tests:\n");
    if IsEmpty(passed) then
      Print("  none!\n");
    else
      for f in passed do
        Print("  ", f);
      od;
    fi;

    Print("FAILED tests:\n");
    if IsEmpty(failed) then
      Print("  none\n");
    else
      for f in failed do
        Print("  ",f);
      od;
    fi;


    #####

    Print("\n");

    faster := [];
    slower := [];
    equal := [];
    for f in [1..nfields] do
      for i in [1..ntests] do
        if results[f][i][1] = true then
          time := results[f][i]{[2,3]};
          s := Concatenation(fielddata[f][2], " - ", testdata[i][1]);
          if FASTER_SLOWER(time) = 0 then
            Add(equal, Concatenation(s, "\n"));
          else
            s := Concatenation(s, " (speedup ", FACTOR_STRING(time[1], time[2]), ")\n");
            if FASTER_SLOWER(time) = 1 then
              Add(faster, s);
            else
              Add(slower, s);
            fi; 
          fi; 
        fi;
      od;
    od;

    Print("LinBox is FASTER for:\n");
    if IsEmpty(faster) then
      Print("  nothing!\n");
    else
      for f in faster do
        Print("  ",f);
      od;
    fi;

    Print("LinBox is SLOWER for:\n");
    if IsEmpty(slower) then
      Print("  nothing!\n");
    else
      for f in slower do
        Print("  ",f);
      od;
    fi;

    if not IsEmpty(equal) then
      Print("LinBox is the same speed as GAP for:\n");
      for f in equal do
        Print("  ",f);
      od;
    fi;

end);
#####################################################################
          

fi; # if not IsBound(LinBox) then
 



