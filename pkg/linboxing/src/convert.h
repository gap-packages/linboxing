/*****************************************************************************
  LINBOX-GAP - convert.h
  C++ header file for GAP to LinBox data conversion
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
 
  $Id: convert.h 93 2008-01-31 14:07:52Z pas $

*****************************************************************************/

#ifndef LINBOXING_CONVERT_H
#define LINBOXING_CONVERT_H
#include "config-linboxing.h"

#include <exception>
#include <vector>

#include <linbox/field/modular.h>
#ifdef HAVE_LIBNTL
  #include <linbox/field/ntl-ZZ.h>
#endif
#include <linbox/field/PID-integer.h>
#include <linbox/blackbox/blas-blackbox.h>
//#include <linbox/blackbox/dense.h>

extern "C"
{
#ifdef CONFIG_H // Include GAP's config.h if we could find it
  #include <config.h>
#endif
#include <src/system.h>
#include <src/objects.h>
#include <src/gasman.h>
#include <src/plist.h>
#include <src/integer.h>
#include <src/gap.h>
#include <src/lists.h>

#include "linboxing.h"
} 

//////////////////////////////////////////////////////////////////////////////
/**
@file convert.h
This file contains functions to convert GAP objects to %LinBox objects and 
vice-versa.
**/
//////////////////////////////////////////////////////////////////////////////

///
/// Exception type for exceptions thrown by the linboxing kernel interface. 
/// It simply contains a message string
class GAPLinBoxException : public std::exception
{
    const static size_t max_message_length = 256; ///< The maximum message length
  public:
    /// Construct an exception from a message string
    GAPLinBoxException(const char* s) 
    {
      strncpy(_str, s, max_message_length); 
      _str[max_message_length-1] = 0;
    }
    /// Return the message
    virtual const char* what() const throw() 
    {
      return _str;
    }
    /// The required virtual destructor, which does nothing.
    virtual ~GAPLinBoxException() throw() {}
  private:
    char _str[max_message_length]; ///< The stored message string
};

//////////////////////////////////////////////////////////////////////////////

/**
@page implementation LinBox-GAP mappings
  
  @section mappings Datatype mappings
    
  The linboxing kernel module converts GAP matrices and vectors into C++ datatypes 
  in the %LinBox library, and then calculates the solution using %LinBox, before
  converting the result back into GAP objects. In this section we outline
  the C++ datatypes used to represent GAP objects.
    
  @subsection integers Integers
  Integers in GAP are represented in two different formats, depending
  on whether they are `small' or `large'. Small integers have absolute value 
  less than either \f$ 2^{28} \f$ or \f$ 2^{60} \f$ (depending on whether the 
  machine is 32- or 64-bit), while large integers are anything larger. Both 
  of these are converted into elements of the #LBIntegers type, which is
  a typedef for the %LinBox datatype \c PID_integer (which is itself a wrapper 
  for the GNU Multiprecision (GMP) integer type).

  @subsection FFE Finite field elements
  Finite field elements in GAP also have various different formats. 
  Vectors (and matrices) of fields of size of up to 256 have a very 
  efficient representation (in particular over GF(2), which is packed into 
  bits). Individual field elements of fields of up to size 65536 have a 
  different representation, while fields of size greater than 65536 are not well 
  supported. Elements over all of the GAP finite fields are converted into the 
  #LBFiniteField type, which is a typedef for the %LinBox datatype 
  \c Modular<uint32>, which represents each field element in 32-bits. 
      
  <b>This means that matrices and vectors over finite fields will usually take 
  much more memory in %LinBox than in GAP</b>. Future versions of the %LinBox
  package will most likely use a smaller datatype for small fields, but %LinBox 
  does not provide a compressed datatype for fields of size less than 256, so 
  for small fields, GAP will always be more memory-efficient.
    
  @subsection vectors Vectors
  Vectors in GAP are represented using a dense list of elements over
  a single field. The %LinBox library stores vectors using the C++
  Standard Template Library's \c vector template class, and GAP vectors are 
  converted into these.
    
  @subsection matrics Matrices
  Matrices in GAP are represented by a dense list of dense lists, with all
  elements over a single field. The %LinBox library provides various
  different matrix types. Since we expect to be using dense matrices
  and BLAS elimination routines, GAP matrices are converted into the 
  #LBDenseMatrix type, which is a wrapper for the \c BlasBlackbox template 
  class.
  
  Once GAP supports sparse matrix types, a future version of this package
  could convert those into a %LinBox sparse matrix type. It should 
  be possible to treat GAP matrices directly as a `black box' without
  copying their data. This could also be done for dense matrices, giving 
  a saving of memory at the likely expense of speed.
    
  @section function_mappings Function mappings
    
  Each of the functions provided in the linboxing package maps directly
  onto a function provided in the \c solutions directory of the 
  %LinBox library. The table below gives the %LinBox solution that is called
  in each case. Each of the solutions has an optional `method' parameter, 
  which we usually leave blank, thus meaning that automaticaly %LinBox 
  selects which of its various methods to use, depending on the properties
  of the matrix.
      
  <TABLE>
    <TR>
      <TD>GAP command</TD>
      <TD>%LinBox function call</TD>
    </TR>
    <TR>
      <TD><TT>d := LinBox.Determinant(M)</TT></TD>
      <TD><TT>det(d, M)</TT></TD>
    </TR>
    <TR>
      <TD><TT>r := LinBox.Rank(M)</TT></TD>
      <TD><TT>rank(r, M, Method::BlasElimination())</TT></TD>
    </TR>
    <TR>
      <TD><TT>t := LinBox.Trace</TT></TD>
      <TD><TT>trace(t, M)</TT></TD>
    </TR>
    <TR>
      <TD><TT>x := LinBox.SolutionMat(A, b)</TT> (finite fields)</TD>
      <TD><TT>solve(x, A, b)</TT></TD>
    </TR>
    <TR>
      <TD><TT>x := LinBox.SolutionMat(A, b)</TT> (integers)</TD>
      <TD><TT>solve(xd, d, A, b)</TT> with <TT>x=xd/d</TT></TD>
    </TR>
  </TABLE>
**/
//////////////////////////////////////////////////////////////////////////////


