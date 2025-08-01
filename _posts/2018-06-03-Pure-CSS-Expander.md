---
url: /2018/06/pure-css-expander.html
title: "Minimal Pure CSS Expand/Collapse Widget"
author: Beej
type: post
description: ""
date: 2018-06-03T14:16:00-07:00
year: "2018"
month: "2018/06"
thumbnail: ""
categories:
tags:
  - WebDev
---

The gist here is leveraging a hidden checkbox to maintain expand/collapse state and css `:before {content: "xyz" }` to add the expand/collapse widget which keeps the additional markup minimal.

<style>
/*markdown renderers tend to add extra empty p tags*/
p:empty {
  display: none;
}

/* hide the native checkbox widget */
input.expander {
  opacity: 0;
  cursor: pointer;
  margin: 5px 0;
  position: absolute;
}

  /* main settings for the visible "expander" element */
  input.expander + p + *:before, /*handle extra p tag inserted after heading tags*/
  input.expander + *:not(p):before { /*everything else normal */
    content: "\f196 "; /*fa-plus-square-o - these codes can be found on the detail page for each fa icon*/
    font-family: FontAwesome;
    cursor: pointer;
    width: 1em;
    display: inline-block;
    /*font-size: larger;*/
    color: blue !important;
  }

  input.expander + p + * {
    display: inline-block;
  }

  input.expander + i {
    font-style: normal;
  }

  /* change the icon in the expanded state, i.e. checkbox checked = expanded */
  input.expander:checked + p + *:before,
  input.expander:checked + *:not(p):before {
    content: "\f147 "; /*fa-minus-square-o*/
  }

  /* alternative caret icon look */
  input.expander.caret + p + *:before,
  input.expander.caret + *:not(p):before {
    content: "\f0da";
  }

  input.expander.caret:checked + p + *:before,
  input.expander.caret:checked + *:not(p):before {
    content: "\f0d7";
  }

  input.expander + p + * + *,
  input.expander + *:not(p) + * {
    transition: all 0.5s ease-in-out;
  }

  input.expander:not(:checked) + p + * + *,
  input.expander:not(:checked) + *:not(p) + * {
    overflow-y: hidden;
    height: 0;
    transform: scaleX(0) scaleY(0);
    opacity: 0;
    margin: 0;
  }
</style>

### Markdown compatible :)
```markdown
<p></p><input type="checkbox" class="expander">
#### Expandified Heading
* bullet 
* bullet
* <input type="checkbox" class="expander"><i>another expander</i>
  * nested content that will be expanded
```
<!--more-->

_yeah i know, what's up with the the extra &lt;p&gt; tag pal?! those sprinkles on my minimalist-day parade are the only way i could get my blog's markdown renderer ([Hugo](https://gohugo.io/) &gt; "[Blackfriday](https://github.com/russross/blackfriday)") to not mangle the expander input under a p tag which ruins using css sibling selector used target the show/hide content_

### Rendered Markdown Demo...

<p></p><input type="checkbox" class="expander">
#### Expando Heading
* bullet 
* bullet
* <input type="checkbox" class="expander"><i>another expander</i>
  * nested content that will be expanded

[Not an original idea](https://css-tricks.com/the-checkbox-hack/#article-header-id-1) ... just boiling it down for my specific usage

For the record, it's not valid html to apply :before/after psuedo elements to form elements like &lt;input&gt; because they're not technically "content" ([stack-o reference](https://stackoverflow.com/questions/12831620/is-the-before-pseudo-element-allowed-on-an-inputtype-checkbox)), bummer... webkit (chrome, safari) actually do render directly on &lt;input&gt; but firefox & explorer don't... oh well, it's not much more to rely on one more element right after &lt;input&gt;... i'm using the &lt;i&gt; tag as popularized by font-awesome but this is arbitrary.

### [JS Fiddle Demo](https://jsfiddle.net/h3c3cb3m/110/)

### [Demo post (rendered via Markdown)](/osx-v2p.html)

