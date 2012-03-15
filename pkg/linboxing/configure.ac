#   LINBOXING - configure.ac
#   Input file for configure
#   Paul Smith
# 
#   Copyright (C)  2007-2008
#   National University of Ireland Galway
#   Copyright (C)  2011
#   University of St Andrews
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

AC_INIT([linboxing], 0.5.2)
AC_CONFIG_SRCDIR([src/linboxing.h])
AC_CONFIG_MACRO_DIR([m4])
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

AC_LANG_PUSH(C++)
DEFAULT_CHECKING_PATH="/usr /usr/local /usr"
LB_CHECK_GIVARO(,,[
echo '*******************************************************************************'
echo ' ERROR: GIVARO not found!'
echo
echo ' Please make sure GIVARO is installed and specify its location with the'
echo ' option --with-givaro=<prefix> when running configure.'
echo '*******************************************************************************'
exit 1
])
LB_CHECK_BLAS(,,[
echo ''
echo '*******************************************************************************'
echo ' ERROR: BLAS not found!'
echo
echo ' Please make sure BLAS is installed and specify its location with the option'
echo ' --with-blas=<lib> when running configure.'
echo '*******************************************************************************'
exit 1
])
AC_LANG_POP(C++)

AC_FIND_LINBOX
MIN_LINBOX_VERSION="1.1.6"
AC_CHECK_LINBOX_VERSION_AT_LEAST([$MIN_LINBOX_VERSION],, [
  echo ""
  echo "********************************************************************"
  echo "  ERROR"
  echo ""
  echo "  The linbox library must be must be version $MIN_LINBOX_VERSION or newer."
  echo ""
  echo "********************************************************************"
  echo ""
exit 1
])
AC_CHECK_LINBOX_VERSION_AT_LEAST(["1.2.0"], 
  [AC_DEFINE([LINBOX_VERSION_1_2], [] , [We have linbox version 1.2.0 or greater])
  echo ""
  echo "********************************************************************"
  echo "  ERROR"
  echo ""
  echo "  The linboxing package does not yet work with linbox version 1.2.0"
  echo "  or higher. Please use linbox versions 1.1.6 or 1.1.7"
  echo ""
  echo "********************************************************************"
  echo ""
exit 1
])
 
AC_CHECK_LINBOX_SHARED
AC_FIND_GAP

AC_CONFIG_FILES([Makefile src/Makefile])
AC_CONFIG_HEADERS([src/config-linboxing.h])
AC_OUTPUT
