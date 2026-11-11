---
title: PowerShell Dual Windows Explorers
date: 2015-06-14
author: Beej
tags:
  - PowerShell
  - Productivity
thumbnail-img: /images/uploads/2015/powershell-dual-windows-explorers-thumbnail.png
---
&nbsp;

Nutshell: Hosting **two Windows File Explorers** inside a WinForm... with the potential of sprinkling some utility hotkeys on top &#8211; e.g. "copy from left to right".

&nbsp;

# [Full source on GitHub][1]

![][2]
  
&nbsp;

Highlights:

  * Always wanted to try this and just finally got around to it... and it actually works to a decent degree.
  * This is of course well covered ground with various other [file managers][3]... i just wanted to see if you could do it this poor man's way with PowerShell driving... so one could readily make it one's own with further customizations
  * I was a longtime fan of Directory Opus... I think it's significant that this meager alternative is customized via standard PowerShell vs a 3rd party scripting environment that must be learned... i.e. if you happen to already know PowerShell, you can jump right in with all that file handling power available
  * The obnoxious part is hunting down the COM interfaces necessary to pull stuff out of FileExplorer... it dips into silliness like how IE is somehow part of the equation.
  * See comments for all the good posts i drew from to cobble it together... lots of handy Shell programming nuggets to be had
  * thanks to a [handy github project][4], [Font-Awesome][5] is now in the WinForms domain &#8211; too cool
  * notes to self 
      * interop.SHDocVw.dll is generated from doing a&nbsp;Visual Studio&nbsp;reference to C:\windows\system32\shdocvmw.dll
      * interop.Shell32.dll seemed like it was going to come in handy but didn't wind up being necessary
      * these are the only real FileExplorer API calls necessary for the CopyFile piece 
          * $objFolder = $objShell.NameSpace($explorerRight_SHDocVw.LocationUrl)
          * $objFolder.CopyHere($explorerLeft_SHDocVw.Document.SelectedItems())
      * there are a few wacky interfaces behind the shell objects but the neat thing is that runtime dynamic type binding makes using real types largely irrelevant... i feel that does lose some self documentation in the balance so i've tried to include the pertinent interfaces in the comments for future reference and expansion

 [1]: https://github.com/Beej126/PoShDualExplorers
 [2]: {{ site.baseurl }}/images/uploads/2015/06/Snap2-1024x699.png
 [3]: https://lifehacker.com/399155/five-best-alternative-file-managers
 [4]: https://github.com/denwilliams/FontAwesome-WindowsForms
 [5]: https://fortawesome.github.io/Font-Awesome/icons/