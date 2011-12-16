#   LINBOXING - configure.ac
#   Input file for configure
#   Paul Smith
# 
#   Copyright (C)  2007-2008
#   Paul Smith
#   National University of Ireland Galway
# 
#   This file is part of the linboxing GAP package. 
#  
#   The linboxing package is free software; you can redistribute it and/or 
#   modify it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or (at your 
#   option) any later version.
#  
#   The linboxing package is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY 
#   or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for 
#   more details.
#  
#   You should have received a copy of the GNU General Public License along with 
#   this program.  If not, see <http://www.gnu.org/licenses/>.
#  
#   $Id: configure.ac 100 2008-04-22 13:10:18Z pas $


AC_INIT([linboxing], 0.5.1)
AC_CONFIG_SRCDIR([src/linboxing.h])
AM_INIT_AUTOMAKE([foreign])

AC_PREFIX_DEFAULT([${PWD}/src])

AC_PROG_CXX
AC_PROG_CC

## Find out what the best compiler flags are
AX_CC_MAXOPT

## 
if test "$ac_test_CXXFLAGS" != "set"; then
  AC_LANG_PUSH(C++)
  CXXFLAGS=$CFLAGS
  AX_CHECK_COMPILER_FLAGS($CXXFLAGS, [], [
  echo ""
  echo "-----------------------------------------------------------------------"
  echo "  WARNING: The guessed best CXXFLAGS were copied from CFLAGS but don't"
  echo "  seem to work with your C++ compiler. Use ./configure CXXFLAGS=...  to"
  echo "  specify your own flags, otherwise the default (slow) compiler"
  echo "  optimisation settings will be used."
  echo "-----------------------------------------------------------------------"
  echo ""
  CXXFLAGS=""
  ])
  AC_LANG_POP(C++)
fi

AC_LIBTOOL_DLOPEN
AC_DISABLE_STATIC
AC_PROG_LIBTOOL

AC_FIND_GMP
AC_FIND_BLAS_AND_LAPACK
AC_FIND_LINBOX
AC_CHECK_LINBOX_VERSION_AND_SHARED
AC_FIND_GAP

AC_CONFIG_FILES([Makefile src/Makefile])
AC_OUTPUT
