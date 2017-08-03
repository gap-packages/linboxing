#   LINBOXING - ac_find_linbox.m4
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
#   $Id: ac_find_linbox.m4 101 2008-04-22 15:08:20Z pas $

################################################################################
# Checks LinBox and sets LINBOX_CPPFLAGS and LINBOX_LIBS
#####################################################
AC_DEFUN([AC_FIND_LINBOX],
[
  # Make sure CDPATH is portably set to a sensible value
  CDPATH=${ZSH_VERSION+.}:
  
  AC_LANG_PUSH(C++)
  
  AC_REQUIRE([AC_FIND_GMP])
  AC_REQUIRE([LB_CHECK_BLAS])
  AC_REQUIRE([LB_CHECK_GIVARO])
  
  #
  #Allow the user to specify the location of LinBox
  #
  AC_ARG_WITH(linboxprefix, 
    [AC_HELP_STRING([--with-linboxprefix=<path>], [specify prefix to which LinBox was installed])],
    [LINBOXDIR=$withval])

  OLD_LIBS=$LIBS
  OLD_LDFLAGS=$LDFLAGS
  OLD_CPPFLAGS=$CPPFLAGS
  CPPFLAGS="$CBLAS_FLAG $GIVARO_CFLAGS $GMP_CPPFLAGS"
  LDFLAGS=$GMP_LDFLAGS
  LIBS="$BLAS_LIBS $GIVARO_LIBS $GMP_LIBS"

  # If the user has provided a linbox directory, check that location
  if test -n "$LINBOXDIR"; then
    # Convert the path to absolute
    LINBOXDIR=`cd $LINBOXDIR > /dev/null 2>&1 && pwd`
    LINBOXLIBDIR=$LINBOXDIR/lib
    if test -r "$LINBOXLIBDIR/liblinbox.la"; then
      LINBOX_CPPFLAGS="-I${LINBOXDIR}/include"
      LINBOX_LDFLAGS="-L${LINBOXDIR}/lib"
      LDFLAGS="$LDFLAGS $LINBOX_LDFLAGS"
      CPPFLAGS="$CPPFLAGS $LINBOX_CPPFLAGS"
    else
      echo ""
      echo "********************************************************************"
      echo "  ERROR"
      echo ""
      echo "  Cannot find the LinBox libtool library liblinbox.la at the"
      echo "  location $LINBOXLIBDIR."
      echo "  Please specify the install prefix to which LinBox was installed "
      echo "  by using"
      echo "    --with-linboxprefix=<prefix>."
      echo "  The header files should be at <prefix>/include and the library in"
      echo "  <prefix>/lib"
      echo "**********************************************************************"
      echo ""
    
      AC_MSG_ERROR([Cannot find LinBox library at specified location.])
    fi
  else
    AC_MSG_CHECKING([for LinBox location])
    # If not, check the standard likely locations
    LINBOX_PATHS="/usr/lib /usr/lib64 /usr/local/lib /usr/local/lib64"
    for LINBOXLIBDIR in ${LINBOX_PATHS} 
    do  
      # Convert the path to absolute
      LINBOXLIBDIR=`cd $LINBOXLIBDIR > /dev/null 2>&1 && pwd`
      if test -r "$LINBOXLIBDIR/liblinbox.la"; then
        break
      fi
      LINBOXLIBDIR="Not found"
    done
    AC_MSG_RESULT([${LINBOXLIBDIR}])
    
    if test "$LINBOXLIBDIR" = "Not found"; then
      echo ""
      echo "*******************************************************************"
      echo "  ERROR"
      echo ""
      echo "  Cannot find the LinBox libtool library liblinbox.la. Please"
      echo "  specify the install prefix to which LinBox was installed using"
      echo "  --with-linboxprefix=<prefix>. "
      echo "  The header files should be at <prefix>/include and the library in"
      echo "  <prefix>/lib"
      echo "*******************************************************************"
      echo ""
      AC_MSG_ERROR([Cannot find the LinBox library.])
    fi

    LINBOX_LDFLAGS="-R${LINBOXLIBDIR}"
  fi
    
  #Now check that it all works OK
  AC_CHECK_LIB(linbox, main, [LINBOX_LIBS="-llinbox"],
    [
      echo ""
      echo "********************************************************************"
      echo "  ERROR"
      echo ""
      echo "  Found the LinBox libtool library linbox.la at"
      echo "  ${LINBOXLIBDIR},"
      echo "  but cannot link with the libtool library. Please check your LinBox"
      echo "  installation."
      echo "********************************************************************"
      echo ""
      AC_MSG_ERROR([cannot link with LinBox library.])
    ])
    
  AC_CHECK_HEADERS([linbox/field/modular.h], , 
    [
      echo ""
      echo "********************************************************************"
      echo "  ERROR"
      echo ""
      echo "  Found the LinBox libtool library linbox.la at "
      echo "  ${LINBOXLIBDIR},"
      echo "  but cannot find the linbox header files. Please check your "
      echo "  LinBox installation."
      echo "********************************************************************"
      echo ""
      AC_MSG_ERROR([Cannot use LinBox header files.])
    ])

  AC_SUBST(LINBOX_CPPFLAGS)
  AC_SUBST(LINBOX_LIBS)
  AC_SUBST(LINBOX_LDFLAGS)
  
  LIBS=$OLD_LIBS
  LDFLAGS=$OLD_LDFLAGS
  CPPFLAGS=$OLD_CPPFLAGS
  
  AC_LANG_POP(C++)
])
