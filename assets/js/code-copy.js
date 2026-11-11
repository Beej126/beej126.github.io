// Add copy controls without making static code depend on JavaScript.
document.addEventListener('DOMContentLoaded', function () {
  document.querySelectorAll('.remote-gist-source').forEach(function (link) {
    link.addEventListener('click', function (event) {
      if (event.ctrlKey || event.metaKey || event.shiftKey || event.altKey) return;
      const sourceWindow = window.open(link.href, link.target);
      if (sourceWindow) {
        event.preventDefault();
        sourceWindow.focus();
      }
    });
  });

  const lineLinks = document.querySelectorAll('.gist-line-number');
  if (lineLinks.length) {
    const feedback = document.createElement('div');
    feedback.className = 'code-link-toast';
    feedback.setAttribute('role', 'status');
    feedback.hidden = true;
    document.body.append(feedback);
    let feedbackTimer;

    lineLinks.forEach(function (link) {
      const label = 'Copy link to line ' + link.getAttribute('data-line-number');
      link.setAttribute('aria-label', label);
      link.title = label;
      link.addEventListener('click', async function (event) {
        // Preserve modified clicks and the native context menu for opening links.
        if (event.ctrlKey || event.metaKey || event.shiftKey || event.altKey) return;
        event.preventDefault();
        clearTimeout(feedbackTimer);
        try {
          await navigator.clipboard.writeText(link.href);
          feedback.textContent = 'Link copied';
        } catch (error) {
          feedback.textContent = 'Could not copy. Right-click the number and copy its link.';
        }
        const position = link.getBoundingClientRect();
        feedback.style.left = Math.max(8, Math.min(position.right + 8, window.innerWidth - 288)) + 'px';
        feedback.style.top = Math.max(8, Math.min(position.top, window.innerHeight - 64)) + 'px';
        feedback.hidden = false;
        feedbackTimer = setTimeout(function () { feedback.hidden = true; }, 2500);
      });
    });
  }

  document.querySelectorAll('.highlighter-rouge').forEach(function (block) {
    const code = block.querySelector('pre code');
    if (!code || block.dataset.codeControlsReady) return;
    block.dataset.codeControlsReady = 'true';

    const toolbar = document.createElement('span');
    toolbar.className = 'code-toolbar';
    const status = document.createElement('span');
    status.className = 'code-copy-status';
    status.setAttribute('role', 'status');
    const button = document.createElement('button');
    button.type = 'button';
    button.className = 'code-copy-button';
    button.textContent = 'Copy';
    button.setAttribute('aria-label', 'Copy code to clipboard');
    const wrapButton = document.createElement('button');
    wrapButton.type = 'button';
    wrapButton.className = 'code-wrap-button';
    wrapButton.textContent = 'No wrap';
    wrapButton.setAttribute('aria-label', 'Wrap long code lines');
    wrapButton.setAttribute('aria-pressed', 'true');
    wrapButton.addEventListener('click', function () {
      const wrapping = block.classList.toggle('code-wrap');
      wrapButton.setAttribute('aria-pressed', String(wrapping));
      wrapButton.textContent = wrapping ? 'No wrap' : 'Wrap lines';
    });
    toolbar.append(status, wrapButton, button);
    const fileHeading = block.previousElementSibling;
    if (fileHeading && fileHeading.classList.contains('remote-gist-file-heading')) {
      toolbar.classList.add('code-toolbar-inline');
      fileHeading.append(toolbar);
    } else {
      block.prepend(toolbar);
      block.classList.add('has-code-toolbar');
    }
    block.classList.add('code-wrap');

    let resetTimer;
    button.addEventListener('click', async function () {
      clearTimeout(resetTimer);
      button.disabled = true;
      status.textContent = '';
      try {
        // textContent preserves whitespace and excludes the separate number gutter.
        await navigator.clipboard.writeText(code.textContent);
        button.textContent = 'Copied!';
        status.textContent = 'Code copied.';
      } catch (error) {
        // If clipboard permission is unavailable, select the code for manual copying.
        const range = document.createRange();
        range.selectNodeContents(code);
        const selection = window.getSelection();
        selection.removeAllRanges();
        selection.addRange(range);
        button.textContent = 'Copy';
        status.textContent = 'Code selected. Press Ctrl+C or Command+C to copy.';
      } finally {
        button.disabled = false;
        resetTimer = setTimeout(function () {
          button.textContent = 'Copy';
          status.textContent = '';
        }, 4000);
      }
    });
  });
});
