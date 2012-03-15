#   LINBOXING - ac_check_linbox_version.m4
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
# Checks LinBox version 
#####################################################
AC_DEFUN([AC_CHECK_LINBOX_VERSION_AT_LEAST],
[
  AC_REQUIRE([AC_FIND_LINBOX])

  AC_LANG_PUSH(C++)

  OLD_CPPFLAGS=$CPPFLAGS
  OLD_LIBS=$LIBS
  CPPFLAGS="$CPPFLAGS $LINBOX_CPPFLAGS"
  LIBS=""

  ac_check_linbox_version=false

  # Check that we have the Linbox config.h configuration file 
  AC_CHECK_HEADERS([linbox/linbox-config.h], 
    [
    # What version are we looking for
    LINBOX_VERSION=$1

    AC_MSG_CHECKING([for LinBox version >= $LINBOX_VERSION])
    AC_RUN_IFELSE([AC_LANG_PROGRAM([[
      #include <sstream> 
      #include <iostream> 
      #include <linbox/linbox-config.h>
    ]],
    [[
      std::string str(__LINBOX_VERSION);
      std::istringstream stm(str);

      std::string minstr("$LINBOX_VERSION");
      std::istringstream minstm(minstr);

      do
      {
        std::string s; 
        getline(stm, s, '.');
        std::string mins;
        getline(minstm, mins, '.');

        if(s >  mins)  // Are we bigger?
          return 0;
        else if(s < mins) // If we are less then we are definitely wrong
          return -1;
        // Otherwise we move onto the minor version number and so on
      }
      while(minstm.good());

      return 0;
    ]])], 
    [ac_check_linbox_version=true])

    if test "$ac_check_linbox_version" = "true" ; then
        AC_MSG_RESULT([yes])
    else
        AC_MSG_RESULT([no])
    fi

    CPPFLAGS=$OLD_CPPFLAGS
    LIBS=$OLD_LIBS
    AC_LANG_POP(C++)

  ])

  dnl # Execute ACTION-IF-TRUE / ACTION-IF-FALSE.
  if test "$ac_check_linbox_version" = "true" ; then
        m4_default([$2], :)
  else
        m4_default([$3], :)
  fi
])
