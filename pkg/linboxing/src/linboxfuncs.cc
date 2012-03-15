/*****************************************************************************
  LINBOXING - linboxfuncs.cc
  All LinBox-related C++ code
  Paul Smith

  Copyright (C)  2007-2008
  National University of Ireland Galway
  Copyright (C)  2011
  University of St Andrews

  This file is part of the linboxing GAP package. 
 
  The linboxing package is free software; you can redistribute it and/or 
  modify it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or (at your 
  option) any later version.
 
  The linboxing package is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY 
  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for 
  more details.
 
  You should have received a copy of the GNU General Public License along with 
  this program.  If not, see <http://www.gnu.org/licenses/>.
 
*****************************************************************************/

//////////////////////////////////////////////////////////////////////////////
/**
@file linboxfuncs.cc
This file contains all of the code that deals with %LinBox. This should ideally 
be split into three source files: convert.cc, solutions.cc and tests.cc, but 
%LinBox currently does not support seperate source files (it multiply-defines
some functions which then causes linker errors). If this is ever fixed, we
can separate this into different source files.
**/
//////////////////////////////////////////////////////////////////////////////

/*****************************************************************************
  LINBOXING - convert.cc
  GAP-LinBox-GAP conversion functions
  Paul Smith

  Copyright (C)  2007-2008
  Paul Smith
  National University of Ireland Galway

  This file is part of the linboxing GAP package. 
 
  The linboxing package is free software; you can redistribute it and/or 
  modify it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or (at your 
  option) any later version.
 
  The linboxing package is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY 
  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for 
  more details.
 
  You should have received a copy of the GNU General Public License along with 
  this program.  If not, see <http://www.gnu.org/licenses/>.
 
*****************************************************************************/

#include "convert.h"

#ifdef GAP_4_5
extern "C"
{
  #include <src/gmpints.h>
}
#endif // GAP_4_5

//////////////////////////////////////////////////////////////////////////////

#ifndef GAP_4_5

/// This macro is copied from the GAP source file $GAPROOT/src/integer.c
/// It returns the number of <tt>TypDigit</tt>s in a long integer.
#define SIZE_INT(op)    (SIZE_OBJ(op) / sizeof(TypDigit))

/// This macro is copied from the GAP source file $GAPROOT/src/integer.c
/// It returns the address of the first digit in a long integer as a 
/// pointer to a <tt>TypDigit</tt>.
#define ADDR_INT(op)    ((TypDigit*)ADDR_OBJ(op))

#endif // GAP_4_5


//////////////////////////////////////////////////////////////////////////////


/// Calculate and store the biggest integer that can be stored as a GAP small integer
const LBIntegers::Element maxGAPsmallint((1L << NR_SMALL_INT_BITS) - 1);
/// Calculate and store the smallest integer that can be stored as a GAP small integer
const LBIntegers::Element minGAPsmallint((1L << NR_SMALL_INT_BITS) * -1);

/// Test whether the %LinBox integer \a z will fit into a GAP small integer.
/// The largest GAP small integer is either 2^28-1 or 2^60-1, depending on 
/// whether the machine is 64- or 32-bit
inline bool IsGAPSmallInt(const LBIntegers::Element& z)
{
  return z <= maxGAPsmallint && z >= minGAPsmallint;
}

/// Test whether the %LinBox finite field element \a e will fit into a GAP small 
/// integer.
/// The largest GAP small integer is either 2^28-1 or 2^60-1, depending on 
/// whether the machine is 64- or 32-bit
inline bool IsGAPSmallInt(const LBFiniteField::Element& e)
{
  return LBInteger_Int(e) <= maxGAPsmallint && LBInteger_Int(e) >= minGAPsmallint;
}

/// Return the the largest small integer as a GAP small integer (for debugging)
extern "C"
Obj MaxGAPSmallInt()
{
  return INTOBJ_INT(Int_Element(maxGAPsmallint));
}


//////////////////////////////////////////////////////////////////////////////