/// The %LinBox type that we use for finite fields is typedefed in case we 
/// later want to change it
#ifndef LINBOX_VERSION_1_2
typedef LinBox::Modular<LinBox::uint32> LBFiniteField;
#else 
typedef LinBox::Modular<uint32_t> LBFiniteField;
#endif

/// The %LinBox type that we use for integers is typedefed in case we 
/// later want to change it
typedef LinBox::PID_integer LBIntegers;

/// The %LinBox type that we use for matrices is typedefed in case we 
/// later want to change it. This has to be done as a subtype of
/// a class/struct since C++ doesn't currently do template typedefs
template<typename Field>
struct LBDenseMatrix
{
  typedef LinBox::BlasBlackbox<Field> Type; ///< The actual typedef
//  typedef LinBox::DenseMatrix<Field> Type; ///< The actual typedef
};


//////////////////////////////////////////////////////////////////////////////

/// Convert an element from #LBFiniteField into an integer of the GAP kernel 
/// \c Int type.
inline Int Int_Element(const LBFiniteField::Element& m)
{
  return Int(m);
}

//////////////////////////////////////////////////////////////////////////////


/// Convert an integer (of the GAP kernel \c Int type) into an element
/// from PID_Integer
inline LinBox::PID_integer::Element LBInteger_Int(Int i)
{
  return LinBox::PID_integer::Element(i);
}

/// Convert an element from PID_Integer into an integer of the GAP kernel 
/// \c Int type.
inline Int Int_Element(const LinBox::PID_integer::Element& z)
{
  return Int(z);
}

/// Raise an element \a z from #LBIntegers to the exponent \a e, 
/// i.e. \c pow(z, e)
inline LinBox::PID_integer::Element LBIntegerPow(
  const LinBox::PID_integer::Element& z, Int e)
{
  return pow(z, e);
}

//////////////////////////////////////////////////////////////////////////////
#ifdef HAVE_LIBNTL

/// Convert an integer (of the GAP kernel \c Int type) into an element
/// from NTL_ZZ
/*
inline LinBox::NTL_ZZ::Element LBInteger_Int(Int i)
{
  return NTL::to_ZZ(i);
}
*/
/// Convert an element from #LBIntegers into an integer of the GAP kernel 
/// \c Int type.
inline Int Int_Element(const LinBox::NTL_ZZ::Element& z)
{
  return NTL::to_ulong(z);
}

/// Raise an element \a z from #LBIntegers to the exponent \a e, 
/// i.e. \c pow(z, e)
inline LinBox::NTL_ZZ::Element LBIntegerPow(const LinBox::NTL_ZZ::Element& z, Int e)
{
  return NTL::power(z, e);
}

#endif //HAVE_LIBNTL
//////////////////////////////////////////////////////////////////////////////

// Forward declaration of functions defined in convert.cc

LBIntegers::Element LinBox_GAPInt(Obj z);
Obj GAP_LinBoxInt(const LBIntegers::Element& e);
Obj GAP_LinBoxInt(const LBFiniteField::Element& e);


