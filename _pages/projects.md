---
layout: page
title: Projects and Repos
permalink: /projects/
description: 
nav: true
nav_order: 2
display_categories: 
horizontal: false
---

[comment]: Edit the `_data/repositories.yml` and change the `github_users` and `github_repos` lists to include your own GitHub profile and repositories.

## Recorded talks

<a href="https://www.youtube.com/watch?v=zy0vBngeTJQ"><i class="fab fa-youtube" style="color:red"></i></a> March 2025, <a href="https://www.youtube.com/watch?v=zy0vBngeTJQ">John Hopkins Cerebellum Seminars</a> <br>
<a href="https://mediacentral.ucl.ac.uk/Play/112817"><i class="fab fa-youtube" style="color:red"></i></a> June 2024, <a href="https://mediacentral.ucl.ac.uk/Play/112817">Jon Driver Prize Winner Talk</a> <br>
<a href="https://www.youtube.com/watch?v=hjuufbEm42g"><i class="fab fa-youtube" style="color:red"></i></a> October 2022, <a href="https://www.youtube.com/watch?v=hjuufbEm42g">UCL Neuropixels Course</a>

## Repositories

<!-- {% if site.data.repositories.github_users %}
<div class="repositories d-flex flex-wrap flex-md-row flex-column justify-content-between align-items-center">
  {% for user in site.data.repositories.github_users %}
    {% include repository/repo_user.html username=user %}
  {% endfor %}
</div>
{% endif %} -->

{% if site.data.repositories.github_repos %}
<div class="repositories d-flex flex-wrap flex-md-row flex-column justify-content-between align-items-center">
  {% for repo in site.data.repositories.github_repos %}
    {% include repository/repo.html repository=repo %}
  {% endfor %}
</div>
{% endif %}


## Ongoing projects

<!-- pages/projects.md -->
<div class="projects">
{%- if site.enable_project_categories and page.display_categories %}
  <!-- Display categorized projects -->
  {%- for category in page.display_categories %}
  <h2 class="category">{{ category }}</h2>
  {%- assign categorized_projects = site.projects | where: "category", category -%}
  {%- assign sorted_projects = categorized_projects | sort: "importance" %}
  <!-- Generate cards for each project -->
  {% if page.horizontal -%}
  <div class="container">
    <div class="row row-cols-2">
    {%- for project in sorted_projects -%}
      {% include projects_horizontal.html %}
    {%- endfor %}
    </div>
  </div>
  {%- else -%}
  <div class="grid">
    {%- for project in sorted_projects -%}
      {% include projects.html %}
    {%- endfor %}
  </div>
  {%- endif -%}
  {% endfor %}

{%- else -%}
<!-- Display projects without categories -->
  {%- assign sorted_projects = site.projects | sort: "importance" -%}
  <!-- Generate cards for each project -->
  {% if page.horizontal -%}
  <div class="container">
    <div class="row row-cols-2">
    {%- for project in sorted_projects -%}
      {% include projects_horizontal.html %}
    {%- endfor %}
    </div>
  </div>
  {%- else -%}
  <div class="grid">
    {%- for project in sorted_projects -%}
      {% include projects.html %}
    {%- endfor %}
  </div>
  {%- endif -%}
{%- endif -%}
</div>
