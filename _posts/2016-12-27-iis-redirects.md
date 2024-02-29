---
title: Cleanly driving SSL and WWW prefix on IIS
author: Beej
type: post
date: 2016-12-27T20:53:05+00:00
year: "2016"
month: "2016/12"
url: /2016/12/iis-redirects.html
snap_isAutoPosted:
  - 1
snapEdIT:
  - 1
snapTW:
  - 's:312:"a:1:{i:0;a:11:{s:2:"do";s:1:"1";s:9:"timeToRun";s:0:"";s:10:"SNAPformat";s:15:"%TITLE% - %URL%";s:8:"attchImg";s:1:"1";s:9:"isAutoImg";s:1:"A";s:8:"imgToUse";s:0:"";s:4:"doTW";s:1:"1";s:11:"isPrePosted";s:1:"1";s:8:"isPosted";s:1:"1";s:4:"pgID";s:18:"813850275500855296";s:5:"pDate";s:19:"2016-12-27 20:53:22";}}";'
dsq_thread_id:
  - 5597202286
categories:
tags:
  - IIS

---
### Background

Infrequently enough to forget, I find the need to redirect all non-SSL requests to SSL... or similarly, force the WWW prefix onto a url when the initial navigation comes in without it.
  
I instinctively reach for the URLRewrite module due to it's flexibility, but i've found that it can actually lead me astray in these particular scenarios...

### TL;DR

Create a separate IIS web site for the "undesirable" url which does a simple HTTP Redirect to the desired path

### Elaboration

Especially in the case of SSL, this is definitely the way to go because you'll also want to enable "Require SSL" ... which outright prevents the the non-ssl url from being able to respond with a URLRewrite Rule... i.e. the Require SSL checkbox yields a hard 403 error immediately upon resolving the non-SSL path, no other logic executes... and at this point, the IIS admin console just stares back blankly awaiting orders with no help out of this blind alley.

### Security bonus

by creating a site entirely for the non-ssl redirect, we can then set that site's physical path to something harmless, leaving no doubt the SSL URL is the only way in to our sensitive physical path.

### Separate Physical Folder FOR EACH SITE

To be perfectly clear, each redirecting sites' physical folder will now merely provide containment for its corresponding solitary web.config, yet it is crucial each site is indeed configured with a unique physical path and web.config... this is obvious once considered but can be a momentary point of confusion until one realizes why all the different sites' settings are overlapping 🙂