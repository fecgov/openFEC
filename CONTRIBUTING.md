## Welcome
We're glad you're thinking about contributing to an FEC open source project!
If you're unsure about anything, ask us. Or submit the issue or pull request
anyway; the worst that can happen is that we’ll politely ask you to change
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

In addition, everyone is encouraged to open issues for figuring out functional
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
- Only FEC staff may merge pull requests (don't merge your own pull
  requests; ask for someone else to review and do so).



### Demos
We have agreed to continue using our development site for demos with folks at
the FEC. Everyone should feel empowered to demo their work as needed,
especially as this provides valuable and timely feedback. We have also created
a new space — which isn't auto-deployed to — for testing and demoing specific features.

While we routinely demo our work on the development site, the FEC folks will
conduct full reviews of the work slated for a release on our staging site.

## Team's workflow
### Issue and PR management
1. Please pull an issue from the current sprint only (unless there is an
   *URGENT* issue). If a non *URGENT* issue comes up, but you want to prioritize it, coordinate with the PMs or tech lead on Slack.
2. Before starting,
   [write the dev issue checklist](https://github.com/fecgov/openFEC/blob/develop/CONTRIBUTING.md#development-issues-should-include).
3. While working, submit `[WIP]`
   [pull requests](https://github.com/fecgov/openFEC/blob/develop/CONTRIBUTING.md#pull-requests)
   liberally.
4. Time boxing! If you have spent half the time of the estimated size of the
   issue and you're not sure that you're halfway finished, notify the tech
   lead or PM in Slack. This isn't bad; we just like knowing what's up. :)
5. Make sure your pull request includes significant test coverage. (Follow the above pull request
   guidelines.)
6. Once you're done with your pull request, notify the team in Slack that your pull request is
   ready for review, and don't merge your own pull request.
7. Do a review of someone else's pull request and merge when it is deemed ready.

### Pipelines and pre-release testing procedures
Our team’s workflow consists of separate pipelines that determine where a ticket is in the process of our workflow.

These pipelines include:

1. **Backlog:** Tickets that are ready to be worked on and assigned in sprint planning
2. **In progress:** Tickets that are actively being worked on by a member of the team who is assigned to the ticket
3. **Blocked:** This signifies an issue with the ticket that is blocking any kind of further work until a certain dependency is met. These are critical especially because it would prevent a ticket from being completed within the sprint iteration.
4. **Ready:** The ticket has been completed and is ready for code, design, content review, and merge into our repositories. Add “plz-review” label here to signify that the ticket is ready to be reviewed. After the PR is merged, DO NOT close the ticket, leave it in Ready. Closing the ticket may jeopardize testing it in staging. 

    - If applicable, be sure to connect the PR with a particular issue so that it will show up on the board as connected.
        - A. It is important for the product team to refresh requirements in the original issue if something has changed. This way it will not be confusing during testing.
         - B. Dev team should include plain language for what to test in their PR with reproducible steps for testers to follow to check business requirements

#### Release cut

The release is typically cut the Wednesday after sprint planning. By this time, all PR reviews that are part of the past sprint should be done and merged into the develop branch. The release branch is cut from our develop branch. Therefore, when the release branch is cut, those changes that were due in sprint that just closed, will be merged in. Ideally, this would give us about 1 week to complete testing before production release deployment the following wednesday.

5. **Ready for testing:** After release is cut, move all of the previous sprint’s tickets from the “Ready” pipeline to “Ready for testing”.
6. **Testing in progress:** An individual, who is NOT the original person who created the PR, should test. Tester has to verify that business requirements and implementation is correct.
7. **Closed:** After testing is complete, the ticket is complete, close the ticket! 

### Deployment and release information
The fec.gov project requires a steady release schedule that is
planned ahead of time, due to project requirements.

In general, we are committed to creating and deploying a release branch on the
every sprint. This will require us to have everything
intended to be ready for the release merged to the `develop` branch before the release is cut.

This release branch will be deployed to our `stage` environment for FEC folks
to review until we are ready to do a production deployment, which we have
agreed will be that Wednesday, pending any issues found. To prevent suprisse, we've agreed to
let folks know ahead of time in the appropriate Slack channels when the branch is created.

We currently have automatic deployments take place whenever code is
merged/pushed to the `develop` (to our `dev` space) or `release/*` (to our
`stage` space) branches.

We have also created a separate `feature` space in Cloud Foundry, which we
manually deploy to as needed. This will enable us to work on and test features
that may require a long lead time before merging into `develop`. It will also
enable us to test this work without being clobbered by the frequent
deployments made when work is merged into `develop`.

When working in the `feature` space, we've agreed to ask in advance to make
sure no one else is currently using the space for their work.


### Development tools
Both teams have agreed to the following tenets around the use of our
development tools:

- Folks should feel free to branch or fork the code as they see fit; neither
  workflow has major pros or cons over the other, and, if anything, forking is
  encouraged to ensure that there are no issues for external folks who would
  like to contribute to the repositories.
- We are going to stick with using
  [git-flow](http://danielkummer.github.io/git-flow-cheatsheet/) to manage our
  work in git, mainly because our deployment hooks are tied to its workflow.
  We are leaving ourselves the option to investigate other tools or git
  workflows in the future.
- Our current setup with Circle CI, hound, and Codecov are working fine for
  both teams; we will continue to use them as is until we find they no
  longer meet our needs.


### Monitoring
We currently have several monitoring tools in place:

- New Relic, mainly for basic pings
- We receive nightly status reports about
  the `dev`, `stage`, and `prod` environments via slack.
- We have extensive logs via cloud.gov


# Pull request review

- Read the code changes to see if they make sense to you. Any questions you might also be good things to document in a doc string or comment.
- Check for test coverage- the tests should be proportional to the change you are making. A minor text change won't need a test a large feature will need many tests to cover all of its core functionality.
- Check for style, you should be using a linter for each language you write or review. Let that help you find style pointers. Politely suggest any changes that might make the style more consistent. Generally, we have been ignoring line length. Also, function and readability more important than style so test out any major style changes.
- Check with consistency with the rest of the code base. We want the code to follow the same patterns everywhere.
- Make sure everything is documented for outside users.
- Run the code locally! Pull down the code to test the code out on your computer. (Keep this in mind when you are submitting pull requests to be reviewed. It makes it easier if you explain exactly how to test your PR.) Think of additional edge cases that might cause errors and test them out.