/// Convert a GAP integer object (small or large) to a %LinBox integer
/// field element.
/// @param z The GAP integer object to convert
/// @returns The same integer as a %LinBox integer field element
LBIntegers::Element LinBox_GAPInt(Obj z)
{
  // Is it a small integer?
  if(IS_INTOBJ(z))
    return LBInteger_Int(INT_INTOBJ(z));
  else
  {
    // Check it's a GAP large integer
    if(TNUM_OBJ(z) != T_INTNEG && TNUM_OBJ(z) != T_INTPOS)
    {
      throw GAPLinBoxException("Only integers and prime fields are supported. Elements over characteristic zero must be integer.");
    }

#ifndef USE_GMP
    // see $GAPROOT/src/integer.c for details of the format
    // The data type is a C-style array of length SIZE_INT(z)
    // with entries that are digits (of type TypDigit) in a number of base
    // INTBASE. Read these out directly and build up the number in a 
    // LinBox integer
    LBIntegers::Element e = LBInteger_Int(0);
    LBIntegers::Element base = LBInteger_Int(INTBASE);
    TypDigit* zp = ADDR_INT(z);
    for(size_t p = 0; p < SIZE_INT(z); p++)
    {
      e += LBInteger_Int(zp[p]) * pow(base, p);
    }

    if(TNUM_OBJ(z) == T_INTNEG)
      e *= -1;

    return e;
#else 
    // It is a GMP integer
    TypLimb* ptr = (TypLimb*)ADDR_INT(z);
    TypGMPSize size = SIZE_INT(z);
    LBIntegers::Element::vect_t vec(ptr, ptr+size); 
    LBIntegers::Element e(vec);

    if(TNUM_OBJ(z) == T_INTNEG)
      e = Integer::negin(e);
    
    return e;
#endif 

/*
    This orginal version is a little slower
    
    It uses GAP's arithmetic to break the input object z into chunks
    that are no bigger than a GAP small integer, and builds up the 
    LinBox integer from those.
    
    LBIntegers::Element e;
    // Create a GAP (large) integer that is one larger than the biggest
    // small integer
    Obj GAPmod = PowInt(INTOBJ_INT(2), INTOBJ_INT(NR_SMALL_INT_BITS));
    LBIntegers::Element ZZmod = pow(LBIntegers::Element(2), NR_SMALL_INT_BITS);
    // z modulo this number will be a small integer
    e = LBIntegers::Element(INT_INTOBJ(ModInt(z, GAPmod)));
    Obj m = QuoInt(z, GAPmod);
    // Now divide our integer by mod and repeat
    long unsigned int p = 1;
    for( ; !IS_INTOBJ(m); ++p)
    {
      Obj r = ModInt(m, GAPmod);
      e += LBIntegers::Element(INT_INTOBJ(r)) * pow(ZZmod, p);
      // And divide again
      m = QuoInt(m, GAPmod);
    }
    e += LBIntegers::Element(INT_INTOBJ(m)) * pow(ZZmod, p);
*/
  }
}

/// Convert a %LinBox finite field element to a GAP integer object.
/// Only fields that will fit into a GAP small integer are currently supported
/// @param e The element to convert
/// @returns The same element as a GAP integer object. This will need converting
/// into a field element at the GAP level.
Obj GAP_LinBoxInt(const LBFiniteField::Element& e)
{
  if(IsGAPSmallInt(e)) 
    return INTOBJ_INT(Int_Element(e));
  else
    throw GAPLinBoxException("The finite field element is too large to convert");
}

