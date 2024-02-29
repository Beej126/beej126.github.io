---
title: External Content in Blogger Post
author: Beej
type: post
date: 2015-06-15T05:47:00+00:00
year: "2015"
month: "2015/06"
url: /2015/06/external-content-in-blogger-pos.html
blogger_bid:
  - 7726907200224433699
blogger_blog:
  - www.beejblog.com
blogger_id:
  - 426118917555111483
blogger_author:
  - g108832383968142578199
blogger_permalink:
  - /2015/06/external-content-in-blogger-post.html
dsq_thread_id:
  - 5517230291
categories:
tags:
  - Blogging

---
Highlights:

  * pull content from 3rd party source, using crossorigin.me (<a href="https://en.wikipedia.org/wiki/Cross-origin_resource_sharing" target="_blank">CORS</a> proxy) to avoid "no 'access-control-allow-origin' header is present on the requested resource"
  * from what i can glean, Blogger does not offer any kind of&nbsp;<a href="https://en.wikipedia.org/wiki/Server_Side_Includes" target="_blank">server side include</a>&nbsp;facility so we have to resort to client browser tricks and that means this content is NOT going to be crawled/googlable
  * this approach relies on jQuery (Core) so you'll need to have that referenced as well &#8211; <a href="https://www.jquerybyexample.net/2010/08/jquery-tip-always-load-your-jquery.html" target="_blank">example here</a>, but also make sure you point at the <a href="https://code.jquery.com/" target="_blank">latest version</a>

Usage:
  
drop this helper function in a global JS/HTML widget via the Blogger Layout editor...

<pre class="prettyprint linenums">function pluginContent(url, containerSelector, boolPrettyPrint) {
  var ctrl = $(containerSelector);
  $.get("https://crossorigin.me/"+url)
    .done(function (result) {
        ctrl.html(result);

        //force prettyPrint rendering after loading dynamic content
        // google on: "google code prettify" to get dialed in on this code syntax highlighting library
        // => https://code.google.com/p/google-code-prettify/wiki/GettingStarted
        if (boolPrettyPrint) {
          ctrl.removeClass("prettyprinted");
          PR.prettyPrint();
        }
    })
    .fail(function() {
      ctrl.html('failed to retrieve external content.'+
        'try going there directly: <a href="'+url+'">'+url+'</a>')
    });
}
</pre>

Then use it like this in an individual blogpost:

<pre class="prettyprint linenums"><pre class="prettyprint linenums lang-powershell" id="prePoshDualExplorers"></pre>

<script>
  //pull code content from codeplex
  pluginContent("https://beejpowershell.svn.codeplex.com/svn/PoshDualExplorers/PoshDualExplorers.ps1", "#prePoshDualExplorers", true);
</script>
</pre>