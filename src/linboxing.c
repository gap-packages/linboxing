/*****************************************************************************
  LINBOXING - linboxing.c
  C interface between GAP and the linboxfuncs C++ file
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
@file linboxing.c
This file contains all of the pure C code that deals with GAP.
**/
//////////////////////////////////////////////////////////////////////////////
/**
@mainpage

The %LinBox C++ library (http://www.linalg.org) performs exact linear algebra 
and provides a set of routines for the solution of linear algebra problems such 
as rank, determinant, and the solution of linear systems. It provides 
representations for both sparse and dense matrices over integers and
finite fields. It has a particular emphasis on black-box matrix methods
(which are very efficient over sparse matrices), but increasingly also 
provides elimination-based routines for dense matrices using the 
industry-standard BLAS numeric routines.

GAP (http://www.gap-system.org) is a system for computational discrete algebra,
with a particular emphasis on computational group theory. It provides a 
programming language and a number of libraries, and includes functions for
defining vectors and matrices and performing exact linear algebra. However,
since linear algebra is not the main focus of GAP, the routines in the %LinBox
library are often faster.

The linboxing GAP package provides an interface to the %LinBox C++
library. It provides alternative versions of GAP linear algebra routines
which are mapped through to the equivalent %LinBox library routines
at the GAP kernel level. The result is linear algebra routines in GAP
that are, in many cases, considerably faster than the native GAP versions.
As is typical, this speed is at the expense of memory, since the GAP 
matrices and vector must be copied into the equivalent %LinBox matrices and 
vectors.

This documentation covers the C and C++ source for the linboxing kernel 
module. Documentation for the GAP part of this package, which includes 
instructions for installation, can be found in the \c doc directory of this 
package.

An introduction to the GAP-LinBox mappings can be found 
\ref implementation "here".
**/
//////////////////////////////////////////////////////////////////////////////

#include <string.h>

#ifdef CONFIG_H
  #include <config.h>  /* Include GAP's config.h if we could find it */
#endif
#include <src/compiled.h>

#include "linboxing.h"

/******************** Helper functions ***************/

/** 
Stores the GAP object that is the function \c INTFFR() so that we can
call it to convert field elements to integers.
*/
static Obj GF_IntFFE;

/**
Convert a GAP finite field element object to a GAP integer object. This
simply calls the GAP function \c INTFFE().
*/
Obj IntObj_FFEObj(Obj o)
{
  return CALL_1ARGS(GF_IntFFE, o);
}

/**
Print a GAP error message. This is called from the exception handlers,
and shouldn't cause any further memory allocation (except maybe in GAP - 
depending on how \c ErrorMayQuit works. The message 
printed is <tt>type: message</tt> unless \a type is empty, in which 
case just \a message is printed.
@param type The type of the error (e.g. %LinBox or system)
@param message The message, usually as reported by \c e.what()
**/
void PrintGAPError(const char* type, const char* message)
{
  static const size_t max_error = 256;
  char mess[max_error];
  if(type[0] != 0)
  {
    snprintf(mess, max_error, "%s: %s", type, message);
    mess[max_error-1] = 0;
    ErrorMayQuit(mess, 0L, 0L);
  }
  else
    ErrorMayQuit(message, 0L, 0L);
}


/***************** Functions to be called directly from GAP ***************/

/** 
GAP kernel C function to report what this kernel module thinks the size of a 
small integer is. This is used for testing
@param self The standard GAP first parameter
@return The maximum small integer (according to this kernel module).
**/
Obj FuncLINBOX_MAX_SMALL_INT(Obj self)
{
  return MaxGAPSmallInt();
}


/******************** The inteface to GAP ***************/


