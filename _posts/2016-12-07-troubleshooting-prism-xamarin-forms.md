---
title: Troubleshooting Prism Xamarin Forms
date: 2016-12-07
author: Beej
tags:
  - Xamarin
---
_for the record i'm currently running with the Unity DI framework_

### totally silent app crash on NavigateAsync

this is super frustrating when you don't get any exception stack at all to go on...
  
i can't tell you how many times i've brainfarted a simple typo bug which blows up the xaml parse ... so check that well before you get too cranky... e.g. i always forget the "{Binding }" around my commands!?!?
  
but if you can easily, temporarily set your initial page navigation (typically in your App.xaml.cs::App.OnInitialized) to go directly to your offending page
  
and then make sure to put a .Wait() on the end of the call... doing these two things allows the otherwise silent exceptions to show up and hopefully that's just the clue you need

### ViewModelLocationProvider naming bug

i stumbled into naming one of my pages "PdfView" and it went haywire not binding to my "PdfViewViewModel" but instead probably the first viewmodel instantiated