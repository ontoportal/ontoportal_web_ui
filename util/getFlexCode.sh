#!/bin/bash
#===============================================================================
#
#          FILE:  getFlexCode.sh
# 
#         USAGE:  ./getFlexCode.sh 
# 
#   DESCRIPTION:  Incorporate flex code into a git checkout for
#   bioportal_web_ui.
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Darren L. Weber, Ph.D. <darren.weber@stanford.edu>
#       COMPANY:  Stanford University
#       VERSION:  1.0
#       CREATED:  10/24/2012 02:26:42 PM PDT
#      REVISION:  ---
#===============================================================================

FLEX_RELEASE="stage"
FLEX_REPO="https://bmir-gforge.stanford.edu/svn/flexviz/tags/${FLEX_RELEASE}/flex"
FLEX_USER="anonymous"
FLEX_PASS="anonymous-ncbo"
svn export --force --username ${FLEX_USER} --password ${FLEX_PASS} ${FLEX_REPO} ./public/flex

