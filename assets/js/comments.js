// The archive is ordinary HTML. Network access only adds newer entries or replies.
document.addEventListener('DOMContentLoaded', function () {
  document.querySelectorAll('.blog-comments').forEach(function (section) {
    const list = section.querySelector('.static-comment-list');
    const details = section.querySelector('.live-discussion');
    const mount = section.querySelector('.utterances-mount');
    details.addEventListener('toggle', function () {
      if (!details.open || mount.dataset.loaded) return;
      mount.dataset.loaded = 'true';
      const script = document.createElement('script');
      script.src = 'https://utteranc.es/client.js';
      script.setAttribute('repo', mount.dataset.repository);
      if (mount.dataset.issueNumber) script.setAttribute('issue-number', mount.dataset.issueNumber);
      else script.setAttribute('issue-term', mount.dataset.issueTerm);
      script.setAttribute('theme', mount.dataset.theme);
      if (mount.dataset.label) script.setAttribute('label', mount.dataset.label);
      script.crossOrigin = 'anonymous';
      script.async = true;
      mount.append(script);
    });

    const button = section.querySelector('.comment-check-new');
    if (!button) return;
    const status = section.querySelector('.comment-update-status');
    const knownIds = new Set(Array.from(list.querySelectorAll('[data-github-comment-id]'), function (node) {
      return node.dataset.githubCommentId;
    }));
    let busy = false;
    button.hidden = false;

    async function checkNewComments() {
      if (busy) return;
      busy = true;
      button.disabled = true;
      status.textContent = 'Checking for newer comments…';
      let added = 0;
      try {
        for (let page = 1; ; page++) {
          const endpoint = new URL('https://api.github.com/repos/' + section.dataset.repository +
            '/issues/' + section.dataset.issueNumber + '/comments');
          endpoint.searchParams.set('per_page', '100');
          endpoint.searchParams.set('page', String(page));
          if (section.dataset.since) endpoint.searchParams.set('since', section.dataset.since);
          const response = await fetch(endpoint.href, { headers: { Accept: 'application/vnd.github.full+json' } });
          if (!response.ok) throw new Error('GitHub returned ' + response.status);
          const comments = await response.json();
          if (!Array.isArray(comments)) throw new Error('Invalid comment response');
          comments.forEach(function (comment) {
            const id = String(comment.id);
            if (knownIds.has(id)) return;
            list.append(renderComment(comment, knownIds));
            knownIds.add(id);
            added++;
          });
          // A parent can arrive later in the same API batch. Revisit new entries
          // after each page so their order or pagination does not lose nesting.
          list.querySelectorAll('.newer-comment').forEach(placeComment);
          if (comments.length < 100) break;
        }
        status.textContent = added ? added + ' newer comment' + (added === 1 ? '' : 's') + ' loaded.' : 'No newer comments.';
        section.querySelector('h2').textContent = 'Comments (' + knownIds.size + ')';
      } catch (error) {
        status.textContent = 'Live comments not responding (e.g. GitHub API rate limits, etc). View GitHub for the latest discussion.';
      } finally {
        busy = false;
        button.disabled = false;
      }
    }
    function placeComment(article) {
      const parentId = article.dataset.parentCommentId;
      const parent = parentId && document.getElementById('comment-' + parentId);
      let container = list;
      if (parent && list.contains(parent) && parent !== article && !article.contains(parent)) {
        container = parent.querySelector(':scope > .comment-replies');
        const link = article.querySelector(':scope > .blog-comment-header .comment-reply-link');
        if (link) link.remove();
      }
      if (!container) return;
      const next = Array.from(container.children).find(function (other) {
        return other !== article && other.dataset.published && other.dataset.published > article.dataset.published;
      });
      container.insertBefore(article, next || null);
    }
    button.addEventListener('click', checkNewComments);
    if ('IntersectionObserver' in window) {
      const observer = new IntersectionObserver(function (entries) {
        if (entries.some(function (entry) { return entry.isIntersecting; })) {
          observer.disconnect();
          checkNewComments();
        }
      }, { rootMargin: '200px' });
      observer.observe(section);
    } else checkNewComments();
  });

  function renderComment(comment, knownIds) {
    const template = document.createElement('template');
    template.innerHTML = comment.body_html || '';
    const fragment = template.content;
    let author = comment.user.login;
    let published = comment.created_at;
    let profile = comment.user.html_url;
    const first = fragment.querySelector('strong');
    const imported = first && first.textContent.match(/^Originally posted by (.+) on (\d{4}-\d{2}-\d{2}T\S+)$/);
    const isImported = imported && (comment.body || '').includes('<!-- disqus-comment:');
    if (isImported) {
      author = imported[1];
      published = imported[2];
      profile = null;
      const parent = first.parentElement;
      first.remove();
      if (parent.tagName === 'P' && !parent.textContent.trim() && !parent.children.length) parent.remove();
    }
    fragment.querySelectorAll('script, iframe, object, embed, style, link, form, input, button, textarea').forEach(function (node) { node.remove(); });
    fragment.querySelectorAll('*').forEach(function (node) {
      Array.from(node.attributes).forEach(function (attribute) {
        if (/^on/i.test(attribute.name) || ['style', 'srcdoc'].includes(attribute.name)) node.removeAttribute(attribute.name);
      });
    });
    fragment.querySelectorAll('img').forEach(function (image) {
      const link = document.createElement('a');
      link.textContent = image.alt || 'View attached image';
      const source = image.getAttribute('src') || '';
      if (/^https?:\/\//i.test(source)) link.href = source;
      image.replaceWith(link);
    });
    fragment.querySelectorAll('a[href]').forEach(function (link) {
      const href = link.getAttribute('href');
      if (!/^(https?:|mailto:|#)/i.test(href)) link.removeAttribute('href');
      const parent = href.match(/#issuecomment-(\d+)$/);
      if (parent && knownIds.has(parent[1])) link.href = '#comment-' + parent[1];
      link.rel = 'nofollow ugc';
    });
    let replyHref = null;
    const paragraph = fragment.firstElementChild;
    if (isImported && paragraph && paragraph.tagName === 'P' && paragraph.textContent.trim() === 'Reply to an earlier comment.') {
      const links = paragraph.querySelectorAll('a[href]');
      if (links.length === 1 && links[0].textContent === 'an earlier comment') {
        replyHref = links[0].getAttribute('href');
        paragraph.remove();
      }
    }
    const article = document.createElement('article');
    article.className = 'blog-comment newer-comment';
    article.id = 'comment-' + comment.id;
    article.dataset.githubCommentId = String(comment.id);
    article.dataset.published = published;
    const parentMatch = replyHref && replyHref.match(/#(?:comment-|issuecomment-)(\d+)$/);
    if (parentMatch) article.dataset.parentCommentId = parentMatch[1];
    const header = document.createElement('header');
    header.className = 'blog-comment-header';
    const name = document.createElement('strong');
    if (profile) {
      const link = document.createElement('a');
      link.href = profile;
      link.rel = 'nofollow ugc';
      link.textContent = author;
      name.append(link);
    } else name.textContent = author;
    const time = document.createElement('time');
    time.dateTime = published;
    time.textContent = new Date(published).toLocaleDateString(undefined, { year: 'numeric', month: 'long', day: 'numeric', timeZone: 'UTC' });
    header.append(name, time);
    if (replyHref) {
      const reply = document.createElement('a');
      reply.className = 'comment-reply-link';
      reply.href = replyHref;
      reply.rel = 'nofollow ugc';
      reply.textContent = 'replying to...';
      header.append(reply);
    }
    const body = document.createElement('div');
    body.className = 'blog-comment-body';
    body.append(fragment);
    const replies = document.createElement('div');
    replies.className = 'comment-replies';
    article.append(header, body, replies);
    return article;
  }
});
