## Welcome
We're glad you're thinking about contributing to an 18F open source project!
If you're unsure about anything, ask us — or submit the issue or pull request
anyway. The worst that can happen is that we’ll politely ask you to change
something.

We love all friendly contributions, and we welcome your ideas about how to
make the FEC's online presence more user friendly, accessible, and elegant.

To ensure a welcoming environment for our projects, our staff follows the
[18F Code of Conduct](https://github.com/18F/code-of-conduct/blob/master/code-of-conduct.md);
contributors should do the same. Please also check out the
[18F Open Source Policy GitHub repository]( https://github.com/18f/open-source-policy).

If you’d prefer, you can also reach us by
[email](mailto:betafeedback@fec.gov).


## Public domain
By submitting a pull request, you agree to comply with the policies on our
[LICENSE](LICENSE.md) page.


## Issues
We use GitHub issues to track user issues and team tasks. Whenever possible,
we follow this outline:
 
1. Goal: a quick blurb explaining the bug or what the issue should accomplish.
   Optional: What is the user need?
2. Completion criteria: how we’ll know that this issue has been completed
3. Tasks to completion:
    - [ ] Use 
    - [ ] Markdown
    - [ ] Checklists 
4. Dependencies (optional): What other issues out there need to be completed
   before you can do this one? Include links to tickets with the dependency.
5. For development issues, include unknown tasks or dependencies that need
   investigation.

In addition, everyone is encourage to open issues for figuring out functional
testing or exploring new ideas that require some additional research, e.g.,
database performance and tuning activities.


## Commit messages
- Good commit messages start with a verb, like "adds" or "changes" or
  "removes."
- Be sure to talk about the nature of the change you're making. Explain why
  the change is needed, rather than simply describing the bug or task it
  addresses.
- If your commit resolves an issue, reference it in the commit messages. For
  example "fixes #555." Read more GitHub guidance on
  [closing issues via commit messages](https://help.github.com/articles/closing-issues-via-commit-messages/).
- We encourage you to follow the
  [50/72 format](http://stackoverflow.com/questions/2290016/git-commit-messages-50-72-formatting).


## Pull requests
- Create pull requests for all commits, even typo fixes.
- Use [PEP 8](https://www.python.org/dev/peps/pep-0008/) as the coding
  standard for Python, but don't worry about fitting lines within 79
  characters.
- Pull requests contain some tests. Ideally they would contain decent test
  coverage.
- Reference a ticket number, where available, with "#555" if additional work
  is needed on the issue or "fixes #555" or any of the other
  [keywords](https://help.github.com/articles/closing-issues-via-commit-messages/)
  if the commit resolves the issue.
- Include a summary of all work and changes; be sure to talk about the nature
  of the change you're making instead of describing the bug or task. Explain
  why the change was needed if it is relevant.
- As with commit messages, pull requests usually start with a verb. Like
  "added" or "changed" or "removed."  We also generally follow the
  [50/72 format](http://stackoverflow.com/questions/2290016/git-commit-messages-50-72-formatting).
- Use `cc @username` to notify a specific team member to review a pull
  request.
- When a pull request is ready for review, label it `plz-review!`.
- Anyone may informally review a pull request and make comments or
  suggestions.
- Only 18F staff may merge pull requests (please do not merge your own pull
  requests, ask for someone else to review and do so).


## 18F team information and practices
There are currently two teams at 18F working in the FEC repositories: the data
team and the legal team. Both teams have agreed to sync their sprint schedules
and align their development efforts to coincide with combined bi-weekly
releases that ship to production on the Wednesday after a two-week sprint. We
will also share a calendar in order to keep track of important sprint dates
and events.

In addition, we've committed to setting aside some time during each sprint
when we all work on code reviews of open pull requests together. This will
help bring new developers up-to-speed on the various code bases and ensure
folks are comfortable reviewing code across the teams. As everyone's comfort
increases we can consider making this activity less structured.


### Demos
We have agreed to continue using our development site for demos with folks at
the FEC. Everyone should feel empowered to demo their work as needed,
especially as this provides valuable and timely feedback. We have also created
a new space for us for testing and demoing specific features that is not
auto-deployed to.

While we routinely demo our work on the development site, the FEC folks will
conduct full reviews of the work slated for a release on our staging site.


### Deployment- and release-related information
The betaFEC project requires a steady release schedule with contents of
releases planned ahead of time due to project requirements. Since both teams
have agreed to synchronize their sprint schedules, this will make it easier
for us to plan for each release after a sprint is completed.

In general, we are committed to creating and deploying a release branch on the
Monday after a sprint is completed. This will require us to have everything
intended to be ready for the release merged to the `develop` branch by the
second Thursday in a sprint. We are allowing ourselves an extra day at the end
to provide us with the bandwidth needed to address any issues, merge
conflicts, etc.

This release branch will be deployed to our `stage` environment for FEC folks
to review until we are ready to do a production deployment, which we have
agreed will be that Wednesday pending any issues found. When the branch is
created we have agreed to let folks know in the appropriate Slack channels
ahead of time to prevent surprises.

We currently have automatic deployments take place whenever code is
merged/pushed to the `develop` (to our `dev` space) or `release/*` (to our
`stage` space) branches.

We have also created a separate `feature` space in Cloud Foundry that we only
manually deploy to as needed. This will enable us to work on and test features
that may require a long lead time before merging into `develop`. It will also
enable us to test this work without being clobbered by the frequent
deployments made when work is merged into `develop`.

When working in the `feature` space, we've agreed to ask in advance to make
sure no one else is currently utilizing the space for their work.


### Development-related tools
Both teams have agreed to the following tenents around the use of our
development-related tools:

- Folks should feel free to branch or fork the code as they see fit; neither
  workflow has major pros or cons over the other, and if anything forking is
  encouraged to ensure that there are no issues for external folks who would
  like to contribute to the repositories as well.
- We are going to stick with using
  [git-flow](http://danielkummer.github.io/git-flow-cheatsheet/) to manage our
  work in git, mainly because our deployment hooks are tied to its workflow.
  We are leaving ourselves the option to investigate other tools or git
  workflows in the future.
- Our current setup with Travis-CI, hound, and Codecov are working fine for
  both teams; we will continue to use them as is until we find they are no
  longer meeting our needs.


### Monitoring
We currently have several monitoring tools in place:

- New Relic, mainly for basic pings
- Sentry, for catching more verbose error reports and logs
- A custom script powered by Mandrill to e-mail us nightly status reports in
  the `dev`, `stage`, and `prod` environments.


### 18F specific team workflow
1. Pull an issue from the current sprint only, please (unless there is an
   *URGENT* issue). Take an unassigned issue or re-assign an issue with the
   label "[stealable](https://github.com/18F/openFEC/labels/stealable)." If a
   non *URGENT* issue comes up, but you want to prioritize it, coordinate with
   the PM or tech lead on slack.
2. Before starting,
   [write the dev issue checklist](https://github.com/18f/openFEC/blob/develop/CONTRIBUTING.md#development-issues-should-include).
3. While working, submit `[WIP]`
   [pull requests](https://github.com/18f/openFEC/blob/develop/CONTRIBUTING.md#pull-requests)
   liberally.
4. Time boxing! If you have spent half the time of the estimated size of the
   issue and you're not sure that you're half-way finished, notify the tech
   lead or PM in slack. This isn't bad, we just like knowing what's up. :)
5. Make sure your PR includes significant test coverage. (Follow the above PR
   guidelines.)
6. Once you're done with your PR, notify the team in slack that your PR is
   ready for review and don't merge your own pull request.
7. Do a review of someone else's PR and merge when it is deemed ready.