/// Convert a %LinBox integer element to a GAP integer object 
/// (either small or large integer format as appropriate).
/// @param e The integer to convert
/// @returns The same integer as a GAP object
Obj GAP_LinBoxInt(const LBIntegers::Element& e)
{
  if(IsGAPSmallInt(e)) 
    return INTOBJ_INT(Int_Element(e));
  else
  {
/*
    It is slower (in this case) to build a GAP large integer directly

    //see $GAPROOT/src/integer.c for details of the format
    //We can read out of the object directly, but timings
    //indicate that this is slower (by almost a factor of two) than 
    //the code below, which does it base 2^NR_SMALL_INT_BITS rather than
    //base INTBASE
    LBIntegers::Element base(INTBASE);
    LBIntegers::Element ee = e;
    bool neg = false;
    if(ee < 0)
    {
      ee *= -1;
      neg = true;
    }

    // Count the number of digits (including padding)
    LBIntegers::Element maxdigit(INTBASE);
    Int d = 1;
    for(; maxdigit < ee; maxdigit = maxdigit * INTBASE, d++);
    int pad = (4 - (d % 4)) % 4;
    d += pad;

    Obj z = NewBag(neg ? T_INTNEG : T_INTPOS, d * sizeof(TypDigit));
    TypDigit* zd = ADDR_INT(z);
    while(ee > base)
    {
      *zd++ = TypDigit(ee % base);
      ee /= base;
    }
    *zd++ = TypDigit(ee);
    for(int i = 0; i < pad; i++)
    {
      *zd++ = TypDigit(0);
    }
*/
#ifndef USE_GMP
    // Create a GAP (large) integer that is one larger than the biggest
    // small integer
    Obj GAPmod = PowInt(INTOBJ_INT(2), INTOBJ_INT(NR_SMALL_INT_BITS));
    LBIntegers::Element ZZmod = pow(LBInteger_Int(2), NR_SMALL_INT_BITS);
    // z modulo this number will be a small integer
    Obj z = INTOBJ_INT(Int_Element(e % ZZmod));
    LBIntegers::Element m = e / ZZmod;
    // Now divide our integer by mod and repeat
    Obj b = GAPmod;
    while(!IsGAPSmallInt(m))
    {
      LBIntegers::Element r = m % ZZmod;
      z = SumInt(z, ProdInt(INTOBJ_INT(Int_Element(r)), b));
      // And divide again
      m = m / ZZmod;
      // And calculate the next power of the base
      b = ProdInt(b, GAPmod);
    }
    z = SumInt(z, ProdInt(INTOBJ_INT(Int_Element(m)), b));

    return z;
#else
    Obj z;
    if(e.sign() < 0) 
    {
      z = NewBag(T_INTNEG, length(e));
    }
    else
    {
      z = NewBag(T_INTPOS, length(e));
    }

    // Need to cast away the const since Givaro does not provide a 
    // public const version of get_mpz()
    LBIntegers::Element& temp_e = const_cast<LBIntegers::Element&>(e);
    mpz_ptr p_gmpz = temp_e.get_mpz();
    size_t size = mpz_size(p_gmpz);

    mp_limb_t* p_limbs = ADDR_INT(z);
    for(int i = 0; i < size; i++)
      p_limbs[i] = mpz_getlimbn(p_gmpz, i);
    // Is this necessary?
    z = GMP_NORMALIZE(z);
    return z;
#endif //GAP_4_5
  }   
}







/*****************************************************************************
  LINBOXING - solutions.cc
  Provide GAP versions of the LinBox solutions
  Paul Smith

  Copyright (C)  2007-2008
  National University of Ireland Galway
  Copyright (C)  2011
  University of St Andrews

  This file is part of the linboxing GAP package. 
 
  The linboxing package is free software; you can redistribute it and/or 
  modify it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or (at your 
  option) any later version.
 
  The linboxing package is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY 
  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for 
  more details.
 
  You should have received a copy of the GNU General Public License along with 
  this program.  If not, see <http://www.gnu.org/licenses/>.
 
*****************************************************************************/

#include <memory>

#include "convert.h"
#include "runfunc.h"

extern "C" 
{
  #include <src/bool.h>
  #include <src/ariths.h>
  
  #include "linboxing.h"
}

#include "linbox/solutions/rank.h"
#include "linbox/solutions/det.h"
#include "linbox/solutions/trace.h"
#include "linbox/solutions/solve.h"
#ifdef HAVE_LIBNTL
  #include "linbox/solutions/smith-form.h"
#endif //HAVE_NTL

/// The C++ Standard Library namespace
using namespace std;
/// The %LinBox namespace wraps all %LinBox functions and objects
using namespace LinBox;

//////////////////////////////////////////////////////////////////////////////


/// GAP kernel C function to turn on or off the printing of the %LinBox 
/// commentator messages 
/// @param self The standard GAP first parameter
/// @param on If is the GAP object \c True, then all messages are turned on, 
/// or if this is the GAP object \c False then they are turned off. All other
/// values for \a on are ignored.
extern "C"
Obj FuncSET_LINBOX_MESSAGES(Obj self, Obj on)
{
  if(on == True)
  {
    commentator.setMaxDetailLevel(-1);
    commentator.setMaxDepth(-1);
    commentator.setPrintParameters(-1, -1, 0);
    commentator.setReportStream(std::cerr);
  }
  else if(on == False)
  {
    commentator.setMaxDetailLevel(0);
    commentator.setMaxDepth(0);
    commentator.setReportStream(commentator.cnull);
    commentator.setPrintParameters(0, 0, 0);
  }
  return (Obj)0;
}

