## Copied (with minor modifications) from linbox/macros (using Linbox versions 1.1.6/1.2.0) 

# Bradford Hovinen, 2001-06-13
# Modified by Pascal Giorgi, 2003-12-03
# Inspired by gnome-bonobo-check.m4 by Miguel de Icaza, 99-04-12
# Stolen from Chris Lahey       99-2-5
# stolen from Manish Singh again
# stolen back from Frank Belew
# stolen from Manish Singh
# Shamelessly stolen from Owen Taylor

dnl LB_CHECK_GIVARO ([MINIMUM-VERSION [, ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND]]])
dnl
dnl Test for Givaro and define GIVARO_CFLAGS and GIVARO_LIBS

AC_DEFUN([LB_CHECK_GIVARO],
[

AC_ARG_WITH(givaro,
  [AS_HELP_STRING([--with-givaro=<path>],
    [specify prefix to which givaro was installed])],
  [if test "$withval" = yes ; then
    GIVARO_HOME_PATH="${DEFAULT_CHECKING_PATH}"
  elif test "$withval" != no ; then
    GIVARO_HOME_PATH="$withval ${DEFAULT_CHECKING_PATH}"
  fi],
  [GIVARO_HOME_PATH="${DEFAULT_CHECKING_PATH}"])

version_min=30400
min_givaro_version=ifelse([$1], ,3.2.12,$1)
max_givaro_version=ifelse([$2], ,3.5.0,$2)



dnl Check for existence

BACKUP_CXXFLAGS=${CXXFLAGS}
BACKUP_LIBS=${LIBS}

AC_MSG_CHECKING([for GIVARO >= $min_givaro_version])

for GIVARO_HOME in ${GIVARO_HOME_PATH} 
 do	
if test -r "$GIVARO_HOME/include/givaro/givconfig.h"; then

	if test "x$GIVARO_HOME" != "x/usr" -a "x$GIVARO_HOME" != "x/usr/local"; then
		GIVARO_CFLAGS="-I${GIVARO_HOME}/include"
		GIVARO_LIBS="-L${GIVARO_HOME}/lib -lgivaro"
	else
		GIVARO_CFLAGS=
		GIVARO_LIBS="-lgivaro"		
	fi	
	CXXFLAGS="${BACKUP_CXXFLAGS} ${GIVARO_CFLAGS} ${GMP_CFLAGS}" 
	LIBS="${BACKUP_LIBS} ${GIVARO_LIBS} ${GMP_LIBS}"

	AC_TRY_LINK(
	[#include <givaro/givinteger.h>],
	[Integer a;],
	[
	AC_TRY_RUN(
	[#include <givaro/givconfig.h>	 
	 int main () { if (GIVARO_VERSION < 3) return -1; else return 0; }
	],[
	givaro_found="yes"	
	break
	],[	
	givaro_problem="$problem $GIVARO_HOME"	
	unset GIVARO_CFLAGS
	unset GIVARO_LIBS
	],[
	givaro_found="yes"
	givaro_cross="yes"
	
	break
	])	
	],
	[
	givaro_found="no"
	])
        # It might be a newer version of givaro, which has namespaces
	if test "x$givaro_found" = "xno" ; then		
	  AC_TRY_LINK(
	  [#include <givaro/givinteger.h>],
	  [Givaro::Integer a;],
	  [
	  AC_TRY_RUN(
	  [#include <givaro/givconfig.h>	 
	  int main () { if (GIVARO_VERSION < $version_min || GIVARO_VERSION >= (($version_min/100+1)*100) || GIVARO_VERSION>0x030000) return -1; else return 0; /* old version of Givaro are defined as hexa 0x03yyzz*/ }
	  ],[
	  givaro_found="yes"	
	  break
	  ],[	
	  givaro_problem="$problem $GIVARO_HOME"	
	  unset GIVARO_CFLAGS
	  unset GIVARO_LIBS
	  ],[
	  givaro_found="yes"
	  givaro_cross="yes"
	  
	  break
	  ])	
	  ],
	  [
	  givaro_found="no"
	  ])
	fi
else
	givaro_found="no"
fi	
done

if test "x$givaro_found" = "xyes" ; then		
	AC_SUBST(GIVARO_CFLAGS)
	AC_SUBST(GIVARO_LIBS)
	AC_DEFINE(HAVE_GIVARO,1,[Define if GIVARO is installed])
	HAVE_GIVARO=yes
	if test "x$givaro_cross" != "xyes"; then
		AC_MSG_RESULT([found])
	else
		AC_MSG_RESULT([unknown])
		echo "WARNING: You appear to be cross compiling, so there is no way to determine"
		echo "whether your GIVARO version is new enough. I am assuming it is."
	fi
	ifelse([$2], , :, [$2])
elif test -n "$givaro_problem"; then
	AC_MSG_RESULT([problem])
	echo "Sorry, your GIVARO version is too old. Disabling."
	ifelse([$3], , :, [$3])
elif test "x$givaro_found" = "xno" ; then
	AC_MSG_RESULT([not found])
	ifelse([$3], , :, [$3])
fi	

AM_CONDITIONAL(LINBOX_HAVE_GIVARO, test "x$HAVE_GIVARO" = "xyes")

CXXFLAGS=${BACKUP_CXXFLAGS}
LIBS=${BACKUP_LIBS}
#unset LD_LIBRARY_PATH

])
