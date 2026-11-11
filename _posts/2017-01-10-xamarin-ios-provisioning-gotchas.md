---
title: Xamarin iOS Provisioning Gotchas
date: 2017-01-10
author: Beej
tags:
  - iOS
  - Xamarin
---
I managed to create scenario where debugging from **Visual Studio 2017** to iOS Simulator was giving me absolute fits because the error messages are so unhelpful... as usual, it was my own fault of course, but gosh it's scary how easily one can fall in that deep dark pit where hopes and dreams go to die ; )

### Example Error Messages

  * `Application X need to be rebuilt due to an inconsistency between the connected Mac and the local app`
  * `Visual Studio cannot start the application automatically because it was signed with a Distribution provisioning profile. Please start it by tapping the application icon on the device`

### TL;DR

In my case it was because the "Bundle ID" aka "App ID" set in my info.plist was incompatible with the provisioning profiles actually available on my Mac build host and selected in the iOS project settings.

### More background

  1. My Provisioning Certificates had expired (as we know, issued from https://Developer.Apple.com) ... that did throw me off for a bit but eventually I got the clue and went through the Apple Developer account renewal process... 
  2. Funny thing, I'd been waiting for our Apple Enterprise Developer aka In House distribution account to finalize... I noticed it had finally opened up (_there's a big yellow sign indicating 2wk delay between approval and the corresponding "In House" radio button becoming available on the provisioning profile page_) and decided to just run with that vs my personal Developer keys...
  3. This meant I was creating all the necessary provisioning bits from scratch...
  4. First up, creating my App ID aka Bundle Id record (_cue foreboding thunderclap_)... 'course when you're establishing a new name, it's always fun to apply your more current understanding of just what that name should be... here's where I messed up, this <span class="hl">App ID gets embedded in the provisioning profile which must then be the same as what's in your iOS project's info.plist > CFBundleIdentifier entry !!</span>
  5. So while I did realize I needed to go select those new Identity/Provisioning profile entries in the iOS project settings > iOS Bundle Signing page, there's nothing obvious in the error messaging to smack us in the head about App Id conflict.

### Saving Grace

reading [this post][1]... suggested <u>compiling under Xamarin Studio on the Mac for more error visibility</u>... that's a good basic technique reminder... I also use Xcode for this at times... at this point we've got <span class="hl">Visual Studio for Mac so i fired that up and it did indeed provide significantly more helpful messaging, which got me back on track</span> &#8211; Good to know !

### Developer vs Distribution Profile &#8211; what's the difference?

Somehow I'd never really run smack into this but one pertinent difference _during development_ is that choosing a _Distribution_ Profile will require you to manually launch your app on the iOS Simulator vs Visual Studio being able to launch it for you... so choose a Developer profile until you're really in the mode to push builds out to real end user devices.

[![image][2]][2]

 [1]: https://stackoverflow.com/a/17999469/813599
 [2]: /images/uploads/2017/xamarin-ios-provisioning-gotchas-2c62a6f833f5.png