---
title: '[SOLVED] SSRS (2012), Excel export, "Not a legal OleAut date" error'
date: 2013-06-18
author: Beej
tags:
  - Database
---
### Cause

For my situation, it wound up being that executing TimeSerial(0,0,secs) in some vbscript code, when the "secs" param value was greater than 24 hours.

### Analysis

Somehow out of all the different formats SSRS will export to, the Excel output was the only one running into this issue.

From the [TimeSerial][1] specs I don't see anything inherently invalid about going that high... the docs indicate it simply rolls it into the day portion of the resulting value as I would expect. Given that the error refers to "Ole", there must be some other intermediate data type conversion going on here... perhaps it passes through a time only type???

 [1]: https://msdn.microsoft.com/en-us/library/microsoft.visualbasic.dateandtime.timeserial.aspx