//////////////////////////////////////////////////////////////////////////////

/// Functor to calculate the rank of a matrix.
class RankFunc
{
  public:
    /// The functor's function
    /// @param M The GAP matrix object 
    /// @param F An instance of the %LinBox field
    /// @param one The one of the field
    /// @return The rank of the object as a GAP object
    template<typename Field>
    Obj operator()(Obj M, Field& F, Obj one) const
    {
      auto_ptr<typename LBDenseMatrix<Field>::Type > A(LinBox_GAPMatrix(M, F));

      long unsigned int rr;
      rank(rr, *A, Method::BlasElimination());
      //rank(rr, *A); // requires givaro

      // We know the answer must fit into a GAP small integer
      // since no GAP list can be longer than that
      return INTOBJ_INT(rr);
    }
};

/// GAP kernel C handler to calculate the rank of a matrix. This just calls 
/// RunLinBoxFunction() with the RankFunc functor.
/// @param self The usual GAP first parameter
/// @param M The GAP matrix object 
/// @param fielddata The field data
/// @return The rank of the matrix
extern "C"
Obj FuncRANK(Obj self, Obj M, Obj fielddata)
{
  return RunLinBoxFunction<RankFunc>(M, fielddata);
}


//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////

/// Functor to calculate the determinant of a matrix.
class DeterminantFunc
{
  public:
    /// The functor's function
    /// @param M The GAP matrix object 
    /// @param F An instance of the %LinBox field
    /// @param one The one of the field
    /// @return The determinant of the object as a GAP object
    template<typename Field>
    Obj operator()(Obj M, Field& F, Obj one) const
    {
      auto_ptr<typename LBDenseMatrix<Field>::Type > A(LinBox_GAPMatrix(M, F));

      typename Field::Element dd;
      det(dd, *A);

      return PROD(GAP_LinBoxInt(dd), one);
    }
};

/// GAP kernel C handler to calculate the determinant of a matrix. This just 
/// calls RunLinBoxFunction() with the DeterminantFunc functor.
/// @param self The usual GAP first parameter
/// @param M The GAP matrix object 
/// @param fielddata The field data
/// @return The determinant of the matrix
extern "C"
Obj FuncDETERMINANT(Obj self, Obj M, Obj fielddata)
{
  return RunLinBoxFunction<DeterminantFunc>(M, fielddata);
}




//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////

/// Functor to calculate the trace of a matrix.
class TraceFunc
{
  public:
    /// The functor's function
    /// @param M The GAP matrix object 
    /// @param F An instance of the %LinBox field
    /// @param one The one of the field
    /// @return The trace of the object as a GAP object
    template<typename Field>
    Obj operator()(Obj M, Field& F, Obj one) const
    {
      auto_ptr<typename LBDenseMatrix<Field>::Type > A(LinBox_GAPMatrix(M, F));

      typename Field::Element tt;
      trace(tt, *A);

      return PROD(GAP_LinBoxInt(tt), one);
    }
};

/// GAP kernel C handler to calculate the trace of a matrix. This just calls 
/// RunLinBoxFunction() with the TraceFunc functor.
/// @param self The usual GAP first parameter
/// @param M The GAP matrix object 
/// @param fielddata The field data
/// @return The trace of the matrix
extern "C"
Obj FuncTRACE(Obj self, Obj M, Obj fielddata)
{
  return RunLinBoxFunction<TraceFunc>(M, fielddata);
}

//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
#ifdef HAVE_LIBNTL

/// Functor to calculate the Smith Normal Form of a matrix.
class SmithFormFunc
{
  public:
    /// The functor's function
    /// @param M The GAP matrix object 
    /// @param F An instance of the %LinBox field
    /// @param one The one of the field
    /// @return A GAP matrix object with the Smith Normal Form of \a M
    template<typename Field>
    Obj operator()(Obj M, Field& F, Obj one) const
    {
      auto_ptr<typename LBDenseMatrix<Field>::Type > A(LinBox_GAPMatrix(M, F));
      typename LBDenseMatrix<Field>::Type S(F);
      
      smithForm(S, *A);

      return PROD(GAP_LinBoxMatrix<Field>(S), one);
    }
};

