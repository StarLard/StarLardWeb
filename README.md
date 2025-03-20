# StarLardWeb

Source code for the [starlard.dev](https://starlard.dev) website.

## Overview

StarLardWeb is a static website, built using [Jekyll](https://jekyllrb.com). The project is organized using standard Jekyll conventions and depend

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

## Deploy

Deployment is managed automatically upon merging to main via GitHub actions.

### Manual deploy

When required, deployment can also be done locally by running `firebase deploy --only hosting --project dev-starlard-lard-lad`.

## Contributing

This site uses the Minimal Mistakes Jekyll theme. See the [documentation](https://mmistakes.github.io/minimal-mistakes/docs/quick-start-guide/) for detailed configuration options.

### Pages

Create pages in the `_pages` directory and add paths for any new pages in `_data/navigation.yml`.

Pages shoudld contain a [Front Matter](https://jekyllrb.com/docs/front-matter/) header like the following at the top of the file:
```
---
layout: <layout>
title: About
permalink: /about/
---
```
Layout options are described [here](https://mmistakes.github.io/minimal-mistakes/docs/layouts/).

### Posts

Create posts in the `_posts` directory.

Jekyll requires blog post files to be named according to the following format:

`YEAR-MONTH-DAY-title.MARKUP`

Where `YEAR` is a four-digit number, `MONTH` and `DAY` are both two-digit numbers, and `MARKUP` is the file extension representing the format used in the file. After that, include the necessary front matter.

Posts shoudld contain the a [Front Matter](https://jekyllrb.com/docs/front-matter/) header like the following at the top of the file:
```
---
layout: <layout>
title:  "Welcome to Jekyll!"
date:   2025-02-03 16:05:45 -0800
categories: <space seperated list of categories>
tags: swift <space seperated list of tags>
---
```

#### Formatting

Jekyll offers support for code snippets:
```
{% highlight swift %}
print("Hello World!")
{% endhighlight %}
```

### Images

Put images in `assets/images`

## Technical Design

This site initially existed as a React app, which was initially chosen to serve as a learning mechanism for JS, but that proved burdensome to maintain and was overkill for the website's actual requirements given I had no dynamic content. Being an iOS developer, I investigated using Swift-based solutions, such as [Publish](https://github.com/JohnSundell/Publish) and [Vapor](https://github.com/vapor/vapor), but found that doing so recreated the issues I was having with React: I wanted something lightweight and easy to maintain so that I could spend more time working on projects that interest me; not maintaing a website. Hence, Jekyll was chosen due to its broad popularity, community support, and development velocity. Currently, it is hosted using using [Firebase Hosting](https://firebase.google.com/docs/hosting), since they offer free hosting and great performance for my use case.

# Credits

[Jekyll](https://github.com/jekyll/jekyll)

# License

All source code and content contained here-in are copyright of Caleb Friden, provided for demonstration purposes only, and not intended for distribution. 