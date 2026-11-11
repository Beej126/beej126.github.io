---
title: Hacking Profiler into SSMS Express
date: 2012-06-25
author: Beej
tags:
  - Database
---
  * We can download the SQL Server Management Studio Express installer for free which makes for a convenient source for this tool when firing up a new Windows machine that you just want to connect to some servers and get to work &#8211; <https://www.microsoft.com/en-us/download/details.aspx?id=22985>   
    But SSMS Express doesn't provide the Profiler (aka SQL Trace) component that I can't live without. 
  * So &#8211; If you have access to a server where these "Extended Management Tools" are already installed, you can simply copy the handful of Profiler's binary files to your drive and it'll run fine... here's the list... starting with a path like "C:Program Files (x86)Microsoft SQL Server100Tools": 
      * binnPROFILER.EXE 
      * binnPROFILER.EXE.CONFIG 
      * binnPFUI.DLL 
      * binnResources1033PROFILER.rll 
  * Go ahead and add Profiler.exe to your SSMS Tools menu if you like. 
  * Lastly, to patch up the ability to save templates (stolen from here: <https://sqlserverpedia.com/blog/sql-server-bloggers/where-did-the-sql-server-profiler-template-disappear/)> &#8211; just throw a "dummy.tdf" text file into this folder: "C:Program Files (x86)Microsoft SQL Server100ToolsProfilerTemplatesMicrosoft SQL Server1050". That 1050 is the specific SQL Server version number and obviously varies so just roll with whatever yours is... just browse to some other nearby folders to find what your magic version number happens to be. All the ones you've saved so far will magically start appearing in the templates selection drop down after that.