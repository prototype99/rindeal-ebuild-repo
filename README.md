Rindeal's Gentoo Overlay
==========================
[![Build Status](https://img.shields.io/travis/rindeal/gentoo-overlay/master.svg?style=flat-square&label=repoman full)](https://travis-ci.org/rindeal/gentoo-overlay)

Repository consists mostly of packages I haven't found anywhere else, more up-to-date versions of official packages,
or ebuilds with features enhanced to my liking. In each _category/package directory_ you should find a _README_ file
describing the exact reason of its inclusion in this repository. If not then it probably means that it's simply a new package.

For a full package listing see [LISTING] \(don't hesitate, it's nice).

Highlights
-----------

### [Telegram]
My package is the only source-based package for _Telegram Desktop_ app, the others are just pre-built binaries.

### [JetBrains IntelliJ Platform](http://www.jetbrains.org/pages/viewpage.action?pageId=983889)
I've created a special eclass for _IntelliJ_ based IDEs, which allows to easily add and update any such IDE,
while still providing features like slotting and component unbundling (JRE, CMake, GDB, ...) using USE-flags.


Stability
----------

I am trying to maintain high quality and stable ebuilds here.
To achieve this goal I'm using several safety guards:

- _[Travis CI]_, which runs _[repoman]_
    checks against every `git push`
- all points of _GitHub_'s feature called [protected branches],
    which means that all merges to _master_ have to be repoman-valid

This all, of course, doesn't prevent build failures, missing dependencies, etc. So, should you find
some issues, send me a PR (if you know how to fix it), or at least [fill an issue][New issue].


How to install this overlay
----------------------------

### Layman

```sh
layman -o 'https://github.com/rindeal/gentoo-overlay/raw/master/repositories.xml' -a rindeal
```

or simply

```sh
layman -a rindeal
```

### Manually
Add an entry to `/etc/portage/repos.conf`:
```ini
[rindeal]
## set this to any location you want
location = /usr/local/portage/rindeal
sync-uri = https://github.com/rindeal/gentoo-overlay.git
## or if you don't mind a small delay, you might use gentoo-mirror which includes metadata cache
#sync-uri =  https://github.com/gentoo-mirror/rindeal.git
sync-type = git
auto-sync = yes
```


[protected branches]: https://help.github.com/articles/about-protected-branches/
[repoman]: https://wiki.gentoo.org/wiki/Repoman
[Travis CI]: https://travis-ci.org/
[LISTING]: ./LISTING.md
[New issue]: https://github.com/rindeal/gentoo-overlay/issues/new
[Telegram]: https://desktop.telegram.org/