/// GAP kernel C handler to calculate the Smith Normal Form a matrix. This 
/// just calls RunLinBoxFunction() with the SmithFormFunc functor.
/// @param self The usual GAP first parameter
/// @param M The GAP matrix object 
/// @param fielddata The field data
/// @return A matrix which is \a M in Smith Normal Form. This will be a matrix
/// over the integers, and must be converted to finite field elements if 
/// necessary. 
extern "C"
Obj FuncSMITH_FORM(Obj self, Obj M, Obj fielddata)
{
  return RunLinBoxFunction<SmithFormFunc>(M, fielddata);
}
#else //HAVE_LIBNTL
extern "C"
Obj FuncSMITH_FORM(Obj self, Obj M, Obj fielddata)
{
  throw GAPLinBoxException("The linboxing package was compiled without NTL. Smith Normal Form is not available");
}
#endif //HAVE_LIBNTL
//////////////////////////////////////////////////////////////////////////////


/// Functor to calculate the solution of a matrix equation. 
/// If there is no solution to the equation, it returns a \c Fail object
class SolveFunc
{
  public:
    /// The functor's function. This calls an internal function to do 
    /// the actual solution, since the %LinBox function to call is different
    /// for the integers and finite fields.
    /// @param M The GAP matrix object 
    /// @param b The GAP vector object 
    /// @param F An instance of the %LinBox field
    /// @param one The one of the field
    /// @return The solution vector as a GAP object
    template<typename Field>
    Obj operator()(Obj M, Obj b, Field& F, Obj one)
    {
      try
      {
        auto_ptr<typename LBDenseMatrix<Field>::Type > AA(LinBox_GAPMatrixTransposed(M, F));
        auto_ptr<std::vector<typename Field::Element> > bb(LinBox_GAPVector<Field>(b));
    
        // Call a field-specific function to do the actual solution
        return PROD(Solve(*AA, *bb), one);
      }
      catch(...)
      {
        return Fail;
      }
    }
    
  private:
    /// The version for finite fields calls the standard LinBox::solve() function.
    Obj Solve(
      const LBDenseMatrix<LBFiniteField>::Type& M, 
      const std::vector<LBFiniteField::Element>& b) const
    {
      std::vector<LBFiniteField::Element> x(M.coldim());
    
      solve(x, M, b);
    
      return GAP_LinBoxVector<LBFiniteField>(x);
    }
    
    /// The version for integers calls a LinBox::solve() function that also
    /// returns a denominator, allowing the result to be a rational by 
    /// dividing the integer vector by this denominator.
    Obj Solve(
      const LBDenseMatrix<LBIntegers>::Type& M, 
      const std::vector<LBIntegers::Element>& b) const
    {
      std::vector<LBIntegers::Element> x(M.coldim());
      LBIntegers::Element d; // The denominator
     
      solve(x, d, M, b);
    
      Obj dd = GAP_LinBoxInt(d);
      Obj xx = GAP_LinBoxVector<LBIntegers>(x);
      
      if(Int_Element(d) == 1)
        return xx;
      else
      {
        // Divide each element in xx by dd
        for(Int i = 1; i <= LEN_PLIST(xx); i++)
        {
          Obj q = QUO(ELM_PLIST(xx, i), dd);
          SET_ELM_PLIST(xx, i, q);
          CHANGED_BAG(xx);
        }
        return xx;
      }
    } 
};

/// GAP kernel C handler to calculate the solution of a matrix equation xA = b 
/// (GAP matrices are row-major). This just calls RunLinBoxFunction() with the 
/// SolveFunc functor.
/// @param self The usual GAP first parameter
/// @param A The GAP matrix object 
/// @param b The GAP vector that is the result of xA
/// @param fielddata The field data
/// @return The vector x that solves xA=b, or Fail if there is no solution. The
/// vector returned will be a vector over the integers, and will need to be
/// converted into the appropriate finite field if necessary.
Obj FuncSOLVE(Obj self, Obj A, Obj b, Obj fielddata)
{
  return RunLinBoxFunction<SolveFunc>(A, b, fielddata);
}

//////////////////////////////////////////////////////////////////////////////







