#   LINBOXING - ac_check_linbox_shared.m4
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

################################################################################
# Checks LinBox shared library
#####################################################
AC_DEFUN([AC_CHECK_LINBOX_SHARED],
[
  AC_REQUIRE([AC_FIND_LINBOX])

  AC_LANG_PUSH(C++)
  
  AC_MSG_CHECKING([for LinBox shared library])
  if test -r "$LINBOXLIBDIR/liblinbox.so"; then
    AC_MSG_RESULT([yes])
    shared=yes
  else
    if test -r "$LINBOXLIBDIR/liblinbox.dylib"; then
      AC_MSG_RESULT([yes])
      shared=yes
    else
      AC_MSG_RESULT([no])
      shared=no
    fi
  fi

  if test "x$shared" = "xno"; then
    echo ""
    echo "*******************************************************************"
    echo "  ERROR"
    echo ""
    echo "  The Linbox library is present, but the shared library cannot be"
    echo "  found. This is usually built by default: did you configure Linbox"
    echo "  with --disable-shared? If so, please don't!"
    echo ""
    echo "  See the package documentation for further details."
    echo "*******************************************************************"
    AC_MSG_ERROR([cannot find a LinBox shared library.])
  fi
])