//////////////////////////////////////////////////////////////////////////////


/// Generic functor class for converting any GAP field element to a %LinBox 
/// field element. This general template version is simply provided to
/// catch errors and should never be called: if it does, it will throw an 
/// exceptions. Conversion is handled by specialisations of this functor class.
template<typename Field>
class LinBox_GAPConvertFunctor
{
  public:
    /// Convert the GAP object \a obj into a field element
    /// This generic instance catches the unhandled cases and throws an exception
    typename Field::Element operator()(Obj obj)
    {
      throw GAPLinBoxException("Unhandled field type in GAP->LinBox element conversion");
    }
};

/// Specialisation of the LinBox_GAPConvertFunctor functor class for converting 
/// a GAP object to a %LinBox integer 
template<>
class LinBox_GAPConvertFunctor<LBIntegers>
{
  public:
    /// Convert the GAP object \a obj into %LinBox integer element. This
    /// does not check that the object is an integer.
    /// @param obj The object to convert
    /// @returns The corresponding %LinBox integer element
    LBIntegers::Element operator()(Obj obj)
    {
      return LBIntegers::Element(LinBox_GAPInt(obj));
    }
};

/// Specialisation of the LinBox_GAPConvertFunctor functor class for converting 
/// a GAP object to a %LinBox finite field element 
template<>
class LinBox_GAPConvertFunctor<LBFiniteField>
{
  public:
    /// Convert the GAP object \a obj into %LinBox finite field element. This
    /// does not check that the object is finite field.
    /// @param obj The object to convert
    /// @returns The corresponding %LinBox finite field element
    LBFiniteField::Element operator()(Obj obj)
    {
      return LBFiniteField::Element(INT_INTOBJ(IntObj_FFEObj(obj)));
    }
};

//////////////////////////////////////////////////////////////////////////////

/// Generic functor class for converting any %LinBox field element to a GAP 
/// field element. This general template version is simply provided to
/// catch errors and should never be called: if it does, it will throw an 
/// exceptions. Conversion is handled by specialisations of this functor class.
template<typename Field>
class GAP_LinBoxConvertFunctor
{
  public:
    /// Convert the %LinBox object \a e into a field element
    /// This generic instance catches the unhandled cases and throws an exception
    Obj operator()(typename Field::Element e)
    {
      throw GAPLinBoxException("Unhandled field type in LinBox->GAP element conversion");
    }
};

/// Specialisation of the GAP_LinBoxConvertFunctor functor class for converting 
/// a %LinBox integer to a GAP object
template<>
class GAP_LinBoxConvertFunctor<LBIntegers>
{
  public:
    /// Convert the %LinBox integer element \a e into a GAP object
    /// @param e The object to convert
    /// @returns The corresponding %LinBox integer element
    Obj operator()(LBIntegers::Element e)
    {
      return GAP_LinBoxInt(e);
    }
};

/// Specialisation of the GAP_LinBoxConvertFunctor functor class for converting 
/// a %LinBox finite field element to a GAP object
template<>
class GAP_LinBoxConvertFunctor<LBFiniteField>
{
  public:
    /// Convert the %LinBox finite field element \a e into a GAP \b integer object.
    /// This need to be multuplied by \c One(Field) in GAP to generate a finite
    /// field element.
    /// @param e The object to convert
    /// @returns The corresponding %LinBox integer element
    Obj operator()(LBFiniteField::Element e)
    {
      return INTOBJ_INT(Int(e));
    }
};


//////////////////////////////////////////////////////////////////////////////


/// Convert a GAP list to an STL \c vector of elements over the field \a Field.
/// The elements are converted using the appropriate LinBox_GAPConvertFunctor,
/// which must therefore exist for this field.
/// This vector is allocated using \c new and must be destroyed with \c delete.
/// @param V The GAP list object (which can be any list type known to GAP)
/// @returns A pointer to an STL \c vector copy of \a V
template<typename Field>
std::vector<typename Field::Element>* LinBox_GAPVector(Obj V)
{
  int n = LEN_LIST(V);
  std::vector<typename Field::Element>* v = new std::vector<typename Field::Element>;
  v->reserve(n);
  LinBox_GAPConvertFunctor<Field> convert;
  for(Int i=0; i < n; i++)
  {
    typename Field::Element e = convert(ELM_LIST(V, i+1));
    v->push_back(e);
  }
  return v;
}

