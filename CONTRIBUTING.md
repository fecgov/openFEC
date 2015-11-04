## Welcome
We're glad you're thinking about contributing to an 18F open source project! If you're unsure about anything, ask us — or submit the issue or pull request anyway. The worst that can happen is that we’ll politely ask you to change something. 

We love all friendly contributions, and we welcome your ideas about how to make the FEC's online presence more user friendly, accessible, and elegant. 

To ensure a welcoming environment for our projects, our staff follows the [18F Code of Conduct](https://github.com/18F/code-of-conduct/blob/master/code-of-conduct.md); contributors should do the same. Please also check out the [18F Open Source Policy GitHub repository]( https://github.com/18f/open-source-policy). 

If you’d prefer, you can also reach us by [email](mailto:betafeedback@fec.gov).

## Public domain
By submitting a pull request, you agree to comply with the policies on our [LICENSE](LICENSE.md) page.

### Issues
We use GitHub issues to track user issues and team tasks. Whenever possible, we follow this outline:
 
1. Goal: a quick blurb explaining the bug or what the issue should accomplish. What is the user need?
2. Completion criteria: how we’ll know that this issue has been completed
3. Tasks to completion:
    - [ ] Use 
    - [ ] Markdown
    - [ ] Checklists 
4. Dependencies (optional): What other issues out there need to be completed before you can do this one? Include links to tickets with the dependency.
5. For development issues, include:
Unknown tasks or dependencies that need investigation
[The boilerplate tasks for each development issue](https://gist.github.com/theresaanna/86be7e29214a7f31ab73)

### Commit messages
- Good commit messages start with a verb, like “adds” or “changes” or “removes.” 
- Be sure to talk about the nature of the change you're making. Explain why the change is needed, rather than simply describing the bug or task it addresses. 
- If your commit resolves an issue, reference it in the commit messages. For example “fixes #555.” Read more GitHub guidance on [closing issues via commit messages](https://help.github.com/articles/closing-issues-via-commit-messages/).
- We encourage you to follow the [50/72 format](http://stackoverflow.com/questions/2290016/git-commit-messages-50-72-formatting).

### Pull requests
- Anyone may informally review a pull request and make comments or suggestions. 
- When a pull request is ready for review, label it `plz-review`. 
- Include a summary of all work and changes.
- Use `cc @username` to notify a specific team member to review a pull request.

## 18F team processes
* Use PEP8 as the coding standard for Python, but don't worry about fitting lines within 79 characters.
* Create pull requests for all commits, even typo fixes.
* Don't merge your own pull request. Ask a colleague to review your code and merge.
* Pull requests contain some tests. Ideally they would contain decent test coverage.

- Usually start with a verb. Like “added” or “changed” or “removed”.
- Generally follow [50/72 format](http://stackoverflow.com/questions/2290016/git-commit-messages-50-72-formatting).
- Reference a ticket number, where available, with "#555" if additional work is needed on the issue or “fixes #555” or any of the other [keywords](https://help.github.com/articles/closing-issues-via-commit-messages/) if the commit resolves the issue.
- Be sure to talk about the nature of the change you're making instead of describing the bug or task. Explain why the change was needed if it is relevant.

## 18F team workflow

1. Pull an issue from the current sprint only, please (unless there is an *URGENT* issue). Take an unassigned issue or re-assign an issue with the label "[stealable](https://github.com/18F/openFEC/labels/stealable)." If a non *URGENT* issue comes up, but you want to prioritize it, coordinate with the PM or tech lead on slack.
2. Before starting, [write the dev issue checklist](https://github.com/18f/openFEC/blob/develop/CONTRIBUTING.md#development-issues-should-include).
3. While working, submit `[WIP]` [pull requests](https://github.com/18f/openFEC/blob/develop/CONTRIBUTING.md#pull-requests) liberally.
4. Time boxing! If you have spent half the time of the estimated size of the issue and you're not sure that you're half-way finished, notify the tech lead or PM in slack. This isn't bad, we just like knowing what's up. :)
5. Make sure your PR includes significant test coverage.
6. Once you're done with your PR, notify the team in slack that your PR is ready for review. Do a review of someone else's PR. (Follow the above PR guidelines.)
