#   LINBOXING - ac_find_gmp.m4
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
#   $Id: ac_find_gmp.m4 104 2008-04-23 16:28:53Z pas $

################################################################################
# Checks GMP and sets GMP_LDFLAGS, GMP_LIBS and GMP_CPPFLAGS accordingly. 
#####################################################
AC_DEFUN([AC_FIND_GMP],
[
  # Make sure CDPATH is portably set to a sensible value
  CDPATH=${ZSH_VERSION+.}:
  
  AC_LANG_PUSH(C)
  #
  #Allow the user to specify the location of GMP
  #
  AC_ARG_WITH(gmpprefix,
    [AC_HELP_STRING([--with-gmpprefix=<path>], [specify prefix to which GMP was installed])],
    [GMPDIR=$withval])

  OLD_LIBS=$LIBS

  GMP_LIBS=""
  GMP_LDFLAGS=""
  GMP_CPPFLAGS=""

  # If the user has provided a gmp directory, then add that to LIBS
  if test -n "$GMPDIR"; then
    # Convert the path to absolute
    GMPDIR=`cd $GMPDIR > /dev/null 2>&1 && pwd`
    GMP_LDFLAGS="-L$GMPDIR/lib"
    GMP_CPPFLAGS="-I$GMPDIR/include"
    LDFLAGS="$LDFLAGS $GMP_LDFLAGS"
  fi

  # see if we can find it
  AC_CHECK_LIB(gmp, main, [GMP_LIBS="-lgmp"],
  [
    echo ""
    echo "*********************************************************************"
    echo "  ERROR"
    echo ""
    echo "  Cannot find or use the GNU Multiprecision (GMP) library. Please"
    echo "  specify the install prefix to which GMP was installed using."
    echo "  --with-gmpprefix=<path>. "
    echo "  The header files should be at $prefix/include and the library in"
    echo "  $prefix/lib"
    echo "*********************************************************************"
    echo ""
    
    AC_MSG_ERROR([Cannot find GMP library])
  ])

  AC_SUBST(GMP_CPPFLAGS)
  AC_SUBST(GMP_LDFLAGS)
  AC_SUBST(GMP_LIBS)
  
  LIBS=$OLDLIBS

  AC_LANG_POP(C)
])
