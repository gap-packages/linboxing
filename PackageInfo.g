#############################################################################
##
##  LINBOXING - PackageInfo.g
##  Initialisation file
##  Paul Smith
##
##  Copyright (C)  2007-2008
##  National University of Ireland Galway
##  Copyright (C)  2011
##  University of St Andrews
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
##  with this program.  If not, see <https://www.gnu.org/licenses/>.
## 
#############################################################################

SetPackageInfo( rec(

PackageName := "linboxing",
Subtitle := "access to LinBox linear algebra functions from GAP",
Version := "0.5.2",
Date := "19/05/2011", # dd/mm/yyyy format
License := "GPL-2.0-or-later",

Persons := [
  rec( 
    LastName      := "Smith",
    FirstNames    := "Paul",
    IsAuthor      := true,
    IsMaintainer  := true,
    Email         := "pas1001@cantab.net",
    WWWHome       := "http://www.cs.st-andrews.ac.uk/~pas",
    PostalAddress := Concatenation( [
                         "Paul Smith\n",
                         "School of Computer Science\n",
                         "University of St Andrews\n",
                         "St Andrews\n",
                         "UK" ] ),
    Place         := "St Andrews",
    Institution   := "University of St Andrews"
  ),
],

Status := "deposited",

ArchiveURL := "http://www.cs.st-andrews.ac.uk/~pas/linboxing/linboxing-0.5.2",
ArchiveFormats := ".tar.gz",
README_URL := 
  "http://www.cs.st-andrews.ac.uk/~pas/linboxing/README.linboxing",
PackageInfoURL := 
  "http://www.cs.st-andrews.ac.uk/~pas/linboxing/PackageInfo.g",
PackageWWWHome := "http://www.cs.st-andrews.ac.uk/~pas/linboxing/",

AbstractHTML := 
  "The <span class=\"pkgname\">linboxing</span> package provides kernel-level \
  access to the exact linear algebra functions from the LinBox C++ library.",

PackageDoc := rec(
  BookName  := "linboxing",
  ArchiveURLSubset := ["doc"],
  HTMLStart := "doc/chap0_mj.html",
  PDFFile   := "doc/manual.pdf",
  SixFile   := "doc/manual.six",
  LongTitle := "Kernel-level access to LinBox linear algebra",
  Autoload  := true
),


Dependencies := rec(
  GAP := ">=4.4",
  NeededOtherPackages := [["GAPDoc", "1.0"]],
  SuggestedOtherPackages := [],
  ExternalConditions := ["LinBox (https://www.linalg.org/) with version >= 1.1.6"]
),

AvailabilityTest := function()
  local path;
    # test for existence of the compiled binary
    path := DirectoriesPackagePrograms("linboxing");
    if not "linboxing" in SHOW_STAT() and Filename(path, "linboxing.so") = fail then
      # Use LogPackageLoadingMessage if available (i.e. GAP4.5)
      # But need to call it in this round-about way so that we don't get
      # errors in GAP 4.4. PACKAGE_ERROR=1
      if IsBoundGlobal( "LogPackageLoadingMessage" ) then
        CallFuncList( ValueGlobal( "LogPackageLoadingMessage" ), [ 1,
          ["The compiled linboxing kernel module is not present."]]);
      else
        Info(InfoWarning, 1, "linboxing: compiled kernel module not present.");
      fi;
      return false;
    fi;
    return true;
  end,

TestFile := "tst/linboxing.tst",

Keywords := ["Linear algebra"],

));
