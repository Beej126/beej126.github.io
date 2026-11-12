---
title: 'Visual Studio 2010 Slow Startup [resolved]'
date: 2011-02-24
author: Beej
tags:
  - VisualStudio
---
Apparently the culprit of my slowdown was the VMware debugger integration… <a href="https://www.devtopics.com/visual-studio-2010-slowdown-vmdebugger-is-the-culprit/" target="_blank">resolution here</a> I merely uninstalled the VMDebugger component via VMware Desktop setup.exe …  I did \*not\* have to completely uninstall all of VMware Desktop to see an significant improvement to Visual Studio startup time… down to a few seconds now from something that felt like 30 seconds.