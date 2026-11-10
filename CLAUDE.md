# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

StarLardWeb is a static portfolio website built with Jekyll and its own small theme (no third-party theme). It showcases iOS apps and blog posts. Hosted on Firebase Hosting with automatic deployment via GitHub Actions.

## Common Commands

### Setup
```bash
cat .ruby-version | rbenv install --skip-existing
gem install bundler
bundle install
```

### Development
```bash
# Serve locally with Jekyll (auto-reloads on changes)
bundle exec jekyll serve

# Build site (generates _site directory)
bundle exec jekyll build

# Serve with Firebase emulator (requires build first)
firebase emulators:start --only hosting:starlarddev
```

### Deployment
Automatic deployment occurs on merge to main via GitHub Actions. Manual deploy:
```bash
firebase deploy --only hosting --project dev-starlard-lard-lad
```

## Architecture

- **Theme**: Custom, in `_layouts`, `_includes` and `_sass`. Styles follow the Star Lard design system: red, white and black with yellow only as an accent; square boards with a 3px outline and hard offset shadows; Yellowtail script, Bowlby One labels, Figtree body text.
- **Themes**: Light and Dark via CSS custom properties in `_sass/_tokens.scss`, switched by `data-theme` on `<html>`. The inline script in `_includes/head.html` applies the visitor's choice (Auto, Light or Dark from the footer picker) before the page draws. Always style with tokens, never fixed colors.
- **Home page**: `index.md` (copy) with the `home` layout, which includes `_includes/sections/*`. App and experience content lives in `_data/apps.yml` and `_data/experience.yml`.
- **Posts**: `_posts/`, `post` layout by default, served at `/posts/:title/`. The Posts index is `_pages/posts.md`.
- **Redirects**: old `/portfolio/*` app pages and tag, category and year archives redirect in `firebase.json`.
- **Assets**: Images in `assets/images/`; one stylesheet `assets/css/main.scss`; `assets/js/theme.js` for the theme picker and code copy buttons.
- **Build output**: `_site/` directory (deployed to Firebase)

## Content Conventions

### Posts
- Location: `_posts/`
- Naming: `YEAR-MONTH-DAY-title.md`
- Front matter: `title`, `date`, `description` (one sentence, used on cards and in SEO), `categories`, `tags`

### Apps
- Location: `_data/apps.yml`
- Fields: `name`, `url`, `icon`, `platforms`, `pitch`; one app may be `featured: true` with `image`, `image_alt`, `action` and an optional `tag`

### Code Snippets in Posts
Use Jekyll's highlight tag or fenced code blocks:
```
{% highlight swift %}
print("Hello World!")
{% endhighlight %}
```

## Key Configuration

- `_config.yml`: Main Jekyll configuration (requires server restart on changes)
- `firebase.json`: Firebase hosting configuration (public directory: `_site`)
