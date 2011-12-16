#   LINBOXING - ac_check_linbox_version_and_shared.m4
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
#   $Id: ac_check_linbox_exceptions_and_shared.m4 90 2008-01-29 15:10:15Z pas $

################################################################################
# Checks LinBox version and for a shared library
#####################################################
AC_DEFUN([AC_CHECK_LINBOX_VERSION_AND_SHARED],
[
  AC_REQUIRE([AC_FIND_LINBOX])

  AC_LANG_PUSH(C++)
  
  OLD_CPPFLAGS=$CPPFLAGS
  OLD_LIBS=$LIBS
  CPPFLAGS="$CPPFLAGS $LINBOX_CPPFLAGS"
  LIBS=""
  
  # Check that we have the Linbox config.h configuration file 
  AC_CHECK_HEADERS([linbox/linbox-config.h], , 
    [
      echo ""
      echo "********************************************************************"
      echo "  ERROR"
      echo ""
      echo "  The LinBox library appears to be installed, but the header file"
      echo "  linbox-config.h does not appear to be present. Please check your "
      echo "  LinBox installation."
      echo "********************************************************************"
      echo ""
      AC_MSG_ERROR([Cannot find the LinBox configuration file.])
    ])
  
  # Now read the version number from this file and check that it is OK
  LINBOX_MIN_VERSION=1.1.5
  AC_MSG_CHECKING([for LinBox version >= $LINBOX_MIN_VERSION]);
  AC_RUN_IFELSE([AC_LANG_PROGRAM([[
    #include <sstream> 
    #include <iostream> 
    #include <linbox/linbox-config.h>
  ]],
  [[
    std::string str(__LINBOX_VERSION);
    std::istringstream stm(str);
    
    std::string minstr("$LINBOX_MIN_VERSION");
    std::istringstream minstm(minstr);
    
    do
    {
      std::string s; 
      getline(stm, s, '.');
      std::string mins;
      getline(minstm, mins, '.');
      //std::cout << "Version " << s << ", desired " << mins << std::endl;
      if(s > mins)  // If greater then we are OK
        return 0;
      else if(s < mins) // If less then oops!
        return -1;
      // Otherwise we move onto the minor version number and so on
    }
    while(minstm.good());
  
    return 0;
  ]])], [versionok=yes], [versionok=no])

  if test "x$versionok" = "xyes"; then
    AC_MSG_RESULT([yes])
  else
    AC_MSG_RESULT([no])
    echo ""
    echo "*********************************************************************"
    echo "  ERROR"
    echo ""
    echo "  The Linbox library is present, but it is an old version (earlier"
    echo "  than 1.1.5).  Please download a more recent version from "
    echo "  http://www.linalg.org"
    echo "*********************************************************************"
    echo ""
    AC_MSG_ERROR([LinBox version is incompatible.])
  fi

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

  CPPFLAGS=$OLD_CPPFLAGS
  LIBS=$OLD_LIBS
  AC_LANG_POP(C++)
])
