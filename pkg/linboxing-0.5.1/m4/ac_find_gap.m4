#   LINBOXING - ac_find_gap.m4
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
#   $Id: ac_find_gap.m4 101 2008-04-22 15:08:20Z pas $
################################################################################

# Find the location of GAP
# Sets GAPROOT, GAPARCH and GAP_CPPFLAGS appropriately
#####################################################

AC_DEFUN([AC_FIND_GAP],
[
  AC_LANG_PUSH(C)
  
  # Make sure CDPATH is portably set to a sensible value
  CDPATH=${ZSH_VERSION+.}:

  GAP_CPPFLAGS=""

  ######################################
  # Find the GAP root directory by 
  # checking for the sysinfo.gap file 
  AC_MSG_CHECKING([for GAP root directory])
  
  #Allow the user to specify the location of GAP
  #
  AC_ARG_WITH(gaproot, 
    [AC_HELP_STRING([--with-gaproot=<path>], [specify root of GAP installation])],
    [GAPROOT=$withval])
  DEFAULT_GAPROOTS="../.. /usr/local/lib/gap4r4 /usr/lib/gap4r4"
  
  SYSINFO="sysinfo.gap"
  havesysinfo=0
  if test -n "$GAPROOT"; then
    # Make sure the path given is stored as an absolute path
    GAPROOT=`cd $GAPROOT > /dev/null 2>&1 && pwd`

    if test -e ${GAPROOT}/${SYSINFO}; then
      havesysinfo=1
    fi
  else
    # Otherwise try likely directories
    for GAPROOT in ${DEFAULT_GAPROOTS} 
    do
      # Convert the path to absolute
      GAPROOT=`cd $GAPROOT > /dev/null 2>&1 && pwd`
      if test -e ${GAPROOT}/${SYSINFO}; then
        havesysinfo=1
        break
      fi
    done
  fi
    
  if test "x$havesysinfo" = "x1"; then
    AC_MSG_RESULT([${GAPROOT}])
  else
    AC_MSG_RESULT([Not found])
    
    echo ""
    echo "**********************************************************************"
    echo "  ERROR"
    echo ""
    echo "  Cannot find your GAP installation. Please specify the location of"
    echo "  GAP's root directory using --with-gaproot=<path>"
    echo ""
    echo "  The GAP root directory (as far as linboxing is concerned) is the one"
    echo "  containing the file sysinfo.gap and the subdirectories src/ and "
    echo "  bin/."
    echo "**********************************************************************"
    echo ""
    
    AC_MSG_ERROR([Unable to find GAP root directory])
  fi
        
  #####################################
  # Now find the architecture
        
  AC_REQUIRE([AC_PROG_GREP])
  AC_REQUIRE([AC_PROG_SED])
  
  GAPARCH="Unknown"

  AC_MSG_CHECKING([for GAP architecture])
  GAPARCH=`${GREP} GAParch ${GAPROOT}/${SYSINFO} | ${SED} 's|^GAParch=\(.*\)|\1|'`
  AC_MSG_RESULT([${GAPARCH}])
 
  if test "x$GAPARCH" = "xUnknown"; then
    echo ""
    echo "**********************************************************************"
    echo "  ERROR"
    echo ""
    echo "  Found a GAP installation at $GAPROOT"
    echo "  but could find information about GAP's architecture in the file"
    echo "  ${GAPROOT}/${SYSINFO}"
    echo "  This file should be present: please check your GAP installation."
    echo "**********************************************************************"
    echo ""
    
    AC_MSG_ERROR([Unable to find GAParch information.])
  fi  
  
  
  #####################################
  # Now check for the GAP header files
        
  #Remember the input CPPFLAGS
  OLD_CPPFLAGS="$CPPFLAGS"
  
  AC_MSG_CHECKING([for GAP include files])
  CPPFLAGS="$OLD_CPPFLAGS -I$GAPROOT"
  
  AC_COMPILE_IFELSE(
    [#include "src/compiled.h"
      Obj Func(Obj Self){return (Obj)0;}], 
    [a=1])

  if test "x$a" = "x1"; then
    GAP_CPPFLAGS="-I$GAPROOT"
    AC_MSG_RESULT([$GAPROOT/src])
  else
    AC_MSG_RESULT([Not found])
    
    echo ""
    echo "**********************************************************************"
    echo "  ERROR"
    echo ""
    echo "  Failed to find the GAP source header files in the src/ subdirectory"
    echo "  of your GAP root directory. The expected location was"
    echo "  $GAPROOT/src"
    echo ""
    echo "  The linboxing kernel build process expects to find the normal GAP "
    echo "  root directory structure as it is after building GAP itself, and in "
    echo "  particular the files <gaproot>/sysinfo.gap, <gaproot>/src/<includes>"
    echo "  and <gaproot>/bin/<architecture>/bin/config.h. Please make sure that"
    echo "  your GAP root directory structure conforms to this layout, or give"
    echo "  the correct GAP root using  --with-gaproot=<path>"
    echo "**********************************************************************"
    echo ""
    
    AC_MSG_ERROR([Unable to find GAP include files in /src subdirectory])
  fi
  
  #Reset CPPFLAGS
  CPPFLAGS="$OLD_CPPFLAGS"

  
  ######################################
  # Try to find a GAP config.h
  # either in GAPROOT/bin or in GAPINCLUDES
  
  AC_MSG_CHECKING([for GAP config.h location])
  GAPCONFIGPATH="$GAPROOT/bin/$GAPARCH"
  if test -r "$GAPCONFIGPATH/config.h"; then
    GAP_CPPFLAGS="$GAP_CPPFLAGS -DCONFIG_H -I$GAPCONFIGPATH"
    AC_MSG_RESULT([$GAPCONFIGPATH/config.h])
  else
    AC_MSG_RESULT([not found])
    AC_CHECK_SIZEOF([void *],4)
    bits64=""
    AC_MSG_CHECKING([for 64-bit machine])
    if test "x${ac_cv_sizeof_void_p}" = "x8"; then
      GAP_CPPFLAGS="$GAP_CPPFLAGS -DSYS_IS_64_BIT"
      AC_MSG_RESULT([yes])
      bits64="a 64-bit machine"
    else
      AC_MSG_RESULT([no])
      bits64="not a 64-bit machine"
    fi
    echo ""
    echo "----------------------------------------------------------------------"
    echo "  WARNING"
    echo ""
    echo "  Failed to find GAP's config.h file in the expected location"
    echo "  $GAPCONFIGPATH/config.h"
    echo "  This is needed to find out what system settings GAP was built with,"
    echo "  and in particular whether GAP thinks the system is 32- or 64-bit."
    echo "  As a result, the linboxing configure script has done its own test"
    echo "  and thinks it is $bits64. You can proceed to build the"
    echo "  kernel module, but it is important that you use"
    echo ""
    echo "  gap> TestLinboxing()"
    echo ""
    echo "  to make sure that linboxing and GAP agree about the size of small "
    echo "  integers."
    echo ""
    echo "  To avoid this warning, please check that the GAP root path used (or"
    echo "  specified by --with-gaproot) points to the location of the full GAP "
    echo "  directory structure where GAP was built, and that the architecture"
    echo "  reported in <gaproot>/sysinfo.gap agrees with the subdirectory of"
    echo "  <gaproot>/bin" 
    echo "----------------------------------------------------------------------"
    echo ""
  fi;
  
  AC_SUBST(GAPARCH)
  AC_SUBST(GAPROOT)
  AC_SUBST(GAP_CPPFLAGS)


  AC_LANG_POP(C)
])
