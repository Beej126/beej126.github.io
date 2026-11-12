---
title: Chrome User Script – Whack page elements based on jQuery selectors
date: 2015-11-09
author: Beej
tags:
  - WebDev
thumbnail-img: /images/uploads/2015/chrome-user-script-whack-page-elements-thumbnail.png
---
  * Tweaked this solution: [How can I use jQuery in Greasemonkey scripts in Google Chrome?][1]
  * Install: 
      1. save this as something.**user**.js - the "user.js" is critical for Chrome to accept
      2. navigate to chrome://extensions/
      3. drag/drop the file to the Chrome Extensions page

<pre class="prettyprint">// ==UserScript==
// @name VipLeague.se AdBlock Hack
// @match https://www.vipleague.se/*
// ==/UserScript==

function addJQuery(callback) {
  var script = document.createElement("script");
  script.setAttribute("src", "https://code.jquery.com/jquery-2.1.4.min.js");
  script.addEventListener('load', function() {
    var script = document.createElement("script");
    script.textContent = "(" + callback.toString() + ")();";
    document.body.appendChild(script);
  }, false);
  document.body.appendChild(script);
}

function main() {
  $("span:contains('Adblock is enabled')").remove();
}

// load jQuery and execute the main function
addJQuery(main);</pre>

![enter image description here][2]
  
![enter image description here][3]

 [1]: https://stackoverflow.com/questions/2246901/how-can-i-use-jquery-in-greasemonkey-scripts-in-google-chrome
 [2]: {{ site.baseurl }}/images/uploads/2015/11/Snap2.png ""
 [3]: {{ site.baseurl }}/images/uploads/2015/11/Snap4-1.png ""