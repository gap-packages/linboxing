#############################################################################
##
##  LINBOXING - linboxing.tst
##  Test the package with some examples
##  Paul Smith
##
##  Copyright (C)  2011
##  University of St Andrews
##
##  This file is part of the linboxing GAP package
## 
##  The linboxing package is free software; you can redistribute it and/or
##  modify it under the terms of the GNU General Public License as published by
##  the Free Software Foundation; either version 2 of the License, or (at your
##  option) any later version.
## 
##  The linboxing package is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##  GNU General Public License for more details.
## 
##  You should have received a copy of the GNU General Public License
##  along with this program.  If not, see <http://www.gnu.org/licenses/>.
## 
#############################################################################

gap> START_TEST("linboxing/tst/linboxing.tst");

gap> LoadPackage("linboxing");
true
gap> LinBox.SetMessages(false);
gap> ##  
gap> # Check the PackageInfo.g for this package
gap> ValidatePackageInfo( Filename( DirectoriesPackageLibrary( 
>        "linboxing", "" ), "PackageInfo.g" ) );
true
gap> ##  
gap> # Get a random number generator
gap> rs := GlobalMersenneTwister;
<RandomSource in IsMersenneTwister>
gap> # What is the matrix/vector size to use?
gap> n := 100;
100
gap> ##  
gap> # Check the size of small ints is correct
gap> IsSmallIntRep(LinBox.MAX_GAP_SMALL_INT()) and 
>         not IsSmallIntRep(LinBox.MAX_GAP_SMALL_INT() + 1);
true
gap> ##  
gap> # Test the conversion of a random small integer
gap> z := Random(rs, 1, LinBox.MAX_GAP_SMALL_INT());;
gap> LinBox.TEST_INT_CONVERSION(z) = z;
true
gap> z := -Random(rs, 1, LinBox.MAX_GAP_SMALL_INT());;
gap> LinBox.TEST_INT_CONVERSION(z) = z;
true
gap> # Test the conversion of a random large integer
gap> p := Random([2..1000]);;
gap> z := Random(rs, LinBox.MAX_GAP_SMALL_INT(), 
>              LinBox.MAX_GAP_SMALL_INT()^p);;
gap> LinBox.TEST_INT_CONVERSION(z) = z;
true
gap> z := -Random(rs, LinBox.MAX_GAP_SMALL_INT(), 
>              LinBox.MAX_GAP_SMALL_INT()^p);;
gap> LinBox.TEST_INT_CONVERSION(z) = z;
true
gap> ##  
gap> # Test the conversion of vectors of integers
gap> v := RandomMat(1, n, Integers)[1];;
gap> LinBox.TEST_VECTOR_CONVERSION(v) = v;
true
gap> # Test the conversion of small FFEs
gap> p := NextPrimeInt(Random([1..250]));;
gap> v := RandomMat(1, n, GF(p))[1];;
gap> LinBox.TEST_VECTOR_CONVERSION(v) = v;
true
gap> # Test the conversion of large FFEs
gap> p := NextPrimeInt(Random([256..65520]));;
gap> v := RandomMat(1, n, GF(p))[1];;
gap> LinBox.TEST_VECTOR_CONVERSION(v) = v;
true
gap> ##  
gap> # Test the conversion of matrices of integers
gap> A := RandomMat(n, n, Integers);;
gap> LinBox.TEST_MATRIX_CONVERSION(A) = A;
true
gap> # Test the conversion of small FFEs
gap> p := NextPrimeInt(Random([1..250]));;
gap> A := RandomMat(n, n, GF(p));;
gap> LinBox.TEST_MATRIX_CONVERSION(A) = A;
true
gap> # Test the conversion of large FFEs
gap> p := NextPrimeInt(Random([256..65520]));;
gap> A := RandomMat(n, n, GF(p));;
gap> LinBox.TEST_MATRIX_CONVERSION(A) = A;
true
gap> ##  
gap> # Now test the various functions
gap> # Integers
gap> A := RandomMat(n, n, Integers);;
gap> LinBox.DeterminantMat(A) = DeterminantMat(A);
true
gap> A := RandomMat(n, n, Integers);;
gap> LinBox.RankMat(A) = RankMat(A);
true
gap> A := RandomMat(n, n, Integers);;
gap> LinBox.TraceMat(A) = TraceMat(A);
true
gap> A := RandomMat(n, n, Integers);;
gap> b := RandomMat(1, n, Integers)[1];;
gap> LinBox.SolutionMat(A, b)*A = b;
true
gap> # Small finite field
gap> F := GF(NextPrimeInt(Random([1..250])));;
gap> A := RandomMat(n, n, F);;
gap> LinBox.DeterminantMat(A) = DeterminantMat(A);
true
gap> A := RandomMat(n, n, F);;
gap> LinBox.RankMat(A) = RankMat(A);
true
gap> A := RandomMat(n, n, F);;
gap> LinBox.TraceMat(A) = TraceMat(A);
true
gap> A := RandomMat(n, n, F);;
gap> b := RandomMat(1, n, F)[1];;
gap> LinBox.SolutionMat(A, b)*A = b;
true
gap> # Large finite field
gap> F := GF(NextPrimeInt(Random([256..65520])));;
gap> A := RandomMat(n, n, F);;
gap> LinBox.DeterminantMat(A) = DeterminantMat(A);
true
gap> A := RandomMat(n, n, F);;
gap> LinBox.RankMat(A) = RankMat(A);
true
gap> A := RandomMat(n, n, F);;
gap> LinBox.TraceMat(A) = TraceMat(A);
true
gap> A := RandomMat(n, n, F);;
gap> b := RandomMat(1, n, F)[1];;
gap> LinBox.SolutionMat(A, b)*A = b;
true
gap> 
gap> ## Tweak this number until this gives the same GAP4stones as
gap> ## ReadTest("/usr/local/lib/gap4r4/tst/combinat.tst");
gap> STOP_TEST("linboxing/tst/linboxing.tst", 24000000000);
