---
layout: page
permalink: /publications/
title: Publications

description: 
nav: true
nav_order: 1
---
<!-- _pages/publications.md -->
<a href='https://scholar.google.co.uk/citations?user=dwvkuEAAAAAJ&hl=en' style="font-size: 1.5rem;"><i class="ai ai-google-scholar" style="font-size: 1.5rem;"></i> Google scholar</a>

<div class="publications">

{% bibliography -f {{ site.scholar.bibliography }} %}

</div>

[comment]: Edit links to co-authors in ./_data/coauthors.yml