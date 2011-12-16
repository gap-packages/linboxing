#   LINBOXING - ac_find_blas.m4
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
#   $Id: Makefile.am 78 2007-11-19 10:42:45Z pas $

################################################################################
# Checks BLAS and LAPACK and sets linker flags BLAS_LIBS and LAPACK_LIBS
# if successful.
#####################################################
AC_DEFUN([AC_FIND_BLAS_AND_LAPACK],
[
  AC_FC_DUMMY_MAIN
  AC_FC_LIBRARY_LDFLAGS
  ACX_BLAS( , 
    [
      echo ""
      echo "*********************************************************************"
      echo "  ERROR"
      echo ""
      echo "  Cannot find or use a BLAS library. Please check your installation"
      echo "  or use the --with-blas option. You can use this to either specify" 
      echo "  the library name, i.e. --with-blas=<lib> or the full set of linker"
      echo "  flags for example --with-blas=\"-L<path to library> -l<library name>\""
      echo "*********************************************************************"
      echo ""
      AC_MSG_ERROR([Cannot find or use BLAS])
    ])
  
# We don't currently need LAPACK, but just in case we do at some point...
#  ACX_LAPACK( , 
#    [
#    echo ""
#    echo "**********************************************************************"
#    echo "  ERROR"
#    echo ""
#    echo "  Cannot find or use a LAPACK library. Please check your installation"
#    echo "  or use the --with-lapack option. You can use this to either specify" 
#    echo "  the library name, i.e. --with-lapack=<lib> or the full set of"
#    echo "  linker flags for example --with-lapack="-L<path> -l<library name>"
#    echo "**********************************************************************"
#    echo ""
#    AC_MSG_ERROR([Cannot find or use LAPACK])
#    ])
])
