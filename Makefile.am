#   LINBOXING - Makefile.am
#   Main Makefile
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

ACLOCAL_AMFLAGS = -I m4

SUBDIRS = src

EXTRA_DIST = \
	CHANGES \
	LICENCE \
	VERSION \
	PackageInfo.g \
	init.g \
	read.g \
	test.g \
	m4/config-blas.h \
	lib/linboxing.gd \
	lib/linboxing.gi \
	lib/solutions.gi \
	lib/tests.gi \
	tst/linboxing.tst \
	doc/manual.pdf \
	doc/manual.css \
	doc/manual.six \
	doc/linboxing.xml \
	doc/intro.xml \
	doc/install.xml \
	doc/functions.xml.in \
	doc/implementation.xml \
	doc/internal.xml.in \
	doc/internal.xml.none \
	doc/includesourcedoc.sh \
	doc/chap0.html \
	doc/chap0.txt \
	doc/chap1.html \
	doc/chap1.txt \
	doc/chap2.html \
	doc/chap2.txt \
	doc/chap3.html \
	doc/chap3.txt \
	doc/chap4.html \
	doc/chap4.txt \
	doc/chap5.html \
	doc/chap5.txt \
	doc/chapInd.html \
	doc/chapInd.txt
	
test: all
	gap -a 100M -m 100M $(top_srcdir)/test.g
	
dist-hook:
	@echo "---------------------------------------------------------------"
	@echo ""
	@echo " Did you call dist2, not dist? If not, why not?"	
	@echo ""
	@echo "---------------------------------------------------------------"

# My own dist which sets the directory permissions to 755, not 777
# and changes the directory name to be simply linboxing
dist2: distdir
	-find $(distdir) -type d -perm -777 -exec chmod 755 {} \;
	-mv $(distdir) $(PACKAGE)
	tardir=$(PACKAGE) && $(am__tar) | GZIP=$(GZIP_ENV) gzip -c >$(distdir).tar.gz
	-mv $(PACKAGE) $(distdir) 
	$(am__remove_distdir)
	
