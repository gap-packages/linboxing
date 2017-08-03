#############################################################################
##
##  LINBOXING - init.g
##  Initialisation file
##  Paul Smith
##
##  Copyright (C)  2007-2008
##  Paul Smith
##  National University of Ireland Galway
##
##  This file is part of the linboxing GAP package.
## 
##  The linboxing package is free software; you can redistribute it and/or 
##  modify it under the terms of the GNU General Public License as published by
##  the Free Software Foundation; either version 2 of the License, or (at your 
##  option) any later version.
## 
##  The linboxing package is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of 
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General 
##  Public License for more details.
## 
##  You should have received a copy of the GNU General Public License along 
##  with this program.  If not, see <http://www.gnu.org/licenses/>.
## 
##  $Id: init.g 90 2008-01-29 15:10:15Z pas $
##
#############################################################################

ReadPackage( "linboxing", "lib/linboxing.gd" );


# load kernel functions if possible
# try the static module first
if not IsBound(LinBox) then
  if "linboxing" in SHOW_STAT() then
    LoadStaticModule("linboxing");
  fi;
fi;
# now try the dynamic module
if not IsBound(LinBox) then
  if Filename(DirectoriesPackagePrograms("linboxing"), "linboxing.so") <> fail then
    LoadDynamicModule(Filename(DirectoriesPackagePrograms("linboxing"), "linboxing.so"));
  fi;
fi;

