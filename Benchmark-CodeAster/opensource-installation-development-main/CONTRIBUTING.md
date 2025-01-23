# How to contribute

Summary

[[_TOC_]]

Anyone can contribute to this documentation as long as you follow the
rules. Since it is currently being put in place, the rules are not all
set yet.

## Files tree

- Each section has its own directory.

- Subsections are in subdirectories of their parent section...

- Images are added in the subdirectory `images` of the section.
  Do not add images that will be obsolete in two weeks.

## Rules

- Each page must contain a *Summary*:

  ```markdown
  # Page title

  Eventually, a short introduction...

  Summary

  [[_TOC_]]

  ## First subtitle
  ...
  ```

- Note block using:

  ```markdown
  > **NOTE:** Important information...
  ```

- Markdown syntax is the [GitLab Flavored Markdown](https://docs.gitlab.com/ee/user/markdown.html).

- Use minimal formatting, no html.

- Avoid long lines (max. 100 columns).

## Share your changes

Contributions are welcomed using *Merge-Requests* in the GitLab repository.

You can request access to the repository to be able to push a branch with your modifications.
Sign-in on GitLab.com and use the **Request Access** link on the main page of the project:

![request access](./images/request-access.png)

You can also fork the repository.

Then, create a merge-request.

Read the GitLab docs for more details, for example:

- [Issues](https://docs.gitlab.com/ee/user/project/issues/)

- [Merge Requests](https://docs.gitlab.com/ee/user/project/merge_requests/)
