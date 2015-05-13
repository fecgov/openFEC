## Team Processes

* Use PEP8 as the coding standard for Python (but don't worry about fitting lines within 79 characters).
* Pull requests for all commits, even typos.
* Don't merge your own pull request. Find a friend to review your code and merge your pull request.
* Pull requests contain some tests. Ideally they would contain decent test coverage.

### Issues

When creating a task through the issue tracker, please include the following where applicable: 

* A summary of identified tasks related to the issue; and
* Any dependencies related to completion of the task (include links to tickets with the dependency).

Design and feature request issues should include:
* What the goal of the task being accomplished is; and
* The user need being addressed.

#### Development issues should include:
* Unknowns tasks or dependencies that need investigation; and
* [The boilerplate tasks for each development issue](https://gist.github.com/theresaanna/86be7e29214a7f31ab73).

Use checklists (via `- [ ]`) to keep track of sub-items wherever possible.


### Commit messages

- Usually start with a verb. Like “added” or “changed” or “removed”.
- Generally follow [50/72 format](http://stackoverflow.com/questions/2290016/git-commit-messages-50-72-formatting).
- Reference a ticket number, where available, with "#555" if additional work is needed on the issue or “fixes #555” or any of the other [keywords](https://help.github.com/articles/closing-issues-via-commit-messages/) if the commit resolves the issue.
- Be sure to talk about the nature of the change you're making instead of describing the bug or task. Explain why the change was needed if it is relevant.


### Pull Requests

When creating a new pull request:

* Be sure that the message contains a summary of the work that is included in the pull request.
* If the pull request is still a work-in-progress and should not be merged, **include `[WIP]` at the beginning of the title**. When the PR is ready to be merged, **edit the title to remove `[WIP]`**.
* If a pull request is ready for review, **leave or make it unassigned**. This is the assumed state of new PRs, but work-in-progress PRs are quite welcome.
* If you decide to review a pull request with the intent of merging it (or deciding what still needs to be done before merge), then **assign the PR to yourself** so that it's clear that someone's grabbed it.
* Anyone is welcome to informally review a PR and comment on it at any time, no matter who is assigned.

## Team Workflow

1. Pull an issue from the current sprint only, please (unless there is an *URGENT* issue). Take an unassigned issue or re-assign an issue with the label "[stealable](https://github.com/18F/openFEC/labels/stealable)." If a non *URGENT* issue comes up, but you want to prioritize it, coordinate with the PM or tech lead on slack.
2. Before starting, [write the dev issue checklist](https://github.com/18f/openFEC/blob/develop/CONTRIBUTING.md#development-issues-should-include).
3. While working, submit `[WIP]` [pull requests](https://github.com/18f/openFEC/blob/develop/CONTRIBUTING.md#pull-requests) liberally.
4. Time boxing! If you have spent half the time of the estimated size of the issue and you're not sure that you're half-way finished, notify the tech lead or PM in slack. This isn't bad, we just like knowing what's up. :)
5. Make sure your PR includes significant test coverage.
6. Once you're done with your PR, notify the team in slack that your PR is ready for review. Do a review of someone else's PR. (Follow the above PR guidelines.)


## Public domain

This project is in the public domain within the United States, and
copyright and related rights in the work worldwide are waived through
the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).

All contributions to this project will be released under the CC0
dedication. By submitting a pull request, you are agreeing to comply
with this waiver of copyright interest.
