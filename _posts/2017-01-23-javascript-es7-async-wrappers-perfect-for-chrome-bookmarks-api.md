---
title: JavaScript (ES7) async wrappers perfect for Chrome.Bookmarks API
date: 2017-01-23
author: Beej
tags:
  - WebDev
---
### Background:

I tasked myself with a little project to sync my Chrome Bookmarks Bar with my [Diigo links][1].

![image][2]

Chrome's Bookmarks API is very straightforward but it is a traditional async callback style call... so it became a good opportunity for me to cozy up to [EcmaScript v7's (ES7) async/await support][3]... since this is done in a Chrome Extension, it lends itself to this hard dependency on ES7 syntax...

async/await is supported as of [Chrome v55 in Dec.2016][4]

to me, the basic gist of this shift to async away from traditional callbacks means that we get to flatten all those nested callbacks like this:

```js
call_method1(function(response1){
  call_method2(function(response2){
  });
});
```

to this:

```js
let response1 = await call_method1();
let response2 = await call_method2();
```

admittedly, maybe not super dramatic when you boil it down like that but it really feels like previously complex nested code is easier to read/maintain and modularize when this is now available

### Great async reference articles:

  * [Async functions &#8211; making promises friendly][5]
  * [Understand promises before you start using async/await][6]

### Code Nugget:

_I want to elaborate further on the very happily working Diigo solution, but for now just the basic async bits..._

```js
//here's the wrapper
//one main thing to be aware of is that the native Promise object is what we can "await" on
function createBookmarkAsync(parms) {
  return new Promise(function(fulfill, reject) {
    chrome.bookmarks.create(parms, fulfill);
  });
}

//simple usage of the above wrapper
$('#btnRefreshDiigo').click(async function() { //CRITICAL = note the "async" before the function declaration... otherwise google unhelpfully reports that await is an undeclared identifier
  let diigoFolderId = (await createBookmarkAsync({parentId: "1", title: "Diigos"})).id;
  //now continue coding knowing that this code wont execute until the async call returns, very cool!!
}
```

### Also handy for Fetch() API:

_it was also great to use the very nicely straightforward new'ish [Fetch API (Chrome v43+)][7] and await on that response vs something like jquery.ajax_

```js
let response = await fetch(json_api_url, { credentials: 'include' }); //the credentials bit passes existing cookies (e.g. leveraging existing login)
let jsonText = await response.text();
let items = JSON.parse(jsonText).items;
```

 [1]: https://www.diigo.com/
 [2]: /images/uploads/2017/javascript-es7-async-wrappers-perfect-for-chrome-bookmarks-api-bd667035386f.png
 [3]: https://tc39.github.io/ecmascript-asyncawait/
 [4]: https://www.chromestatus.com/feature/5643236399906816
 [5]: https://developers.google.com/web/fundamentals/getting-started/primers/async-functions
 [6]: https://medium.com/@bluepnume/learn-about-promises-before-you-start-using-async-await-eb148164a9c8#.jnvfjg2us
 [7]: https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API