/*****************************************************************************
  LINBOXING - tests.cc
  Functions to help testing
  Paul Smith

  Copyright (C)  2007-2008
  Paul Smith
  National University of Ireland Galway

  This file is part of the linboxing GAP package. 
 
  The linboxing package is free software; you can redistribute it and/or 
  modify it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or (at your 
  option) any later version.
 
  The linboxing package is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY 
  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for 
  more details.
 
  You should have received a copy of the GNU General Public License along with 
  this program.  If not, see <http://www.gnu.org/licenses/>.
 
*****************************************************************************/


#include "convert.h"
#include "runfunc.h"

extern "C" 
{
  #include "linboxing.h"
}


using namespace std;
using namespace LinBox;


//////////////////////////////////////////////////////////////////////////////

/// Functor to test integer conversion.
class TestIntFunc
{
  public:
    /// The functor's function. This default one throws an exception - it 
    /// has been specialised for LBIntegers since those are all we want to test
    /// @param z Any GAP object 
    /// @param F An instance of the %LinBox field
    /// @param one The one of the field
    /// @return This function throws an exception, so never returns anything!
    template<typename Field>
    Obj operator()(Obj z, Field& F, Obj one) const
    {
      throw GAPLinBoxException("TestIntFunc only supports LBIntegers integers");
    }
    /// The functor's function
    /// @param z The GAP integer 
    /// @param F An instance of the %LinBox field
    /// @param one The one of the field
    /// @return The integer after conversion to %LinBox and back 
    Obj operator()(Obj z, LBIntegers& F, Obj one) const
    {
      LBIntegers::Element e = LinBox_GAPInt(z);
      return GAP_LinBoxInt(e);
    }
};

/// GAP kernel C handler to test integer conversion. 
/// This just calls RunLinBoxFunction() with the TestIntFunc functor.
/// @param self The standard GAP first parameter
/// @param z The GAP integer object
/// @param fielddata The field data
/// @return The integer after conversion to %LinBox and back 
extern "C"
Obj FuncLINBOX_TEST_INT_CONVERSION(Obj self, Obj z, Obj fielddata)
{
  return RunLinBoxFunction<TestIntFunc>(z, fielddata);
}


//////////////////////////////////////////////////////////////////////////////


/// Functor to test vector conversion.
class TestVectorFunc
{
  public:
    /// The functor's function
    /// @param v The GAP vector
    /// @param F An instance of the %LinBox field
    /// @param one The one of the field
    /// @return The vector after conversion to %LinBox and back 
    template<typename Field>
    Obj operator()(Obj v, Field& F, Obj one) const
    {
      auto_ptr<vector<typename Field::Element> > vect(LinBox_GAPVector<Field>(v));
      return PROD(GAP_LinBoxVector<Field>(*vect), one);
    }
};

/// GAP kernel C handler to test vector conversion. 
/// This just calls RunLinBoxFunction() with the TestVectorFunc functor.
/// @param self The standard GAP first parameter
/// @param v The GAP vector object 
/// @param fielddata The field data
/// @return The vector after conversion to %LinBox and back 
extern "C"
Obj FuncLINBOX_TEST_VECTOR_CONVERSION(Obj self, Obj v, Obj fielddata)
{
  return RunLinBoxFunction<TestVectorFunc>(v, fielddata);
}

//////////////////////////////////////////////////////////////////////////////


/// Functor to test matrix conversion.
class TestMatrixFunc
{
  public:
    /// The functor's function
    /// @param M The GAP matrix
    /// @param F An instance of the %LinBox field
    /// @param one The one of the field
    /// @return The matrix after conversion to %LinBox and back 
    template<typename Field>
    Obj operator()(Obj M, Field& F, Obj one) const
    {
      auto_ptr<typename LBDenseMatrix<Field>::Type > mat(LinBox_GAPMatrix<Field>(M, F));
      return PROD(GAP_LinBoxMatrix<Field>(*mat), one);
    }
};

/// GAP kernel C handler to test matrix conversion. 
/// This just calls RunLinBoxFunction() with the TestMatrixFunc functor.
/// @param self The standard GAP first parameter
/// @param M The GAP matrix object 
/// @param fielddata The field data
/// @return The matrix after conversion to %LinBox and back 
extern "C"
Obj FuncLINBOX_TEST_MATRIX_CONVERSION(Obj self, Obj M, Obj fielddata)
{
  return RunLinBoxFunction<TestMatrixFunc>(M, fielddata);
}



//////////////////////////////////////////////////////////////////////////////