/// Convert an STL \c vector of elements over the field \a Field into a GAP list.
/// The elements are converted using the appropriate GAP_LinBoxConvertFunctor,
/// which must therefore exist for this field.
/// @param v The STL vector to convert
/// @returns A newly-allocated GAP list object containing a copy of \a v
template<typename Field>
Obj GAP_LinBoxVector(const std::vector<typename Field::Element>& v)
{
  Int n = v.size();
  Obj vect = NEW_PLIST(T_PLIST_HOM, n);
  SET_LEN_PLIST(vect, n);
  Int p = 1;
  GAP_LinBoxConvertFunctor<Field> convert;
  for(typename std::vector<typename Field::Element>::const_iterator i = v.begin(); 
    i != v.end(); i++, p++)
  {
    Obj obj = convert(*i);
    SET_ELM_PLIST(vect, p, obj);
    CHANGED_BAG(vect);
  }
  return vect;
}



//////////////////////////////////////////////////////////////////////////////


/// Convert a GAP matrix to a %LinBox matrix over the elements of \a Field.
/// The elements are converted using the appropriate LinBox_GAPConvertFunctor,
/// which must therefore exist for this field.
/// This vector is allocated using \c new and must be destroyed with \c delete.
/// @param M The GAP matrix object (as a list of lists)
/// @param F An instance of the field
/// @returns A %LinBox matrix with a copy of M
template<typename Field>
typename LBDenseMatrix<Field>::Type* LinBox_GAPMatrix(Obj M, Field& F)
{
  int nrows = LEN_LIST(M);
  int ncols = LEN_LIST(ELM_LIST(M,1));
  typename LBDenseMatrix<Field>::Type* A = 
    new typename LBDenseMatrix<Field>::Type(F, nrows, ncols); 
  LinBox_GAPConvertFunctor<Field> convert;
  for(Int r=0; r < nrows; r++)
  {
    Obj row = ELM_LIST(M, r+1);
    for(Int c=0; c < ncols; c++) 
    {
      typename Field::Element e = convert(ELM_LIST(row, c+1));
      A->setEntry(r, c, e);
    }
  }
  return A;
}

/// Convert the transpose of a GAP matrix to a %LinBox matrix over the elements 
/// of \a Field. This is needed in cases where GAP assumes that matrices
/// are row-major while %LinBox assumes they are column-major, such as in
/// \c SolutionMat/solve().
/// The elements are converted using the appropriate LinBox_GAPConvertFunctor,
/// which must therefore exist for this field.
/// This vector is allocated using \c new and must be destroyed with \c delete.
/// @param M The GAP matrix object (as a list of lists)
/// @param F An instance of the field
/// @returns A %LinBox matrix with a copy of M
template<typename Field>
typename LBDenseMatrix<Field>::Type* LinBox_GAPMatrixTransposed(Obj M, Field& F)
{
  int nrows = LEN_LIST(M);
  int ncols = LEN_LIST(ELM_LIST(M,1));
  typename LBDenseMatrix<Field>::Type* A = 
    new typename LBDenseMatrix<Field>::Type(F, ncols, nrows); 
  LinBox_GAPConvertFunctor<Field> convert;
  for(Int r=0; r < nrows; r++)
  {
    Obj row = ELM_LIST(M, r+1);
    for(Int c=0; c < ncols; c++) 
    {
      typename Field::Element e = convert(ELM_LIST(row, c+1));
      A->setEntry(c, r, e);
    }
  }
  return A;
}

/// Convert a %LinBox matrix over the elements of \a Fieldto a GAP matrix.
/// The elements are converted using the appropriate GAP_LinBoxConvertFunctor,
/// which must therefore exist for this field.
/// @param M The %LinBox matrix object to convert
/// @returns A GAP matrix with a copy of M
template<typename Field>
Obj GAP_LinBoxMatrix(const typename LBDenseMatrix<Field>::Type& M)
{
  GAP_LinBoxConvertFunctor<Field> convert;
  Int cols = M.coldim();
  Int rows = M.rowdim();
  Obj mat = NEW_PLIST(T_PLIST_HOM, rows);
  SET_LEN_PLIST(mat, rows);
  for(Int r = 0; r < rows; r++)
  {
    // Create this new row
    Obj row = NEW_PLIST(T_PLIST_HOM, cols);
    SET_LEN_PLIST(row, cols);
    // And add it to the matrix
    SET_ELM_PLIST(mat, r+1, row);
    CHANGED_BAG(mat);
    // Now fill in the elements
    for(Int c = 0; c < cols; c++)
    {
      Obj obj = convert(M.getEntry(r, c));
      SET_ELM_PLIST(row, c+1, obj);
      CHANGED_BAG(row);
    }
  }
  return mat;
}

//////////////////////////////////////////////////////////////////////////////


#endif // #define GAP_LINBOX_CONVERT_H
