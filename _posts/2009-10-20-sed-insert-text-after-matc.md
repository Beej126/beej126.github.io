---
title: SED – Insert text after match
date: 2009-10-20
author: Beej
tags:
  - CommandLine
  - Database
---
General syntax:

  * sed “s/search-for-regex/& replace-with/” filename.txt

Example:

  * sed "s/BEGIN AS/& nnSET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED/" Plans_s.sql

Explanation:

  * s/search-for-regex/replace-with/ = search and replace command
  * & = the matched text (effectively leaves the matched text alone rather than “replacing” it)
  * n = carriage return