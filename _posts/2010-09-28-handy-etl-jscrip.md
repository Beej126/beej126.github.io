---
title: Handy ETL JScript
author: Beej
type: post
date: 2010-09-28T17:10:00+00:00
year: "2010"
month: "2010/09"
url: /2010/09/handy-etl-jscrip.html
blogger_bid:
  - 7726907200224433699
blogger_blog:
  - www.beejblog.com
blogger_id:
  - 1425768875678034955
blogger_author:
  - g108669953529091704409
blogger_permalink:
  - /2010/09/handy-etl-jscript.html
dsq_thread_id:
  - 5995118531
categories:
tags:
  - Database

---
import.cmd: @cscript /b import.js %* 

```js
//v1.0

function cleanarg(i)
{
    //WScript.stdout.WriteLine("i: " + i);
    return(WScript.Arguments(i+1).replace("\"", ""));
}

//WScript.stdout.WriteLine("arg count: "+WScript.Arguments.length);

if (WScript.Arguments.length == 0)
{
    WScript.stderr.WriteLine("Usage:");
    WScript.stderr.WriteLine("    -i \"input file\"");
    WScript.stderr.WriteLine("    -o \"output file\" (blank = screen output)");
    WScript.stderr.WriteLine("    -r \"record separator\"");
    WScript.Quit();
}

var inputfile;
var outputfile;
var record;

var localpath = WScript.ScriptFullName.replace(WScript.ScriptName, "");

for (var i = 0; i < WScript.Arguments.length; i++)
{
    //WScript.stdout.WriteLine("arg["+i+"]: "+WScript.Arguments(i));
    switch (WScript.Arguments(i))
    {
        case "-i": inputfile = cleanarg(i); break;
        case "-o": outputfile = cleanarg(i); break;
        case "-r": record = cleanarg(i); break;
    }
}

var fso = new ActiveXObject("Scripting.FileSystemObject");

//WScript.stderr.WriteLine("    inputfile: " + inputfile + ", record: " + record + ", exension: " + fso.GetExtensionName(inputfile) + ", WScript.ScriptFullName: " + WScript.ScriptFullName.replace(WScript.ScriptName, ""));
//WScript.Quit();

var ForReading = 1, ForWriting = 2;

var f = fso.OpenTextFile(inputfile, ForReading);

var out = WScript.stdout;
if (outputfile != undefined) out = fso.OpenTextFile(outputfile, ForWriting, true);

var line="";
while ( f.AtEndOfStream != true )
{
    var str = f.Readline();
    if (str == record)
    {
        out.WriteLine(line.slice(1));
        line = "";
    }
    else line += "," + str;
}
out.Close();

if (fso.GetExtensionName(outputfile) == "csv")
{
    var WshShell = WScript.CreateObject("WScript.Shell");
    //WScript.stderr.WriteLine(localpath + outputfile);
    WshShell.Run(localpath + outputfile);
    WshShell.Run(localpath + outputfile);
    WshShell.Run(localpath + outputfile);
}
```
