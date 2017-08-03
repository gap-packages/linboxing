/*****************************************************************************
  LINBOXING - linboxing.h
  GAP to LinBox C++ header file
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
 
  $Id: linboxing.h 90 2008-01-29 15:10:15Z pas $

*****************************************************************************/

#ifndef LINBOXING_LINBOXING_H
#define LINBOXING_LINBOXING_H

//////////////////////////////////////////////////////////////////////////////
/**
@file linboxing.h
This file contains all of declarations for C++ functions that are to be 
called from C, or vice-versa.
**/
//////////////////////////////////////////////////////////////////////////////

//////////////// C++ functions to be called from C ////////////////////

// Solutions

Obj FuncRANK(Obj self, Obj M, Obj fieldsize);
Obj FuncDETERMINANT(Obj self, Obj M, Obj fieldsize);
Obj FuncTRACE(Obj self, Obj M, Obj fieldsize);
Obj FuncSOLVE(Obj self, Obj A, Obj b, Obj fieldsize);
Obj FuncSMITH_FORM(Obj self, Obj A, Obj fieldsize);


// Tests

Obj FuncLINBOX_TEST_INT_CONVERSION(Obj self, Obj z, Obj fieldsize);
Obj FuncLINBOX_TEST_VECTOR_CONVERSION(Obj self, Obj v, Obj fieldsize);
Obj FuncLINBOX_TEST_MATRIX_CONVERSION(Obj self, Obj v, Obj fieldsize);


// Misc

Obj FuncSET_LINBOX_MESSAGES(Obj self, Obj on);
Obj MaxGAPSmallInt();

//////////////// C functions to be called from C++ ////////////////////

Obj IntObj_FFEObj(Obj o);
void PrintGAPError(const char* type, const char* message);


#endif //#define LINBOXING_LINBOXING_H
