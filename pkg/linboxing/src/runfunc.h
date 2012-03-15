/*****************************************************************************
  LINBOXING - runfunc.h
  Template functions to run a general LinBox functor with the correct field
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
 
  $Id: runfunc.h 93 2008-01-31 14:07:52Z pas $

*****************************************************************************/

#ifndef LINBOXING_RUNFUNC_H
#define LINBOXING_RUNFUNC_H

#include <sstream>

extern "C" 
{
#include <src/scanner.h>
#include <src/precord.h>
}

#include <iostream>
//////////////////////////////////////////////////////////////////////////////


/// Template wrapper for %LinBox functions that takes one GAP object as input 
/// and whose solution is one GAP object. This function converts the last 
/// parameter, \a field, the field id, into the appropriate %LinBox field object 
/// and then calls the functor object \a FUNC with the other 
/// argument and an instance of the field object. The functor \a FUNC should 
/// read the GAP input object, call %LinBox functions to find the answer, and 
/// write it back into the GAP output object. See RankFunc for an example of a 
/// \c FUNC object taking one GAP object.
/// @param in The input GAP object
/// @param fielddata The GAP field data. This is a plain record with three 
/// entries: the first is the GAP field object , the second
/// is the field id, which is a number that if it is greater than 
/// zero, then it is the size of the finite field, otherwise the 'field' is 
/// taken to be the ring of the integers. The second entry is the GAP object 
/// that is the one of the field.
/// @param FUNC A functor object that takes
/// three arguments: \a in, and an object of a %LinBox field type, and the
/// GAP object that is the one of the field and returns a GAP object.
template<typename FUNC> 
Obj RunLinBoxFunction(Obj in, Obj fielddata)
{
  try
  {
    FUNC functor;
    Int q = INT_INTOBJ(ELM_PLIST(fielddata, 2));
    if(q > 0)
    {
      LBFiniteField F(q);
      return functor(in, F, ELM_PLIST(fielddata, 3));
    }
    else
    {
      LBIntegers F;
      return functor(in, F, ELM_PLIST(fielddata, 3));
    }
  }
  catch(GAPLinBoxException& e)
  {
    PrintGAPError("linboxing interface error:", e.what());
  }
  catch(std::exception& e)
  {
    PrintGAPError("", e.what());
  }
  catch(LinBox::LinboxError& e)
  {
    std::ostringstream str;
    str << e;
    PrintGAPError("LinBox error", str.str().c_str());
  }
  catch(...)
  {
    PrintGAPError("", "Unrecognised error in linboxing kernel module");
  }
  return Obj(0);
}



/// Template wrapper for %LinBox functions that take two GAP objects as input 
/// and whose solution is one GAP object. This function converts the last 
/// parameter, \a field, the field id, into the appropriate %LinBox field object 
/// and then calls the functor object \a FUNC with the rest of the
/// arguments and an instance of the field object. The functor \a FUNC should 
/// convert the GAP input objects to %LinBox objects (see GAP_LinBoxInt()
/// and its friends), call %LinBox functions to find the solution, and write it 
/// back into the GAP output object. See SolveFunc for an example of a \c FUNC 
/// object taking two GAP objects.
/// @param in1 The first input GAP object
/// @param in2 The second input GAP object
/// @param fielddata The GAP field data. This is a plain record with three 
/// entries: the first is the GAP field object , the second
/// is the field id, which is a number that if it is greater than 
/// the first is the field id, which is a number that if it is greater than 
/// zero, then it is the size of the finite field, otherwise the 'field' is 
/// taken to be the ring of the integers. The second entry is the GAP object 
/// that is the one of the field.
/// @param FUNC A functor object that takes
/// four arguments: \a in1, \a in2, and an object of a %LinBox field type, and 
/// the GAP object that is the one of the field and returns a GAP object.
template<typename FUNC> 
Obj RunLinBoxFunction(Obj in1, Obj in2, Obj fielddata)
{
  try
  {
    FUNC functor;
    Int q = INT_INTOBJ(ELM_PLIST(fielddata, 2));
    if(q > 0)
    {
      LBFiniteField F(q);
      return functor(in1, in2, F, ELM_PLIST(fielddata, 3));
    }
    else
    {
      LBIntegers F;
      return functor(in1, in2, F, ELM_PLIST(fielddata, 3));
    }
  }
  catch(GAPLinBoxException& e)
  {
    PrintGAPError("linboxing interface error:", e.what());
  }
  catch(std::exception& e)
  {
    PrintGAPError("", e.what());
  }
  catch(LinBox::LinboxError& e)
  {
    std::ostringstream str;
    str << e;
    PrintGAPError("LinBox error", str.str().c_str());
  }
  catch(...)
  {
    PrintGAPError("", "Unrecognised error in linboxing kernel module");
  }
  return Obj(0);
}

//////////////////////////////////////////////////////////////////////////////

#endif //#define LINBOXING_RUNFUNC_H

