# #############################################################################
# 
#   GAP-LINBOX - includesourcedoc.sh
#   Inserts GAPDoc blocks into xml template
#   Paul Smith
#   
#   Copyright (C)  2007
#   Paul Smith
#   National University of Ireland Galway
#   
#   This file is part of the LinBox package for GAP. 
# 
#   The LinBox package for GAP is free software; you can redistribute it and/or 
#   modify it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or (at your 
#   option) any later version.
# 
#   The LinBox package for GAP is distributed in the hope that it will be 
#   useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General 
#   Public License for more details.
# 
#   You should have received a copy of the GNU General Public License along 
#   with this program.  If not, see <http://www.gnu.org/licenses/>.
# 
#   $Id: includesourcedoc.sh 170 2007-09-24 16:47:42Z pas $
#
# #############################################################################

# Script information
NAME="includesourcedoc"
VERSION="1.0"
USAGE="$NAME [options] <infile> <outfile>"

# Default values
SOURCEPATH="../lib"

SUFFIXKEY="GAPDocSourceSuffix"
COMMENTSTART="<!--"

# #############################################################################

tmpfile=/tmp/tmp.${RANDOM}$$
tmpfile2=/tmp/tmp.${RANDOM}$$
newfile=/tmp/tmp.${RANDOM}$$

# #############################################################################

# First parse the parameters

while getopts d:h OPTION
do case "$OPTION" in
  d) SOURCEPATH="$OPTARG";;
  h) echo "$USAGE" 
  echo ''
  echo 'Searches GAP source files (*.gd *.gi) for GAPDoc documentation to insert into a'
  echo 'GAPDoc xml file. The input file is parsed for lines including the comment'
  echo 'GAPDocSourceSuffix="_asuffix", and then each source file is parsed for'
  echo 'GAPDoc blocks with lines of the form <#GAPDoc Label="FunctionName_asuffix">'
  echo '#include lines for these blocks are then inserted into the source file'
  echo 'immediately below the original comment. The merged file is saved as outfile.'
  echo ''
  echo 'Optional arguments'
  echo '  -h        Displays this help'
  echo "  -d <dir>  Specifies the relative path to the source files [$SOURCEPATH]"
  exit 1;;
  ?) echo "$USAGE" && exit 1;;
esac
done

shift $[ $OPTIND - 1 ]

# For the moment just check that we have two
if test $# -ne 2
then 
  echo $USAGE
  exit 1;
fi

INFILE=$1
OUTFILE=$2

# Check that the source directory exists
if test ! -d $SOURCEPATH
then
  echo "Directory for source files does not exist: $SOURCEPATH"
  echo "current directory is `pwd`"
  exit 1;
fi
  
# And check that there are some source files in this directory
ls $SOURCEPATH/*.gi $SOURCEPATH/*.gd > /dev/null 2>&1
if test "$?" -ne "0"
then
  echo "No source (*.gd *.gi) files found in path $SOURCEPATH"
  echo "Please specify a different source path"
  exit 1;
fi
  
# Check the input file exists
if test ! -r $INFILE
then
  echo "Cannot read input file $INFILE"
  exit 1;
fi

length=`wc -l $INFILE | cut -f1 -d' '`
# Copy rows one at a time into the output file
lineno=1
while test $lineno -le $length
do
  head -n$lineno $INFILE | tail -n 1 > $tmpfile

  # Does it have a suffix?
  grep -n '.*<!--.*'$SUFFIXKEY'=".*".*' $tmpfile > /dev/null 2>&1
  if test "$?" -eq "0"
  then
    # Extract out the suffix (if it exists)
    suffix=`sed 's|.*<!--.*'$SUFFIXKEY'="\(.*\)".*|\1|' $tmpfile`
    echo "Processing suffix: $suffix"
    
    # Now find the lines in the source files that have this suffix in them
    grep '.*<#GAPDoc Label=".*'$suffix'"' $SOURCEPATH/*.gd $SOURCEPATH/*.gi > $tmpfile

    length2=`wc -l $tmpfile | cut -f1 -d' '`
    lineno2=1
    while test $lineno2 -le $length2
    do
      head -n$lineno2 $tmpfile | tail -n 1 > $tmpfile2
      # Extract out the label
      label=`sed 's|.*<#GAPDoc Label="\(.*'$suffix'\)".*|\1|' $tmpfile2`

      # And write some new lines with these labels
      echo "    <#Include Label=\"$label\">" >> $newfile

      lineno2=$[ $lineno2 + 1 ]
    done
    
  else
    # Otherwise just copy the line
    cat $tmpfile >> $newfile
  fi;
  
  lineno=$[ $lineno + 1 ]
done

cp $newfile $OUTFILE
  
