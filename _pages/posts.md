---
layout: page
title: "Posts"
permalink: /posts/
description: "Notes on iOS development and launching indie apps."
---
<div class="sl-page__head">
  <div class="sl-sign"><h1 class="sl-sign__text">All Posts</h1></div>
  <p class="sl-sign__sub">Notes on iOS development and launching indie apps.</p>
</div>
<div class="sl-posts">
  {%- for post in site.posts %}
  {% include post-card.html post=post %}
  {%- endfor %}
</div>
