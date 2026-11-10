# StarLardWeb

Source code for the [starlard.dev](https://starlard.dev) website.

## Overview

StarLardWeb is a static website built with [Jekyll](https://jekyllrb.com) and its own small theme, styled from the Star Lard design system (a 1950s food-brand look: red script on white sign boards, black outlines, a yellow star). The homepage is a single scrolling page with hero, apps, experience, posts and about sections. Visitors can pick Auto, Light or Dark in the footer.

## Set up

1. Install [rbenv](https://github.com/rbenv/rbenv) (or your prefered ruby version manager)
2. Install the required ruby version from [.ruby-version](https://github.com/StarLard/StarLardWeb/blob/main/.ruby-version): `cat .ruby-version | rbenv install --skip-existing`
3. Install Bundler: `gem install bundler`
4. Install gem dependencies: `bundle install`

## Serve

### Jekyll
1. [Serve](https://jekyllrb.com/tutorials/using-jekyll-with-bundler/#serve-the-site) the site with `bundle exec jekyll serve`
2. Visit the site locally at http://127.0.0.1:4000/ (or whatever address is printed in the console)

### Firebase
If you have the [Firebase CLI](https://firebase.google.com/docs/cli#install_the_firebase_cli) installed, you an also serve the site with firebase.
1. Build the site with `bundle exec jekyll build`
2. Serve the site with `firebase emulators:start --only hosting:starlarddev`
2. Visit the site locally at 127.0.0.1:5002 (or whatever address is printed in the console)

## Test

Run `bundle exec rake test`. It builds the site, then:

1. Checks every built page with [html-proofer](https://github.com/gjtorikian/html-proofer) for broken internal links and `#anchors`, missing images or `alt` text, and malformed HTML. External links aren't checked, since sites like the App Store often block automated requests.
2. Runs `test/site_test.rb`, which checks what html-proofer can't see: every app in `_data/apps.yml` is complete and on the home page with exactly one featured, every nav link has a section, the theme picker and theme script are in place, every post has a description and is built at its URL and listed on `/posts/`, the feed and sitemap are complete, and the redirects in `firebase.json` send old URLs where they should.

`bundle exec rake proof` and `bundle exec rake site_tests` run each half on its own. CI runs `rake test` on every pull request and before every deploy, so a failing test blocks the deploy.

## Deploy

Deployment is managed automatically upon merging to main via GitHub actions.

### Manual deploy

When required, deployment can also be done locally by running `firebase deploy --only hosting --project dev-starlard-lard-lad`.

## Contributing

### Project Structure

```
_config.yml             # Site settings, permalinks and plugins
index.md                # Home page copy: hero, intro and About text
_data/
  apps.yml              # Apps section; the app marked `featured` gets the wide card
  experience.yml        # Experience section, newest first
  navigation.yml        # Header links

_layouts/
  default.html          # Page frame: head, header, footer
  home.html             # The home page sections
  post.html             # A blog post
  page.html             # Simple pages (Posts index, 404)

_includes/
  head.html             # Meta, SEO tags, fonts, styles, and the script that applies the theme before the page draws
  header.html
  footer.html           # Includes the Auto / Light / Dark theme picker
  post-card.html
  star.html             # The brand star icon
  sections/             # hero, apps, experience, posts, about

_sass/
  _tokens.scss          # Colors, type, spacing and shadows for Light and Dark
  _base.scss            # Reset and page basics
  _components.scss      # Buttons, sign headings, cards, tags, theme picker
  _layout.scss          # Header, footer and home page sections
  _article.scss         # Posts, Posts index and 404
  _syntax.scss          # Code highlighting colors

assets/
  css/main.scss         # Compiles the partials above
  js/theme.js           # Wires the theme picker and code copy buttons

Rakefile                # build, proof and test tasks
test/
  site_test.rb          # Content, redirect, feed and sitemap tests
```

### Themes

Colors are CSS custom properties in `_sass/_tokens.scss`. Light values sit on `:root`; Dark values apply when `<html data-theme="dark">`. The inline script in `_includes/head.html` sets `data-theme` from the visitor's saved choice (`localStorage` key `sl-theme`), or from the system on Auto. Style new components with the tokens, never fixed colors, so they work in both themes.

### Apps

Edit `_data/apps.yml`. Each app needs a `name`, `url`, `icon`, `platforms` and `pitch`. Mark one app `featured: true` (with an `image`, `action` and optional `tag`) to show it in the wide card at the top.

Old app pages under `/portfolio/` redirect to each app's own site, and the old tag, category and year archives redirect to `/posts/`. The redirects live in `firebase.json`.

### Pages

Create pages in the `_pages` directory with the `page` layout, and add them to `_data/navigation.yml` if they belong in the header.

```
---
layout: page
title: About
permalink: /about/
---
```

### Posts

Create posts in the `_posts` directory, named `YEAR-MONTH-DAY-title.md`. Posts use the `post` layout automatically and are served at `/posts/:title/`.

```
---
title:  "Welcome to Jekyll!"
date:   2025-02-03 16:05:45 -0800
description: "One sentence for post cards, search results and social previews."
categories: iOS
tags: swift ios
---
```

#### Formatting

Fenced code blocks and Jekyll's highlight tag both work, and get a Copy button:
```
{% highlight swift %}
print("Hello World!")
{% endhighlight %}
```

### Images

Put images in `assets/images`

## Technical Design

This site initially existed as a React app, which was initially chosen to serve as a learning mechanism for JS, but that proved burdensome to maintain and was overkill for the website's actual requirements given I had no dynamic content. Being an iOS developer, I investigated using Swift-based solutions, such as [Publish](https://github.com/JohnSundell/Publish) and [Vapor](https://github.com/vapor/vapor), but found that doing so recreated the issues I was having with React: I wanted something lightweight and easy to maintain so that I could spend more time working on projects that interest me; not maintaing a website. Hence, Jekyll was chosen due to its broad popularity, community support, and development velocity. The site started on the Minimal Mistakes theme; after the 2026 redesign it uses its own small theme instead, since the custom design had replaced nearly everything the theme provided and its two-stylesheet dark mode couldn't support a theme picker. Currently, it is hosted using using [Firebase Hosting](https://firebase.google.com/docs/hosting), since they offer free hosting and great performance for my use case.

# Credits

[Jekyll](https://github.com/jekyll/jekyll), [jekyll-seo-tag](https://github.com/jekyll/jekyll-seo-tag), [jekyll-feed](https://github.com/jekyll/jekyll-feed), [jekyll-sitemap](https://github.com/jekyll/jekyll-sitemap). Fonts: Yellowtail, Bowlby One and Figtree from Google Fonts.

# License

All source code and content contained here-in are copyright of Caleb Friden, provided for demonstration purposes only, and not intended for distribution. 