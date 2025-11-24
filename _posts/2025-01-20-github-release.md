---
title: Squashing commits & a simple GitHub release/notes workflow
date: 2025-01-20
type: post
author: Beej
tags:
  - Dev
thumbnail-img: https://github.com/user-attachments/assets/038ece87-925e-40e4-a089-aa15be019ea8
---

- [GitHub Desktop](https://desktop.github.com/download/) offers a really convenient UI for squashing commits
  - in a nutshell, you might want to squash when you make a lot of little edits to things like README.MD and you want that to all look like one clean save event in the commit history =)
  - easy steps:
    1. load your repo
    1. make sure you fetch the latest via far right button on upper toolbar
    1. nav into the history tab
    1. the commits you want to combine via shift+left_mouse
    1. right mouse one of the commits and select "squash" - tips here:
       - right mouse the one with the description you prefer
       -  make sure to clean up the description box before pushing back to origin
    1. lastly, push the mods back up via the far right toolbar button
    ![image](https://github.com/user-attachments/assets/038ece87-925e-40e4-a089-aa15be019ea8){:width="400px"}
- see this minimal [custom github workflow](https://github.com/Beej126/KingstonFuryRgbCLI/blob/main/.github/workflows/build-release.yml) for my simple take on rolling the commit messages into release notes along with a compiled build zipped into an "asset" attached to each release
  - i'm choosing to make the release a manual launch vs pure CD upon commit so i can take the time to squash before creating the release
  - having clean commits via squashing plays right into using them direcctly for release notes
  - there's lots of stuff out there for leveraging milestones, issues & PRs for more sophisticated release/notes process, this is meant to be for small personal projects