/**
Details of the functions to make available to GAP. 
This is used in InitKernel() and InitLibrary()
*/
static StructGVarFunc GVarFuncs[] = 
{
  {"RANK",             /* GAP function name */
   2,                  /* Number of parameters */
   "M, fielddata",     /* String for GAP to display list of parameter names */
   FuncRANK,           /* C function to call */
   "linboxfuncs.cc:FuncRANK" /* String to display function location */
  }, 

  {"DETERMINANT",
   2,                    
   "M, fielddata",       
   FuncDETERMINANT, 
   "linboxfuncs.cc:FuncDETERMINANT"
  }, 

  {"TRACE",
   2,                    
   "M, fielddata",       
   FuncTRACE, 
   "linboxfuncs.cc:FuncTRACE"
  }, 

  {"SOLVE",
   3,                    
   "M, b, fielddata",       
   FuncSOLVE, 
   "linboxfuncs.cc:FuncSOLVE"
  }, 

  {"SMITH_FORM",
   2,                    
   "M, fielddata",       
   FuncSMITH_FORM, 
   "linboxfuncs.cc:FuncSMITH_FORM"
  }, 

  {"SetMessages", 
   1,
   "on",
   FuncSET_LINBOX_MESSAGES, 
   "linboxfuncs.cc:FuncSET_LINBOX_MESSAGES" 
  }, 

  {"MAX_GAP_SMALL_INT", 
   0,
   "",
   FuncLINBOX_MAX_SMALL_INT, 
   "linboxing.c:FuncLINBOX_MAX_SMALL_INT" 
  }, 

  {"TEST_INT_CONVERSION_INTERNAL", 
   2,
   "z, fielddata",
   FuncLINBOX_TEST_INT_CONVERSION, 
   "linboxfuncs.cc:FuncTEST_INT_CONVERSION" 
  }, 

  {"TEST_VECTOR_CONVERSION_INTERNAL", 
   2,
   "v, fielddata",
   FuncLINBOX_TEST_VECTOR_CONVERSION, 
   "linboxfuncs.cc:FuncTEST_VECTOR_CONVERSION" 
  }, 

  {"TEST_MATRIX_CONVERSION_INTERNAL", 
   2,
   "M, fielddata",
   FuncLINBOX_TEST_MATRIX_CONVERSION, 
   "linboxfuncs.cc:FuncTEST_MATRIX_CONVERSION" 
  }, 

  { 0 } /* Finish with an empty entry */
};



/** 
Function called by GAP after a workspace restore. This is also called by us in
InitLibrary();
**/ 
static Int PostRestore(StructInitInfo* module)
{
  Int i;
  Int gvar;
  Obj tmp;
  
  gvar = GVarName("LinBox");
  tmp = (Obj)VAL_GVAR(gvar);
  if(!tmp) 
  {
    tmp = (Obj)NEW_PREC(0);
  }

  /* Write the names of my functions into th LinBox record */
  for(i = 0; GVarFuncs[i].name != 0; i++) 
  {
    AssPRec(
      tmp, 
      RNamName((Char*)GVarFuncs[i].name), 
      NewFunctionC(
        GVarFuncs[i].name, 
        GVarFuncs[i].nargs, 
        GVarFuncs[i].args, 
        GVarFuncs[i].handler) );
  }
  
  MakeReadWriteGVar(gvar);
  AssGVar(gvar, tmp);
  MakeReadOnlyGVar(gvar);
  return 0;
}


/**
The first function to be called when the library is loaded by the kernel.
**/
static Int InitKernel(StructInitInfo* module)
{
  /* init filters and functions                                          */
  InitHdlrFuncsFromTable( GVarFuncs );
  InitFopyGVar( "IntFFE", &GF_IntFFE );
  
  /* return success                                                      */
  return 0;
}


/**
The second function to be called when the library is loaded by the kernel.
**/
static Int InitLibrary(StructInitInfo* module)
{
    PostRestore( module );

    /* return success                                                      */
    return 0;
}


/**
Information about this library, returned when the library is loaded, 
for example by Init__Dynamic(). This contains details of the library name,
and the further initialisation functions to call.
**/
static StructInitInfo module = {
#ifdef STATICMODULE
 /* type        = */ MODULE_STATIC,
#else
 /* type        = */ MODULE_DYNAMIC,
#endif
 /* name        = */ "simple LinBox interface",
 /* revision_c  = */ 0,
 /* revision_h  = */ 0,
 /* version     = */ 0,
 /* crc         = */ 0,
 /* initKernel  = */ InitKernel,
 /* initLibrary = */ InitLibrary,
 /* checkInit   = */ 0,
 /* preSave     = */ 0,
 /* postSave    = */ 0,
 /* postRestore = */ PostRestore
};


#ifndef STATICGAP
/** 
Function called by GAP as soon as the library is dynamically loaded. 
This returns the StructInitInfo data for this library
**/
StructInitInfo * Init__Dynamic (void)
{
 return &module;
}
#endif
StructInitInfo * Init__linbox(void)
{
  return &module;
}

