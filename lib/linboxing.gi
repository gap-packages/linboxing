#############################################################################
##
##  LINBOXING - linboxing.gi
##  Miscellaneous functions
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
##  with this program.  If not, see <http://www.gnu.org/licenses/>.
## 
#############################################################################

#####################################################################
##  <#GAPDoc Label="MakeLinboxingDoc_manMisc">
##  <ManSection>
##  <Func Name="MakeLinboxingDoc" Arg="[make-internal]"/>
##
##  <Description>
##  Builds this documentation from the &linboxing; package source
##  files. This should not normally need doing: the current documentation is
##  built and included with the package release.
##  <P/>
##  If the optional boolean argument <A>make-internal</A> is <K>true</K> then 
##  the internal (undocumented!) functions are included in this manual.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
#####################################################################
InstallGlobalFunction(MakeLinboxingDoc,
  function(arg)
    local docdir, sysdir;
  # First merge the include files
  docdir := DirectoriesPackageLibrary("linboxing", "doc")[1];
  sysdir := DirectoriesSystemPrograms();
  Process(docdir, Filename(sysdir, "sh"), 
  InputTextUser(), OutputTextUser(), 
  [ "-c", "./includesourcedoc.sh functions.xml.in functions.xml"]);
  
  if Length(arg) = 1 and arg[1] = true then
    Process(docdir, Filename(sysdir, "sh"), 
    InputTextUser(), OutputTextUser(), 
    [ "-c", "./includesourcedoc.sh internal.xml.in internal.xml"]);
  else
    Process(docdir, Filename(sysdir, "cp"), 
    InputTextUser(), OutputTextUser(), 
    ["internal.xml.none", "internal.xml"]);
  fi;
  # Now make the gapdoc
  MakeGAPDocDoc(docdir, "linboxing", [ 
    "../lib/linboxing.gd", 
    "../lib/linboxing.gi", 
    "../lib/solutions.gi",
    "../lib/tests.gi",
    ], "linboxing", "../..");
end);
#####################################################################



if IsBound(LinBox) then
#####################################################################
##  <#GAPDoc Label="LinBox.FIELD_DATA_manInt">
##  <ManSection>
##  <Func Name="LinBox.FIELD_DATA" Arg="M"/>
##
##  <Description>
##  Checks that the field of the matrix <A>M</A> is one that is accepted
##  by the kernel module, and if so returns data on the field for the 
##  kernel module to use. if the field is not compatible, then an error is 
##  thrown.
##  <P/>
##  The field data is a plain list with three elements: first the field of the 
##  matrix (using <Ref Func="DefaultFieldOfMatrix" BookName="Ref"/>); second
##  the field id, which is zero for an integer (or rationals) matrix, or the 
##  fieldsize otherwise; and finally the one of the field.
##  <P/>
##  If the matrix is over the integers or the rationals, then zero is returned.
##  It is assumed that the matrix is over the integers (since we can't cope
##  with rationals), but we check that each element is an integer when we 
##  convert it in the kernel module and throw an error if it is not.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
#####################################################################
LinBox.FIELD_DATA := function(M)
  local f, size, s;
  
  f := DefaultFieldOfMatrix(M);
  if f = Rationals then
    return [Integers, 0, 1];
  elif IsPrimeField(f) then
    size := Size(f);
    if IsSmallIntRep(size) then
      return [f, size, One(f)];
    else
      s := Concatenation("the linboxing package only supports finite fields of order up to ", String(LinBox.MAX_GAP_SMALL_INT()));
      Error(s);
    fi;
  fi;
      
  Error("the linboxing package only supports integers and prime fields.");
end;
#####################################################################
fi; #IsBound(LinBox) 