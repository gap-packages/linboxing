#############################################################################
##
##  LINBOXING - solutions.gi
##  GAP versions of LinBox 'solutions'
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

if IsBound(LinBox) then

## EmptyPlist efficiently generates an empty list, but only appeared
## in GAP 4.4.10. Use it if it's there, or if not then define it to just 
## create a list of zeros
if not IsBound(EmptyPlist) then 
  EmptyPlist := n->ListWithIdenticalEntries(n, 0);
fi;


#####################################################################
##  <#GAPDoc Label="LinBox.DeterminantMat_manMain">
##  <ManSection>
##  <Func Name="LinBox.Determinant" Arg="M"/>
##  <Func Name="LinBox.DeterminantMat" Arg="M"/>
##  <Func Name="LinBox.DeterminantIntMat" Arg="M"/>
##
##  <Description>
##  Returns the determinant of the square matrix <A>M</A>. 
##  The entries of <A>M</A> must be integers or over a prime field.
##  </Description>
##  </ManSection>
##  <Example><![CDATA[
##  gap> LinBox.DeterminantMat([[1,2,3],[4,5,6],[7,8,9]]);
##  0
##  ]]></Example>
##  <#/GAPDoc>
#####################################################################
LinBox.DeterminantMat := function(M)
  local elm;
      
  if not IsMatrix(M) then
    Error("<M> must be a matrix");
  fi;
  if not Length(M) = Length(M[1]) then
    Error("the matrix <M> must be square");
  fi;
    
  return LinBox.DETERMINANT(M, LinBox.FIELD_DATA(M));
end;
#####################################################################
LinBox.Determinant := function(M)
  return LinBox.DeterminantMat(M);
end;
#####################################################################
LinBox.DeterminantIntMat := function(M)
  return LinBox.DeterminantMat(M);
end;
#####################################################################

#####################################################################
##  <#GAPDoc Label="LinBox.RankMat_manMain">
##  <ManSection>
##  <Func Name="LinBox.Rank" Arg="M"/>
##  <Func Name="LinBox.RankMat" Arg="M"/>
##
##  <Description>
##  Returns the maximal number of linearly-independent rows of the matrix <A>M</A>.
##  The entries of <A>M</A> must be integers or over a prime field.
##  </Description>
##  </ManSection>
##  <Example><![CDATA[
##  gap> LinBox.RankMat([[1,2,3],[4,5,6],[7,8,9]]);
##  2
##  ]]></Example>
##  <#/GAPDoc>
#####################################################################
LinBox.RankMat := function(M)
  local elm;
      
  if not IsMatrix(M) then
    Error("<M> must be a matrix");
  fi;
    
  elm := M[1][1];
  
  return LinBox.RANK(M, LinBox.FIELD_DATA(M));
end;
#####################################################################
LinBox.Rank := function(M)
  return LinBox.RankMat(M);
end;
#####################################################################

#####################################################################
##  <#GAPDoc Label="LinBox.TraceMat_manMain">
##  <ManSection>
##  <Func Name="LinBox.Trace" Arg="M"/>
##  <Func Name="LinBox.TraceMat" Arg="M"/>
##
##  <Description>
##  For a square matrix <A>M</A>, returns the sum of the diagonal entries.
##  The entries of <A>M</A> must be integers or over a prime field.
##  Note that this version (unlike the others in this package) is typically
##  slower than the &GAP; equivalent, but is provided for completeness.
##  </Description>
##  </ManSection>
##  <Example><![CDATA[
##  gap> LinBox.TraceMat([[1,2,3],[4,5,6],[7,8,9]]);
##  15
##  ]]></Example>
##  <#/GAPDoc>
#####################################################################
LinBox.TraceMat := function(M)
  local elm;
      
  if not IsMatrix(M) then
    Error("<M> must be a matrix");
  fi;
  if not Length(M) = Length(M[1]) then
    Error("the matrix <M> must be square");
  fi;
    
  elm := M[1][1];
  
  return LinBox.TRACE(M, LinBox.FIELD_DATA(M));
end;
#####################################################################
LinBox.Trace := function(M)
  return LinBox.TraceMat(M);
end;
#####################################################################


#####################################################################
##  <#GAPDoc Label="LinBox.SmithNormalFormIntegerMat_manIGNORE">
##  <ManSection>
##  <Func Name="LinBox.SmithNormalFormIntegerMat" Arg="M"/>
##
##  <Description>
##  Computes the Smith Normal Form of the matrix <A>M</A> (with integer 
##  entries).
##  </Description>
##  </ManSection>
##  <Example><![CDATA[
##  gap> LinBox.TraceMat([[1,2,3],[4,5,6],[7,8,9]]);
##  15
##  ]]></Example>
##  <#/GAPDoc>
#####################################################################
# LinBox.SmithNormalFormIntegerMat := function(M)
#       
#   if not IsMatrix(M) then
#     Error("<M> must be a matrix");
#   fi;
#     
#   if IsInt(M[1][1]) then 
#     return LinBox.SMITH_FORM(M, 0);
#   else
#     Error("<M> must have integer entries");
#   fi;
# end;
#####################################################################


#####################################################################
##  <#GAPDoc Label="LinBox.SolutionMat_manMain">
##  <ManSection>
##  <Func Name="LinBox.SolutionMat" Arg="M, b"/>
##
##  <Description>
##  Returns a row vector <A>x</A> that is a solution of the equation
##  <M>xM=b</M>, or <K>fail</K> if no solution exists. If the system is
##  consistent, a random solution <A>x</A> is returned.
##  The entries of <A>M</A> must be integers or over a prime field, but
##  if they are integers then the solution may include rationals.
##  </Description>
##  </ManSection>
##  <Example><![CDATA[
##  gap> LinBox.SolutionMat([[1,2,3],[4,5,6],[7,8,9]], [2,1,0]);
##  [ -1, -1, 1 ]
##  gap> LinBox.SolutionMat([[1,2,3],[4,5,6],[7,8,9]], [2,1,0]);
##  [ -5/4, -1/2, 3/4 ]
##  ]]></Example>
##  <#/GAPDoc>
#####################################################################
LinBox.SolutionMat := function(M, b)
  local fielddataMat, fielddataVect;
      
  if not IsMatrix(M) then
    Error("<M> must be a matrix");
  fi;
  if not Length(M[1]) = Length(b) then
    Error("the matrix <M> and vector <b> are incompatible");
  fi;
  # LinBox crashes when solving nx1 matrices
  if Length(M[1]) = 1 then
    return SolutionMat(M,b);
  fi;

  fielddataMat := LinBox.FIELD_DATA(M);
  fielddataVect := LinBox.FIELD_DATA([b]);

  if Characteristic(fielddataMat[1]) = Characteristic(fielddataVect[1]) then
    if fielddataMat[2] > fielddataVect[2] then 
      return LinBox.SOLVE(M, b, fielddataMat);
    else
      return LinBox.SOLVE(M, b, fielddataVect);
    fi;
  else
    Error("the matrix <M> and vector <b> are not over fields with the same characteristic");
  fi;
  
end;
#####################################################################
LinBox.SolutionIntMat := function(M, b)
  return LinBox.SolutionMat(M, b);
end;
#####################################################################


else
#  Info(InfoWarning, 1, "linboxing: the kernel module has not been successfully loaded.");
#  Info(InfoWarning, 1, "No LinBox.<func> functions will be available");
fi; # if IsBound(LinBox) then
 