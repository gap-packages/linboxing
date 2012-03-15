#   LINBOXING - Makefile.am
#   Makefile for kernel module
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


BINARCHDIR = bin/$(GAPARCH)
GAPINSTALLLIB = $(abs_top_srcdir)/$(BINARCHDIR)/linboxing.so

lib_LTLIBRARIES = linboxing.la

linboxing_la_SOURCES = linboxing.c linboxing.h linboxfuncs.cc convert.h runfunc.h 
linboxing_la_LDFLAGS = -module -avoid-version $(GMP_LDFLAGS) $(LINBOX_LDFLAGS)
#linbox_la_LIBADD = $(LAPACK_LIBS) $(BLAS_LIBS) $(FCLIBS)
linboxing_la_LIBADD = $(LINBOX_LIBS) $(GIVARO_LIBS) $(BLAS_LIBS) $(GMP_LIBS)
linboxing_la_CPPFLAGS = $(GAP_CPPFLAGS) $(LINBOX_CPPFLAGS) $(GMP_CPPFLAGS) 

EXTRA_DIST = \
	Doxyfile


# Change it so that make all also does a make install (to build the .so)
# and then copies it to the correct bin directory
all-local: 
	@$(MAKE) $(AM_MAKEFLAGS) install-libLTLIBRARIES
	$(mkdir_p) $(top_srcdir)/$(BINARCHDIR)
	cp $(libdir)/linboxing.so $(GAPINSTALLLIB)
	@echo ""
	@echo "***********************************************************************"
	@echo ""
	@echo "  SUCCESS!"
	@echo ""
	@echo "The linboxing kernel module has been successfully built and installed"
	@echo "in $(GAPINSTALLLIB)"
	@echo ""
	@echo ""
	@echo "The linboxing package will probably conflict with GAP's memory. To"
	@echo "avoid conflict you should either run GAP with the -a switch, for"
	@echo "example"
	@echo ""
	@echo "gap -a 100M"
	@echo ""
	@echo "or with the -m switch, for example"
	@echo ""
	@echo "gap -m 256M"
	@echo ""
	@echo "For more details about these switches, see the package documentation" 
	@echo "in the doc/ directory, or via the GAP help system. The relevant by" 
	@echo "section can be found by loading GAP and typing"
	@echo ""
	@echo "gap> ?linboxing:Starting GAP"
	@echo ""
	@echo ""
	@echo "IMPORTANT:"
	@echo "Before using the linboxing package for any calculations, you should"
	@echo "test the correct operation of the package by running GAP and typing"
	@echo ""
	@echo "gap> LoadPackage(\"linboxing\");"
	@echo "gap> TestLinboxing();"
	@echo ""
	@echo "***********************************************************************"
	

# Change it so that make clean also does a make uninstall (to remove the .so)
# and removes it from the bin directory
clean-local: 
	@$(MAKE) $(AM_MAKEFLAGS) uninstall-libLTLIBRARIES
	rm -f $(GAPINSTALLLIB)
