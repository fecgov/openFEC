# Changelog

## [Unreleased](https://github.com/fecgov/openFEC/tree/HEAD)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20200707...HEAD)

**Fixed bugs:**

- Add validation for page number \(can't be 0\) [\#4486](https://github.com/fecgov/openFEC/issues/4486)
- PAC and Parties total endpoints broken [\#4444](https://github.com/fecgov/openFEC/issues/4444)
- Server error for Scheudule E endpoint  [\#4360](https://github.com/fecgov/openFEC/issues/4360)
- missing end tag for "default value" on api.open.fec.gov [\#3705](https://github.com/fecgov/openFEC/issues/3705)

**Security fixes:**

- \[Snyk: Med\] Information Exposure \(Due 08/10/2020\) [\#4407](https://github.com/fecgov/openFEC/issues/4407)
- \[Snyk: Med\] Cross-site Scripting \(XSS\) \(Due 08/10/2020\) [\#4406](https://github.com/fecgov/openFEC/issues/4406)
- \[Snyk: Med\] Prototype Pollution \(Due 07/05/2020\) [\#4337](https://github.com/fecgov/openFEC/issues/4337)

**Closed issues:**

- Test more gevent workers per app instance [\#4489](https://github.com/fecgov/openFEC/issues/4489)
- Add filings URL to unverified committee download file [\#4483](https://github.com/fecgov/openFEC/issues/4483)
- Check logs Sprint 13.1 week 1 [\#4480](https://github.com/fecgov/openFEC/issues/4480)
- Integration testing with EFO and confirm the spec and data [\#4475](https://github.com/fecgov/openFEC/issues/4475)
- Identify the new ES service upgrade version  [\#4474](https://github.com/fecgov/openFEC/issues/4474)
- Work with the db team to copy the AMUR schemas/tables from Oracle to PG/Aurora [\#4473](https://github.com/fecgov/openFEC/issues/4473)
- Run compare candidate totals script [\#4472](https://github.com/fecgov/openFEC/issues/4472)
- Increase size of tres\_nm column in f\_rpt\_or\_form\_sub table [\#4463](https://github.com/fecgov/openFEC/issues/4463)
- Check logs innovation sprint week 3 [\#4440](https://github.com/fecgov/openFEC/issues/4440)
- Check logs innovation sprint week 2 [\#4439](https://github.com/fecgov/openFEC/issues/4439)
- Check logs innovation sprint week 1 [\#4438](https://github.com/fecgov/openFEC/issues/4438)
- Research on pagination beyond last page [\#4405](https://github.com/fecgov/openFEC/issues/4405)
- Deprecate `contributor\_aggregate\_ytd` sort option for Schedule A endpoint \(reminder July 20\) [\#4381](https://github.com/fecgov/openFEC/issues/4381)
- "where filter"s \(max= 10\)  at 5/21 outage but fast \<2 sec [\#4371](https://github.com/fecgov/openFEC/issues/4371)
- Incorporate design/UX and feature flag for API key sign up [\#4363](https://github.com/fecgov/openFEC/issues/4363)
- Preserve archived MUR data in Postgres or archived MUR XML [\#4129](https://github.com/fecgov/openFEC/issues/4129)
- Write comprehensive instructions for whole legal doc  [\#3323](https://github.com/fecgov/openFEC/issues/3323)

## [public-20200707](https://github.com/fecgov/openFEC/tree/public-20200707) (2020-07-07)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20200623...public-20200707)

**Security fixes:**

- \[Snyk: High\] XML External Entity \(XXE\) Injection \(Due 07/10/2020\) [\#4408](https://github.com/fecgov/openFEC/issues/4408)
- \[Snyk: Medium\] Prototype Pollution \(Due: 05/19/2020\) [\#4253](https://github.com/fecgov/openFEC/issues/4253)
- resolve postgresql security vulnerability [\#4430](https://github.com/fecgov/openFEC/pull/4430) ([jason-upchurch](https://github.com/jason-upchurch))

**Closed issues:**

- accessing data [\#4436](https://github.com/fecgov/openFEC/issues/4436)
- Add sched-a endpoint description show api user how to use pagination [\#4411](https://github.com/fecgov/openFEC/issues/4411)
- Check logs Sprint 12.6 week 2 [\#4410](https://github.com/fecgov/openFEC/issues/4410)
- Consistent 502s hitting /schedule\_a [\#4404](https://github.com/fecgov/openFEC/issues/4404)
- Change schedule\_a​ default sort by contribution\_receipt\_date DESC \(reminder Jul 20\) [\#4402](https://github.com/fecgov/openFEC/issues/4402)
- Improve slowest queries by adding a new composite  index:  9mins to 2 sec  270 times faster [\#4369](https://github.com/fecgov/openFEC/issues/4369)
- Investigate speeding up query counts by not specifying columns [\#4368](https://github.com/fecgov/openFEC/issues/4368)
- Remove schedule A routing code/feature flag [\#4336](https://github.com/fecgov/openFEC/issues/4336)
- define acceptable use policy for API keys [\#4305](https://github.com/fecgov/openFEC/issues/4305)
- Make a strategy/create tickets for performance improvement work [\#4146](https://github.com/fecgov/openFEC/issues/4146)
- Experiment with snyk/circle ci integration or testing on PR [\#4064](https://github.com/fecgov/openFEC/issues/4064)
- Conduct snyk command line interface training [\#3920](https://github.com/fecgov/openFEC/issues/3920)
- Slow query: Optimize real\_efile.sa7 query [\#3408](https://github.com/fecgov/openFEC/issues/3408)

**Merged pull requests:**

- \[MERGE WITH GIT FLOW\] Release/public 20200707 [\#4441](https://github.com/fecgov/openFEC/pull/4441) ([hcaofec](https://github.com/hcaofec))
- Update V0201\_\_add\_index\_on\_is\_individual\_contbr\_city\_state.sql [\#4431](https://github.com/fecgov/openFEC/pull/4431) ([dzhang-fec](https://github.com/dzhang-fec))
- Remove confusing brackets in PR template [\#4428](https://github.com/fecgov/openFEC/pull/4428) ([lbeaufort](https://github.com/lbeaufort))
- Add message to change sched-a sort to DESC [\#4427](https://github.com/fecgov/openFEC/pull/4427) ([fec-jli](https://github.com/fec-jli))
- Modify Schedule A endpoint description about last index. [\#4426](https://github.com/fecgov/openFEC/pull/4426) ([fec-jli](https://github.com/fec-jli))
- Update description of postgresql version in README [\#4424](https://github.com/fecgov/openFEC/pull/4424) ([hcaofec](https://github.com/hcaofec))
- Add deprecation notice to Schedule A for 'contributor\_aggregate\_ytd' [\#4423](https://github.com/fecgov/openFEC/pull/4423) ([lbeaufort](https://github.com/lbeaufort))
- Add flag \('use\_pk\_for\_count'\) to only select primary key column for count query [\#4380](https://github.com/fecgov/openFEC/pull/4380) ([lbeaufort](https://github.com/lbeaufort))

## [public-20200623](https://github.com/fecgov/openFEC/tree/public-20200623) (2020-06-23)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20200609...public-20200623)

**Fixed bugs:**

- Candidate profile page doesn't show financial summary \(Easy implementation\) [\#4292](https://github.com/fecgov/openFEC/issues/4292)

**Closed issues:**

- Replace blacklist/whitelist terminology [\#4420](https://github.com/fecgov/openFEC/issues/4420)
- Check logs Sprint 12.6 week 1 [\#4409](https://github.com/fecgov/openFEC/issues/4409)
- Add index for `pg\_date` on fec\_fitem\_sched\_a tables [\#4379](https://github.com/fecgov/openFEC/issues/4379)
- Check logs Sprint 12.5 week 2 [\#4376](https://github.com/fecgov/openFEC/issues/4376)
- Update URL for presidential data on API page [\#4362](https://github.com/fecgov/openFEC/issues/4362)
- Performance testing and fine tune: API and CMS [\#4335](https://github.com/fecgov/openFEC/issues/4335)
- Update README, team postgres version to 10.7 [\#4332](https://github.com/fecgov/openFEC/issues/4332)
- Document and hold training on how to identify slowest queries in realtime \(and historical\) in Aurora [\#4330](https://github.com/fecgov/openFEC/issues/4330)

**Merged pull requests:**

- \[MERGE WITH GIT FLOW\] Release/public 20200623 [\#4416](https://github.com/fecgov/openFEC/pull/4416) ([lbeaufort](https://github.com/lbeaufort))
- add pg\_date indexes to fec\_fitem\_sched\_a tables [\#4412](https://github.com/fecgov/openFEC/pull/4412) ([fecjjeng](https://github.com/fecjjeng))
- Update URL for presidential data on API page [\#4401](https://github.com/fecgov/openFEC/pull/4401) ([hcaofec](https://github.com/hcaofec))
- Add filter by load\_date in sched\_a [\#4367](https://github.com/fecgov/openFEC/pull/4367) ([arcegkaz](https://github.com/arcegkaz))

## [public-20200609](https://github.com/fecgov/openFEC/tree/public-20200609) (2020-06-09)

[Full Changelog](https://github.com/fecgov/openFEC/compare/4396-fix-build...public-20200609)

**Closed issues:**

- Builds failing due to missing `pdfminer3k` from `slate` [\#4396](https://github.com/fecgov/openFEC/issues/4396)
- Update system diagram with CDN [\#4326](https://github.com/fecgov/openFEC/issues/4326)
- Limit query variables for certain fields [\#3902](https://github.com/fecgov/openFEC/issues/3902)

**Merged pull requests:**

- Fix release build [\#4398](https://github.com/fecgov/openFEC/pull/4398) ([lbeaufort](https://github.com/lbeaufort))
- \[MERGE WITH GITFLOW\] Release/public 20200609 [\#4391](https://github.com/fecgov/openFEC/pull/4391) ([fecjjeng](https://github.com/fecjjeng))
- Update index idx\_sched\_a\_cmte\_id\_dt\_sub\_id to use desc order [\#4386](https://github.com/fecgov/openFEC/pull/4386) ([fecjjeng](https://github.com/fecjjeng))
- add index to real\_efile.sa7 and real\_efile.sb4 [\#4383](https://github.com/fecgov/openFEC/pull/4383) ([hcaofec](https://github.com/hcaofec))
- Update requests to v2.22.0 [\#4374](https://github.com/fecgov/openFEC/pull/4374) ([pkfec](https://github.com/pkfec))
- Update pytest-flake8 to v1.0.6. [\#4372](https://github.com/fecgov/openFEC/pull/4372) ([pkfec](https://github.com/pkfec))
- Add max ten \(10\) limits for additional fields [\#4366](https://github.com/fecgov/openFEC/pull/4366) ([lbeaufort](https://github.com/lbeaufort))
- API key signup page [\#4359](https://github.com/fecgov/openFEC/pull/4359) ([jason-upchurch](https://github.com/jason-upchurch))

## [4396-fix-build](https://github.com/fecgov/openFEC/tree/4396-fix-build) (2020-06-04)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20200526...4396-fix-build)

**Fixed bugs:**

- Research why MURs are missing documents after reload [\#4361](https://github.com/fecgov/openFEC/issues/4361)

**Closed issues:**

- Check logs Sprint 12.5 week 1 [\#4375](https://github.com/fecgov/openFEC/issues/4375)
- Update pytest-flake8 pkg to fix the pytest errors with python v3.7.7 [\#4373](https://github.com/fecgov/openFEC/issues/4373)
- Get Celery working with new redis service [\#4358](https://github.com/fecgov/openFEC/issues/4358)
- Check logs Sprint 12.4 week 2 [\#4354](https://github.com/fecgov/openFEC/issues/4354)
- Improve slowest queries by adding a new index composited schedue\_a for desc sorting  [\#4352](https://github.com/fecgov/openFEC/issues/4352)
- Improve slowest queries by adding a new index composited  real\_efile\_sb4\_comid\_idate\_con\_dx [\#4346](https://github.com/fecgov/openFEC/issues/4346)
- Improve slowest queries by adding a new index composited real\_efile\_sa7\_comid\_date\_con\_idx [\#4345](https://github.com/fecgov/openFEC/issues/4345)
- Test API caching [\#4341](https://github.com/fecgov/openFEC/issues/4341)
- Keep one postgresql database \(prod\) in sync in parallel then drop all the old postgres databases [\#4328](https://github.com/fecgov/openFEC/issues/4328)
- API load testing setup [\#4327](https://github.com/fecgov/openFEC/issues/4327)
- update package "requests" from 2.21 to 2.22 [\#4295](https://github.com/fecgov/openFEC/issues/4295)

**Merged pull requests:**

- \[MERGE WITH GIT FLOW\] \[HOTFIX\] Fix master build [\#4397](https://github.com/fecgov/openFEC/pull/4397) ([lbeaufort](https://github.com/lbeaufort))

## [public-20200526](https://github.com/fecgov/openFEC/tree/public-20200526) (2020-05-26)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20200512...public-20200526)

**Security fixes:**

- \[Snyk Med\]Prototype Pollution introduced in minimist \(Due 06/16/2020\) [\#4308](https://github.com/fecgov/openFEC/issues/4308)

**Closed issues:**

- Improve slowest queries by adding a new index:  9mins to 2 sec  270 times faster [\#4370](https://github.com/fecgov/openFEC/issues/4370)
- Committee and candidate profile pages are case sensitive when they shouldn't be [\#4355](https://github.com/fecgov/openFEC/issues/4355)
- Check logs Sprint 12.4 week 1  [\#4353](https://github.com/fecgov/openFEC/issues/4353)
- Add validation for pagination [\#4343](https://github.com/fecgov/openFEC/issues/4343)
- Manually add missing citations to five AOs [\#4333](https://github.com/fecgov/openFEC/issues/4333)
- Check logs Sprint 12.3 week 2 [\#4325](https://github.com/fecgov/openFEC/issues/4325)
- Make API Key signup page \(vanilla prototype\) [\#4323](https://github.com/fecgov/openFEC/issues/4323)
- Improve slowest queries after Aurora migration [\#4321](https://github.com/fecgov/openFEC/issues/4321)
- Improve incident response documentation, do a training [\#4302](https://github.com/fecgov/openFEC/issues/4302)
- \(openFEC db migration\) Add is\_active column into ofec\_committee\_fulltext\_mv [\#4296](https://github.com/fecgov/openFEC/issues/4296)
- Add active/terminated status to /names/committees/ [\#4270](https://github.com/fecgov/openFEC/issues/4270)
- Research/test 10\(?\) item limitation for schedules a, b and e [\#4118](https://github.com/fecgov/openFEC/issues/4118)

**Merged pull requests:**

- \[MERGE WITH GIT FLOW\] Release/public 20200526 [\#4365](https://github.com/fecgov/openFEC/pull/4365) ([patphongs](https://github.com/patphongs))
- Handle case sensitivity for /example/\<string:\>/urls [\#4356](https://github.com/fecgov/openFEC/pull/4356) ([lbeaufort](https://github.com/lbeaufort))
- Add is\_active column in names/committees/ [\#4350](https://github.com/fecgov/openFEC/pull/4350) ([fec-jli](https://github.com/fec-jli))
- Update the AO task to include missing cites [\#4347](https://github.com/fecgov/openFEC/pull/4347) ([pkfec](https://github.com/pkfec))
- Add validation for offset pagination \(Schedule A, B, E\) [\#4344](https://github.com/fecgov/openFEC/pull/4344) ([lbeaufort](https://github.com/lbeaufort))
- Add is\_active column  [\#4342](https://github.com/fecgov/openFEC/pull/4342) ([hcaofec](https://github.com/hcaofec))
- add new transaction codes to the list to be included as individual [\#4339](https://github.com/fecgov/openFEC/pull/4339) ([fecjjeng](https://github.com/fecjjeng))

## [public-20200512](https://github.com/fecgov/openFEC/tree/public-20200512) (2020-05-12)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20200428...public-20200512)

**Fixed bugs:**

- AO 2019-13 and AO 2018-06 missing citations [\#4237](https://github.com/fecgov/openFEC/issues/4237)

**Security fixes:**

- \[Snyk: High severity\] Cross-site request forgery \(Due: May 19, 2020\) [\#4282](https://github.com/fecgov/openFEC/issues/4282)

**Closed issues:**

- Set up Pingdom checks for 4 continents for production [\#4338](https://github.com/fecgov/openFEC/issues/4338)
- Check logs Sprint 12.3 week 1  [\#4324](https://github.com/fecgov/openFEC/issues/4324)
- Update is\_individual function to include the new transaction codes 30E, 31E, 32E [\#4322](https://github.com/fecgov/openFEC/issues/4322)
- Have a meeting to discuss meaningful metrics [\#4314](https://github.com/fecgov/openFEC/issues/4314)
- Check logs Sprint 12.2 week 2 [\#4311](https://github.com/fecgov/openFEC/issues/4311)
- Develop team to use the aurora database as the dev database to fully test API/database [\#4298](https://github.com/fecgov/openFEC/issues/4298)
- Migrate postgresql database instance to new Aurora database instances [\#4297](https://github.com/fecgov/openFEC/issues/4297)
- replace cf environment variable values for FEC\_EMAIL\_RECIPIENTS [\#4238](https://github.com/fecgov/openFEC/issues/4238)
- Update env variable FEC\_EMAIL\_RECIPIENTS and FEC\_EMAIL\_SENDER [\#3815](https://github.com/fecgov/openFEC/issues/3815)

**Merged pull requests:**

- \[MERGE WITH GIT FLOW\] Release/public 20200512 [\#4334](https://github.com/fecgov/openFEC/pull/4334) ([lbeaufort](https://github.com/lbeaufort))
- Update locust to python 3.7 compatible version \(10.0\) [\#4320](https://github.com/fecgov/openFEC/pull/4320) ([lbeaufort](https://github.com/lbeaufort))
- \[Snyk\] Security upgrade webargs from 5.3.1 to 5.5.3 [\#4274](https://github.com/fecgov/openFEC/pull/4274) ([snyk-bot](https://github.com/snyk-bot))

## [public-20200428](https://github.com/fecgov/openFEC/tree/public-20200428) (2020-04-28)

[Full Changelog](https://github.com/fecgov/openFEC/compare/4301-restrict-api-traffic-feature...public-20200428)

**Security fixes:**

- upgrade codecov@2.0.9 to 2.0.17 [\#4293](https://github.com/fecgov/openFEC/pull/4293) ([jason-upchurch](https://github.com/jason-upchurch))

**Closed issues:**

- Increase app instances to 10 [\#4315](https://github.com/fecgov/openFEC/issues/4315)
- Check logs Sprint 12.2 week 1 [\#4310](https://github.com/fecgov/openFEC/issues/4310)
- Make a feature flag to isolate API user traffic from front-end site traffic in case of emergency [\#4301](https://github.com/fecgov/openFEC/issues/4301)
- Perform data query test \(API, data export, PGBadger\) [\#4289](https://github.com/fecgov/openFEC/issues/4289)
- Hook up testing data loading with CircleCI [\#4288](https://github.com/fecgov/openFEC/issues/4288)
- Perform loading tests \(Java, Python, Flyway migration, GoldenGate\) [\#4287](https://github.com/fecgov/openFEC/issues/4287)
- Setting up Aurora database instance version 10.7 for testing \(database creation and data loading\) [\#4286](https://github.com/fecgov/openFEC/issues/4286)
- Add is\_active column into committee/\<committee\_id\>/history/ endpoint [\#4284](https://github.com/fecgov/openFEC/issues/4284)
- Delete ofec\_processed\_non\_financia\_amendment\_chain\_vw [\#4276](https://github.com/fecgov/openFEC/issues/4276)

**Merged pull requests:**

-  \[MERGE WITH GITFLOW\]Release/public 20200428 [\#4319](https://github.com/fecgov/openFEC/pull/4319) ([fec-jli](https://github.com/fec-jli))
- Set prod api instances to 10 [\#4317](https://github.com/fecgov/openFEC/pull/4317) ([lbeaufort](https://github.com/lbeaufort))
- Refactor ofec\_filings\_amendments\_all\_mv [\#4316](https://github.com/fecgov/openFEC/pull/4316) ([hcaofec](https://github.com/hcaofec))
- Add is\_active to committee history endpoint [\#4313](https://github.com/fecgov/openFEC/pull/4313) ([fec-jli](https://github.com/fec-jli))
- Add is\_active to committee\_history\_mv [\#4312](https://github.com/fecgov/openFEC/pull/4312) ([fec-jli](https://github.com/fec-jli))
- Add changes from `release/public 20200414` branch back to `develop` branch [\#4304](https://github.com/fecgov/openFEC/pull/4304) ([lbeaufort](https://github.com/lbeaufort))

## [4301-restrict-api-traffic-feature](https://github.com/fecgov/openFEC/tree/4301-restrict-api-traffic-feature) (2020-04-20)

[Full Changelog](https://github.com/fecgov/openFEC/compare/revert-4281-release/public-20200414...4301-restrict-api-traffic-feature)

**Security fixes:**

- \[Snyk: Medium\] Command Injection \(Due: 4/27/2020\) [\#4228](https://github.com/fecgov/openFEC/issues/4228)

**Closed issues:**

- Add 11.7 changes to develop branches for openFEC and fec-cms [\#4303](https://github.com/fecgov/openFEC/issues/4303)
- Initial performance tuning [\#4291](https://github.com/fecgov/openFEC/issues/4291)
- Perform locust load testing [\#4290](https://github.com/fecgov/openFEC/issues/4290)
- Check logs Sprint 12.1 week 2 [\#4272](https://github.com/fecgov/openFEC/issues/4272)
- Postmortem for database slowness on 3/30/20 [\#4267](https://github.com/fecgov/openFEC/issues/4267)

**Merged pull requests:**

- \[MERGE WITH GIT FLOW\] Add feature flag to restrict API traffic [\#4307](https://github.com/fecgov/openFEC/pull/4307) ([lbeaufort](https://github.com/lbeaufort))

## [revert-4281-release/public-20200414](https://github.com/fecgov/openFEC/tree/revert-4281-release/public-20200414) (2020-04-15)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20200414...revert-4281-release/public-20200414)

**Merged pull requests:**

- Revert "\[MERGE WITH GIT FLOW\] Release/public 20200414" [\#4300](https://github.com/fecgov/openFEC/pull/4300) ([jason-upchurch](https://github.com/jason-upchurch))

## [public-20200414](https://github.com/fecgov/openFEC/tree/public-20200414) (2020-04-14)

[Full Changelog](https://github.com/fecgov/openFEC/compare/4273-fix-downloads...public-20200414)

**Fixed bugs:**

- swagger-ui-dist@3.25.0 causes overlap on swagger ui [\#4261](https://github.com/fecgov/openFEC/issues/4261)

**Security fixes:**

- \[Snyk: Med severity\] Command injection \(Due: 5/24/2020\) [\#4264](https://github.com/fecgov/openFEC/issues/4264)
- replace uglifyjs-webpack-plugin with tersor-webpack-plugin [\#4255](https://github.com/fecgov/openFEC/pull/4255) ([jason-upchurch](https://github.com/jason-upchurch))

**Closed issues:**

- Add is\_active column to ofec\_committee\_history\_mv [\#4283](https://github.com/fecgov/openFEC/issues/4283)
- move python build requirements to requirements.txt [\#4278](https://github.com/fecgov/openFEC/issues/4278)
- schedule\_a  download requests are failing in production [\#4273](https://github.com/fecgov/openFEC/issues/4273)
- Check logs Sprint 12.1 week 1 [\#4271](https://github.com/fecgov/openFEC/issues/4271)
- Add pg\_date column to presidential tables [\#4265](https://github.com/fecgov/openFEC/issues/4265)
- Automate PEP8 linting tests [\#4257](https://github.com/fecgov/openFEC/issues/4257)
- Add name to ofec\_pacronyms [\#4210](https://github.com/fecgov/openFEC/issues/4210)
- research load balancing and server configuration [\#3938](https://github.com/fecgov/openFEC/issues/3938)

**Merged pull requests:**

- \[MERGE WITH GIT FLOW\] Release/public 20200414 [\#4281](https://github.com/fecgov/openFEC/pull/4281) ([jason-upchurch](https://github.com/jason-upchurch))
- move nplus one [\#4279](https://github.com/fecgov/openFEC/pull/4279) ([jason-upchurch](https://github.com/jason-upchurch))
- \[MERGE WITH GIT FLOW\] Hotfix: Feature to separate Schedule A traffic [\#4269](https://github.com/fecgov/openFEC/pull/4269) ([lbeaufort](https://github.com/lbeaufort))
- add\_pg\_date\_column\_to\_presidential\_tables [\#4266](https://github.com/fecgov/openFEC/pull/4266) ([fecjjeng](https://github.com/fecjjeng))
- Delete ofec\_totals\_pacs\_parties\_mv [\#4263](https://github.com/fecgov/openFEC/pull/4263) ([hcaofec](https://github.com/hcaofec))
- update swagger-ui-dist [\#4262](https://github.com/fecgov/openFEC/pull/4262) ([jason-upchurch](https://github.com/jason-upchurch))
- Add flake8 to pytest for automated pep8 testing [\#4259](https://github.com/fecgov/openFEC/pull/4259) ([lbeaufort](https://github.com/lbeaufort))
- Update elasticsearch version in required services [\#4256](https://github.com/fecgov/openFEC/pull/4256) ([lbeaufort](https://github.com/lbeaufort))

## [4273-fix-downloads](https://github.com/fecgov/openFEC/tree/4273-fix-downloads) (2020-04-03)

[Full Changelog](https://github.com/fecgov/openFEC/compare/4268-separate-sch-a...4273-fix-downloads)

**Closed issues:**

- Temporarily set up 3rd replica  [\#4268](https://github.com/fecgov/openFEC/issues/4268)
- Check logs PI 11 innovation week 3 [\#4252](https://github.com/fecgov/openFEC/issues/4252)

**Merged pull requests:**

- \[MERGE WITH GIT FLOW\] Hotfix: Fix downloads while using Schedule A routing setting [\#4275](https://github.com/fecgov/openFEC/pull/4275) ([lbeaufort](https://github.com/lbeaufort))

## [4268-separate-sch-a](https://github.com/fecgov/openFEC/tree/4268-separate-sch-a) (2020-03-31)

[Full Changelog](https://github.com/fecgov/openFEC/compare/v0190_total_pac_party...4268-separate-sch-a)

**Security fixes:**

- \[GitHub\] \[Med\] Regular expressions Cross-Site Scripting \(XSS\) vulnerability \(due 4/7/20\) [\#4198](https://github.com/fecgov/openFEC/issues/4198)

**Closed issues:**

- Check logs PI 11 innovation week 2 [\#4251](https://github.com/fecgov/openFEC/issues/4251)
- remove ofec\_totals\_pacs\_parties\_mv [\#4245](https://github.com/fecgov/openFEC/issues/4245)

## [v0190_total_pac_party](https://github.com/fecgov/openFEC/tree/v0190_total_pac_party) (2020-03-25)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20200320...v0190_total_pac_party)

**Closed issues:**

- Turn on presidential map in stage, prod after deploy \(DUE: 3/20/2020\) [\#4221](https://github.com/fecgov/openFEC/issues/4221)
- Configuration checking crashes the application intermittently [\#4162](https://github.com/fecgov/openFEC/issues/4162)

**Merged pull requests:**

- \[MERGE WITH GITFLOW\] Modify committee type in ofec\_totals\_pac\_party\_vw [\#4258](https://github.com/fecgov/openFEC/pull/4258) ([hcaofec](https://github.com/hcaofec))

## [public-20200320](https://github.com/fecgov/openFEC/tree/public-20200320) (2020-03-20)

[Full Changelog](https://github.com/fecgov/openFEC/compare/upgrade-gitpython-pkg...public-20200320)

**Fixed bugs:**

- Communications costs filer CCs need to be specific to each filer\(committee\_id\) [\#4243](https://github.com/fecgov/openFEC/issues/4243)

**Security fixes:**

- \[Snyk: HIGH\]Arbitrary Code Execution \(Due: 04/4/2020\) [\#4236](https://github.com/fecgov/openFEC/issues/4236)

**Closed issues:**

- Check logs PI 11 innovation week 1 [\#4250](https://github.com/fecgov/openFEC/issues/4250)
- Check logs Sprint 11.6 week 2 [\#4230](https://github.com/fecgov/openFEC/issues/4230)
- Candidate totals for H6MD08549 is inconsistent in /candidates/totals/ and /candidate/{candidate\_id}/totals/ [\#4214](https://github.com/fecgov/openFEC/issues/4214)

**Merged pull requests:**

- \[MERGE WITH GIT FLOW\] Release/public 20200320 [\#4249](https://github.com/fecgov/openFEC/pull/4249) ([jason-upchurch](https://github.com/jason-upchurch))
- modify ofec\_candidate\_totals\_detail\_mv to correct candidate totals for H6MD08549 [\#4247](https://github.com/fecgov/openFEC/pull/4247) ([fecjjeng](https://github.com/fecjjeng))
- Add endpoint communication\_costs/aggregates/ [\#4246](https://github.com/fecgov/openFEC/pull/4246) ([fec-jli](https://github.com/fec-jli))
- \[openFEC\] Enable circleci pipeline [\#4240](https://github.com/fecgov/openFEC/pull/4240) ([pkfec](https://github.com/pkfec))
- recreate ofec\_totals\_pac\_party\_view to include totals from committee that changes committee\_type [\#4239](https://github.com/fecgov/openFEC/pull/4239) ([hcaofec](https://github.com/hcaofec))

## [upgrade-gitpython-pkg](https://github.com/fecgov/openFEC/tree/upgrade-gitpython-pkg) (2020-03-10)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20200310...upgrade-gitpython-pkg)

**Merged pull requests:**

- \[MERGE WITH GIT FLOW\] Update GitPython pkg v3.1.0 [\#4242](https://github.com/fecgov/openFEC/pull/4242) ([pkfec](https://github.com/pkfec))

## [public-20200310](https://github.com/fecgov/openFEC/tree/public-20200310) (2020-03-10)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20200225...public-20200310)

**Closed issues:**

- Update CircleCI pipelines for 3 repos before March 9 [\#4231](https://github.com/fecgov/openFEC/issues/4231)
- Check logs Sprint 11.6 week 1 [\#4229](https://github.com/fecgov/openFEC/issues/4229)
- Committee profile page for C00634212 does not show totals for 2020 cycle [\#4215](https://github.com/fecgov/openFEC/issues/4215)
- Check logs Sprint 11.5 week 2 [\#4207](https://github.com/fecgov/openFEC/issues/4207)
- \[presidential map\] decide on synchronization between FECP and Postgres [\#4172](https://github.com/fecgov/openFEC/issues/4172)
- review config.yml and decide if necessary to upgrade npm/node [\#4070](https://github.com/fecgov/openFEC/issues/4070)

**Merged pull requests:**

- \[MERGE WITH GITFLOW\] Release/public 20200310 [\#4233](https://github.com/fecgov/openFEC/pull/4233) ([pkfec](https://github.com/pkfec))
- Update node v10.16.0 and npm v6.13.7 [\#4226](https://github.com/fecgov/openFEC/pull/4226) ([pkfec](https://github.com/pkfec))
- Add bubble endpoints description. [\#4222](https://github.com/fecgov/openFEC/pull/4222) ([fec-jli](https://github.com/fec-jli))
- Add 'transfers\_from\_affiliated\_committees' field to output [\#4220](https://github.com/fecgov/openFEC/pull/4220) ([lbeaufort](https://github.com/lbeaufort))
- correct the value of most\_recent for F24  [\#4217](https://github.com/fecgov/openFEC/pull/4217) ([hcaofec](https://github.com/hcaofec))
- Update gunicorn to 19.10.0 [\#4216](https://github.com/fecgov/openFEC/pull/4216) ([lbeaufort](https://github.com/lbeaufort))
- Update 'most\_recent' filters to always include null values [\#4209](https://github.com/fecgov/openFEC/pull/4209) ([lbeaufort](https://github.com/lbeaufort))
- Add missing fields to financial summary [\#4205](https://github.com/fecgov/openFEC/pull/4205) ([lbeaufort](https://github.com/lbeaufort))
- \[V0185\]Feature/4170 add endpoint presidential by size [\#4199](https://github.com/fecgov/openFEC/pull/4199) ([fec-jli](https://github.com/fec-jli))
- \[V0186\] Add /presidential/coverage\_end\_date/ [\#4197](https://github.com/fecgov/openFEC/pull/4197) ([lbeaufort](https://github.com/lbeaufort))
- \[V0183\]Feature/4178 add endpoint PresidentialByStateView [\#4190](https://github.com/fecgov/openFEC/pull/4190) ([fec-jli](https://github.com/fec-jli))
- \[V0184\] Make endpoint /presidential/financial\_summary/ [\#4189](https://github.com/fecgov/openFEC/pull/4189) ([lbeaufort](https://github.com/lbeaufort))
- Install packages for pytest in Circle [\#4188](https://github.com/fecgov/openFEC/pull/4188) ([lbeaufort](https://github.com/lbeaufort))
- \[V0182\] Add /presidential/contributions/by\_candidate/ [\#4181](https://github.com/fecgov/openFEC/pull/4181) ([lbeaufort](https://github.com/lbeaufort))

## [public-20200225](https://github.com/fecgov/openFEC/tree/public-20200225) (2020-02-24)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20200211...public-20200225)

**Fixed bugs:**

- Wrong numbers for transfers in [\#4219](https://github.com/fecgov/openFEC/issues/4219)
- \[bubble endpoint\] Add Cash on Hand and Federal Funds to PresidentialSummaryView [\#4204](https://github.com/fecgov/openFEC/issues/4204)

**Security fixes:**

- \[Snyk: Medium\] HTTP Request Smuggling \(Due: 3/15/2020\) [\#4149](https://github.com/fecgov/openFEC/issues/4149)

**Closed issues:**

- Schedule\_e 'most\_recent=true' logic update [\#4208](https://github.com/fecgov/openFEC/issues/4208)
- Check logs Sprint 11.5 week 1 [\#4206](https://github.com/fecgov/openFEC/issues/4206)
- F24 version mismatch and missing transaction [\#4200](https://github.com/fecgov/openFEC/issues/4200)
- \[follow-up add documentation\] to bubble 5 endpoints [\#4191](https://github.com/fecgov/openFEC/issues/4191)
- Test performance of /presidential/ endpoints [\#4186](https://github.com/fecgov/openFEC/issues/4186)
- Check logs Sprint 11.4 week 2 [\#4166](https://github.com/fecgov/openFEC/issues/4166)
- Update committee summary file format [\#4158](https://github.com/fecgov/openFEC/issues/4158)
- Test IE "most recent" work. Need data experts [\#4152](https://github.com/fecgov/openFEC/issues/4152)

**Merged pull requests:**

- Conditionally hide presidential section from docs [\#4225](https://github.com/fecgov/openFEC/pull/4225) ([lbeaufort](https://github.com/lbeaufort))
- \[MERGE WITH GITFLOW\] Release/public 20200225 [\#4218](https://github.com/fecgov/openFEC/pull/4218) ([fec-jli](https://github.com/fec-jli))

## [public-20200211](https://github.com/fecgov/openFEC/tree/public-20200211) (2020-02-11)

[Full Changelog](https://github.com/fecgov/openFEC/compare/4193-pin-werkzeug...public-20200211)

**Closed issues:**

- Unpinned 'werkzeug' package breaking the app [\#4193](https://github.com/fecgov/openFEC/issues/4193)
- Make endpoint for coverage dates and summaries \(financial\_summary, coverage\_date\) [\#4178](https://github.com/fecgov/openFEC/issues/4178)
- \[presidential map\] test consistency of api endpoints [\#4171](https://github.com/fecgov/openFEC/issues/4171)

**Merged pull requests:**

- \[MERGE WITH GIT FLOW\] Release/public 20200211 [\#4187](https://github.com/fecgov/openFEC/pull/4187) ([rfultz](https://github.com/rfultz))
- update ofec\_candidate\_totals\_mv [\#4183](https://github.com/fecgov/openFEC/pull/4183) ([fecjjeng](https://github.com/fecjjeng))
- Add file structure for presidential data endpoints [\#4179](https://github.com/fecgov/openFEC/pull/4179) ([lbeaufort](https://github.com/lbeaufort))
- Create base tables to support data for presidential map 2016 and 2020 [\#4176](https://github.com/fecgov/openFEC/pull/4176) ([fecjjeng](https://github.com/fecjjeng))
- fix Missing candidate\_election\_yr 2018 in ofec\_candidate\_history\_mv for H6MD08549 [\#4167](https://github.com/fecgov/openFEC/pull/4167) ([fecjjeng](https://github.com/fecjjeng))
- Make filings from unverified candidates available on filings webpage [\#4159](https://github.com/fecgov/openFEC/pull/4159) ([hcaofec](https://github.com/hcaofec))
- Feature/4112 schedule h4 endpoint [\#4123](https://github.com/fecgov/openFEC/pull/4123) ([jason-upchurch](https://github.com/jason-upchurch))

## [4193-pin-werkzeug](https://github.com/fecgov/openFEC/tree/4193-pin-werkzeug) (2020-02-07)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20200121...4193-pin-werkzeug)

**Fixed bugs:**

- Missing candidate\_election\_yr 2018 in ofec\_candidate\_history\_mv for H6MD08549 [\#4156](https://github.com/fecgov/openFEC/issues/4156)
- Fix API links in Statutes, reload legal docs [\#3942](https://github.com/fecgov/openFEC/issues/3942)

**Closed issues:**

- Resolve duplicate key error in ofec\_candidate\_totals\_mv [\#4182](https://github.com/fecgov/openFEC/issues/4182)
- Make endpoints for aggregates \(by\_state, by\_size\) [\#4177](https://github.com/fecgov/openFEC/issues/4177)
- Design endpoints - names, filters, output fields, data structure, sort capability [\#4175](https://github.com/fecgov/openFEC/issues/4175)
- Make endpoint for candidate list \(presidential/contributions/by\_candidate\) [\#4170](https://github.com/fecgov/openFEC/issues/4170)
- \[presidential map\] recreate sql logic used for classic [\#4169](https://github.com/fecgov/openFEC/issues/4169)
- \[presidential map\] create tables with migration file [\#4168](https://github.com/fecgov/openFEC/issues/4168)
- Check logs Sprint 11.4 week 1 [\#4165](https://github.com/fecgov/openFEC/issues/4165)
- Fix failing build [\#4160](https://github.com/fecgov/openFEC/issues/4160)
- Filings from unverified candidates are not shown on filings page [\#4157](https://github.com/fecgov/openFEC/issues/4157)
- Check logs Sprint 11.3 week 2 [\#4148](https://github.com/fecgov/openFEC/issues/4148)
- Create prototype for schedule\_h4 endpoint [\#4112](https://github.com/fecgov/openFEC/issues/4112)
- \[python package update\] determine approach to update apispec/marshmallow/webargs [\#4079](https://github.com/fecgov/openFEC/issues/4079)

**Merged pull requests:**

- \[HOTFIX\]\[MERGE WITH GIT FLOW\] Pin werkzeug version [\#4194](https://github.com/fecgov/openFEC/pull/4194) ([lbeaufort](https://github.com/lbeaufort))

## [public-20200121](https://github.com/fecgov/openFEC/tree/public-20200121) (2020-01-29)

[Full Changelog](https://github.com/fecgov/openFEC/compare/4160-fix-python-runtime...public-20200121)

**Merged pull requests:**

- Release/public 20200121 [\#4154](https://github.com/fecgov/openFEC/pull/4154) ([jason-upchurch](https://github.com/jason-upchurch))
- Add filing\_form and is\_notice filters in sched\_e.ScheduleEEfileView [\#4145](https://github.com/fecgov/openFEC/pull/4145) ([fec-jli](https://github.com/fec-jli))
- Remove nulls from cycles\_has\_activity in ofec\_committee\_history\_mv [\#4144](https://github.com/fecgov/openFEC/pull/4144) ([hcaofec](https://github.com/hcaofec))

## [4160-fix-python-runtime](https://github.com/fecgov/openFEC/tree/4160-fix-python-runtime) (2020-01-29)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20200114...4160-fix-python-runtime)

**Fixed bugs:**

- \[QA testing ticket\] Raw /schedule\_a/efile contributor name search not working [\#4085](https://github.com/fecgov/openFEC/issues/4085)

**Closed issues:**

- \[Snyk: High\] Buffer Overflow \(Due: 2/22/2020\) [\#4155](https://github.com/fecgov/openFEC/issues/4155)
- Check logs Sprint 11.3 week 1 [\#4147](https://github.com/fecgov/openFEC/issues/4147)
- Add filing\_form and is\_notice params as filterable field within /schedules/schedule\_e/efile/ [\#4140](https://github.com/fecgov/openFEC/issues/4140)
- Check logs Sprint 11.2 week 2 [\#4134](https://github.com/fecgov/openFEC/issues/4134)
- Fix cycles\_has\_activity return NULL in ofec\_committee\_history\_mv [\#4126](https://github.com/fecgov/openFEC/issues/4126)

**Merged pull requests:**

- \[HOTFIX - MERGE WITH GIT FLOW\] Fix python runtime version [\#4161](https://github.com/fecgov/openFEC/pull/4161) ([lbeaufort](https://github.com/lbeaufort))

## [public-20200114](https://github.com/fecgov/openFEC/tree/public-20200114) (2020-01-14)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20191231...public-20200114)

**Fixed bugs:**

- Ann Arbor missing from individual contributions search [\#4111](https://github.com/fecgov/openFEC/issues/4111)
- backfill real\_efile.sa7 so 3 tsvector columns are populated [\#4093](https://github.com/fecgov/openFEC/issues/4093)
- Update API documentation receipts [\#3962](https://github.com/fecgov/openFEC/issues/3962)
- update docs.py [\#4136](https://github.com/fecgov/openFEC/pull/4136) ([jason-upchurch](https://github.com/jason-upchurch))

**Closed issues:**

- Fix the lower case data in disclosure.fec\_fitem\_sched\_x [\#4137](https://github.com/fecgov/openFEC/issues/4137)
- Check logs Sprint 11.2 week 1  [\#4133](https://github.com/fecgov/openFEC/issues/4133)
- Check logs 11.1 week 2 [\#4120](https://github.com/fecgov/openFEC/issues/4120)
- Clarify license language in all repos  [\#4107](https://github.com/fecgov/openFEC/issues/4107)
- \[python package update\] smart-open related packages [\#4076](https://github.com/fecgov/openFEC/issues/4076)
- \[python package update\] elasticsearch-related packages [\#4075](https://github.com/fecgov/openFEC/issues/4075)

**Merged pull requests:**

- \[MERGE WITH GITFLOW\] Release/public 20200114 [\#4142](https://github.com/fecgov/openFEC/pull/4142) ([hcaofec](https://github.com/hcaofec))
- Update dev deploy rule to point to develop branch [\#4139](https://github.com/fecgov/openFEC/pull/4139) ([pkfec](https://github.com/pkfec))
- Clarify license language [\#4138](https://github.com/fecgov/openFEC/pull/4138) ([lbeaufort](https://github.com/lbeaufort))
- upgrade smart open related pkgs [\#4135](https://github.com/fecgov/openFEC/pull/4135) ([pkfec](https://github.com/pkfec))
- Remove reference to swagger-tools [\#4132](https://github.com/fecgov/openFEC/pull/4132) ([jason-upchurch](https://github.com/jason-upchurch))
- Update raw efile docs to reflect 4 months of data instead of 2 years [\#4131](https://github.com/fecgov/openFEC/pull/4131) ([jason-upchurch](https://github.com/jason-upchurch))
- Remove deprecated endpoints [\#4127](https://github.com/fecgov/openFEC/pull/4127) ([pkfec](https://github.com/pkfec))

## [public-20191231](https://github.com/fecgov/openFEC/tree/public-20191231) (2019-12-31)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20191210...public-20191231)

**Security fixes:**

- Whitelist cloud.gov IPs for server-side API keys \[Due 12/29/19\] [\#3979](https://github.com/fecgov/openFEC/issues/3979)

**Closed issues:**

- Check logs 11.1 week 1 [\#4119](https://github.com/fecgov/openFEC/issues/4119)
- Install Swagger Through package.json Instead of Globally [\#4109](https://github.com/fecgov/openFEC/issues/4109)
- Check logs PI 10 innovation, week 3 [\#4103](https://github.com/fecgov/openFEC/issues/4103)
- Check logs PI 10 innovation, week 2 [\#4102](https://github.com/fecgov/openFEC/issues/4102)
- \[python package update\] flask-related dependencies [\#4073](https://github.com/fecgov/openFEC/issues/4073)
- schedule and perform outage drill [\#4060](https://github.com/fecgov/openFEC/issues/4060)
- set-up for outage drill [\#4059](https://github.com/fecgov/openFEC/issues/4059)
- Update API documentation to indicate raw data\(/efile/ endpoints\) is limited to 4 months [\#4045](https://github.com/fecgov/openFEC/issues/4045)
- Research performance impact of directing Sch A traffic to one replica [\#4038](https://github.com/fecgov/openFEC/issues/4038)
- Remove deprecated endpoints, pingdom alerts \[after 12/20\] [\#4024](https://github.com/fecgov/openFEC/issues/4024)
- Add data from H4 to API [\#3341](https://github.com/fecgov/openFEC/issues/3341)

**Merged pull requests:**

- \[MERGE WITH GITFLOW\] Release/public 20191231 [\#4128](https://github.com/fecgov/openFEC/pull/4128) ([pkfec](https://github.com/pkfec))
- Update GPO statute link format [\#4125](https://github.com/fecgov/openFEC/pull/4125) ([lbeaufort](https://github.com/lbeaufort))
- Update endpoints\_walk. [\#4124](https://github.com/fecgov/openFEC/pull/4124) ([fec-jli](https://github.com/fec-jli))
- Feature/4073 update flask dependencies [\#4122](https://github.com/fecgov/openFEC/pull/4122) ([jason-upchurch](https://github.com/jason-upchurch))
- Feature/4109 swagger is not in package file [\#4110](https://github.com/fecgov/openFEC/pull/4110) ([rfultz](https://github.com/rfultz))

## [public-20191210](https://github.com/fecgov/openFEC/tree/public-20191210) (2019-12-10)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20191126...public-20191210)

**Fixed bugs:**

- /schedule\_e/efile candidate\_search param not returning all possible results [\#4086](https://github.com/fecgov/openFEC/issues/4086)
- update tsvector column trigger defs for table sa7 [\#3834](https://github.com/fecgov/openFEC/issues/3834)
- Feature/3834 tsvector sa7 [\#4095](https://github.com/fecgov/openFEC/pull/4095) ([jason-upchurch](https://github.com/jason-upchurch))

**Security fixes:**

- Research moving npm devDependencies into Dependencies for Snyk testing [\#3936](https://github.com/fecgov/openFEC/issues/3936)

**Closed issues:**

- Check logs PI 10 innovation, week 1 [\#4101](https://github.com/fecgov/openFEC/issues/4101)
- Check logs PI 10.6 week 2 [\#4089](https://github.com/fecgov/openFEC/issues/4089)
- Make an endpoint calculate total communication costs [\#4063](https://github.com/fecgov/openFEC/issues/4063)
- Make an endpoint calculate total independent expenditures [\#4061](https://github.com/fecgov/openFEC/issues/4061)
- Explore the possibility of load balancing RDS read replicas [\#3945](https://github.com/fecgov/openFEC/issues/3945)

**Merged pull requests:**

- \[MERGE WITH GIT FLOW\] Release/public 20191210 [\#4106](https://github.com/fecgov/openFEC/pull/4106) ([jason-upchurch](https://github.com/jason-upchurch))
- Feature/4063 add endpoint caluclate total cc [\#4104](https://github.com/fecgov/openFEC/pull/4104) ([jason-upchurch](https://github.com/jason-upchurch))
- \[Merge after 4095 due to migration file order\] Fix candidate\_search column to return all possible results [\#4099](https://github.com/fecgov/openFEC/pull/4099) ([pkfec](https://github.com/pkfec))
- Add new EC endpoint /electioneering/aggregates/. [\#4098](https://github.com/fecgov/openFEC/pull/4098) ([fec-jli](https://github.com/fec-jli))
- Create new end point to calculate total of independent expenditures by candidate [\#4097](https://github.com/fecgov/openFEC/pull/4097) ([fecjjeng](https://github.com/fecjjeng))
- Create endpoint to calculate total electioneering communications [\#4096](https://github.com/fecgov/openFEC/pull/4096) ([hcaofec](https://github.com/hcaofec))
- Add most\_recent filter to sched\_e endpoint [\#4094](https://github.com/fecgov/openFEC/pull/4094) ([pkfec](https://github.com/pkfec))

## [public-20191126](https://github.com/fecgov/openFEC/tree/public-20191126) (2019-11-26)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20191112...public-20191126)

**Closed issues:**

- Check logs PI 10.6 week 1 [\#4088](https://github.com/fecgov/openFEC/issues/4088)
- Downloads using incorrect estimates for schedule E, causing downloads to fail [\#4071](https://github.com/fecgov/openFEC/issues/4071)
- Electioneering communications filer ECs need to be specific to each filer [\#4066](https://github.com/fecgov/openFEC/issues/4066)
- Make an endpoint calculate total electioneering communications [\#4062](https://github.com/fecgov/openFEC/issues/4062)
- Add most\_recent filter  to /schedules/schedule\_e/ \(Processed data\)  [\#4058](https://github.com/fecgov/openFEC/issues/4058)
- Add most\_recent column to ofec\_sched\_e\_mv to support added filters on most\_recent in /schedules/schedule\_e [\#4056](https://github.com/fecgov/openFEC/issues/4056)
- Check logs PI 10.5 week 2 [\#4052](https://github.com/fecgov/openFEC/issues/4052)
- Remove unneeded package installation from config.yml [\#4047](https://github.com/fecgov/openFEC/issues/4047)
- develop prioritization plan for updating python libraries [\#3953](https://github.com/fecgov/openFEC/issues/3953)

**Merged pull requests:**

- \[MERGE WITH GITFLOW\]Release/public 20191126 [\#4092](https://github.com/fecgov/openFEC/pull/4092) ([fec-jli](https://github.com/fec-jli))
- Update downloads to check for exact counts, refactor count logic [\#4087](https://github.com/fecgov/openFEC/pull/4087) ([lbeaufort](https://github.com/lbeaufort))
- Add\_most\_recent\_to\_ofec\_sched\_e\_mv [\#4081](https://github.com/fecgov/openFEC/pull/4081) ([fecjjeng](https://github.com/fecjjeng))
- update config.yml, consolidate requirements files [\#4069](https://github.com/fecgov/openFEC/pull/4069) ([jason-upchurch](https://github.com/jason-upchurch))
- Delete ofec\_totals\_candidate\_committees\_mv/vw [\#4068](https://github.com/fecgov/openFEC/pull/4068) ([hcaofec](https://github.com/hcaofec))
- update elasticsearch and add pip-tools [\#4065](https://github.com/fecgov/openFEC/pull/4065) ([jason-upchurch](https://github.com/jason-upchurch))

## [public-20191112](https://github.com/fecgov/openFEC/tree/public-20191112) (2019-11-13)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20191028...public-20191112)

**Fixed bugs:**

- Financial summary missing for committee [\#4016](https://github.com/fecgov/openFEC/issues/4016)

**Closed issues:**

- Add Filing\_date to ofec\_sched\_e\_mv to support added filters on filing\_date in /schedules/schedule\_e [\#4054](https://github.com/fecgov/openFEC/issues/4054)
- Check logs PI 10.5 week 1 [\#4051](https://github.com/fecgov/openFEC/issues/4051)
- Upgrade to elasticsearch==5.5.3 and add pip-tools to requirements.txt [\#4044](https://github.com/fecgov/openFEC/issues/4044)
- Add columns to committee\_history\_mv and filings\_all\_mv to help filtering to display cycles with either financial reports or with activity [\#4034](https://github.com/fecgov/openFEC/issues/4034)
- More Python package updates [\#4033](https://github.com/fecgov/openFEC/issues/4033)
- Default load for statutes is blank [\#4028](https://github.com/fecgov/openFEC/issues/4028)
- Add test coverage for committee financial summary [\#4027](https://github.com/fecgov/openFEC/issues/4027)
- Update labels for deprecated endpoints [\#4025](https://github.com/fecgov/openFEC/issues/4025)
- Check logs PI 10.4 week 2 [\#4021](https://github.com/fecgov/openFEC/issues/4021)
- Investigate removing 'partition' code [\#4017](https://github.com/fecgov/openFEC/issues/4017)
- Add candidate\_id filter back to schedules/schedule\_e/efile [\#4005](https://github.com/fecgov/openFEC/issues/4005)
- Set up 2nd replica on stage for testing [\#3983](https://github.com/fecgov/openFEC/issues/3983)
- Set up app instance replicas on stage [\#3982](https://github.com/fecgov/openFEC/issues/3982)
- Replicate August 7 load with locust  [\#3981](https://github.com/fecgov/openFEC/issues/3981)
- Why do API app instances crash? [\#3980](https://github.com/fecgov/openFEC/issues/3980)
- Clean-up ofec\_totals\_candidate\_committees\_mv [\#3928](https://github.com/fecgov/openFEC/issues/3928)
- Add filters and output fields to /schedules/schedule\_e/ \(Processed data\) [\#3817](https://github.com/fecgov/openFEC/issues/3817)
- \[Split into multiple issues\] Make endpoints to calculate "other spending" \(IE/EC/CC\) totals [\#3587](https://github.com/fecgov/openFEC/issues/3587)
- Create state level aggregates [\#3575](https://github.com/fecgov/openFEC/issues/3575)

**Merged pull requests:**

- Remove left join for ofec\_committee\_totals\_per\_cycle\_vw [\#4084](https://github.com/fecgov/openFEC/pull/4084) ([fec-jli](https://github.com/fec-jli))
- Bring migration V0171 into release  [\#4082](https://github.com/fecgov/openFEC/pull/4082) ([lbeaufort](https://github.com/lbeaufort))
- \[MERGE WITH GITFLOW\] Release/public 20191112 [\#4067](https://github.com/fecgov/openFEC/pull/4067) ([jason-upchurch](https://github.com/jason-upchurch))
- add sche\_e processed filters [\#4057](https://github.com/fecgov/openFEC/pull/4057) ([pkfec](https://github.com/pkfec))
- Add filing\_date to ofec\_sched\_e\_mv [\#4055](https://github.com/fecgov/openFEC/pull/4055) ([fecjjeng](https://github.com/fecjjeng))
- Add integration test coverage for committee financial summary [\#4049](https://github.com/fecgov/openFEC/pull/4049) ([hcaofec](https://github.com/hcaofec))
- Remove unused partition code [\#4046](https://github.com/fecgov/openFEC/pull/4046) ([lbeaufort](https://github.com/lbeaufort))
- Add columns to committee\_history\_mv and filings\_all\_mv to help filtering to display cycles with either financial reports or with activity. [\#4043](https://github.com/fecgov/openFEC/pull/4043) ([fecjjeng](https://github.com/fecjjeng))
- add candidate\_id filter to /schedules/schedule\_e/efile/ [\#4041](https://github.com/fecgov/openFEC/pull/4041) ([jason-upchurch](https://github.com/jason-upchurch))
- Add cycles\_has\_financial /activity in committee history and form\_category in filings. [\#4039](https://github.com/fecgov/openFEC/pull/4039) ([fec-jli](https://github.com/fec-jli))
- bump flask 1.0.2--\>1.1.1 [\#4036](https://github.com/fecgov/openFEC/pull/4036) ([jason-upchurch](https://github.com/jason-upchurch))
- Default statutes and regulations search to return all results [\#4032](https://github.com/fecgov/openFEC/pull/4032) ([lbeaufort](https://github.com/lbeaufort))

## [public-20191028](https://github.com/fecgov/openFEC/tree/public-20191028) (2019-10-28)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20191015...public-20191028)

**Fixed bugs:**

- Issue on the website with an Advisory Opinion summary in AO 2016-25 [\#4035](https://github.com/fecgov/openFEC/issues/4035)
- Schedule A, B, and E aggregate endpoints can't filter by committee ID [\#3995](https://github.com/fecgov/openFEC/issues/3995)

**Closed issues:**

- Add dependencies of forked repos to requirements.txt for vulnerability testing [\#4040](https://github.com/fecgov/openFEC/issues/4040)
- Update Flask to latest version [\#4026](https://github.com/fecgov/openFEC/issues/4026)
- Notify the Deprecated endpoints users: /committee/\<committee\_ID\>/schedules/schedule\_x/by\_xx/ [\#4023](https://github.com/fecgov/openFEC/issues/4023)
- Check logs PI 10.4 week 1 [\#4020](https://github.com/fecgov/openFEC/issues/4020)
- Double-check candidate totals on 10/16 [\#4019](https://github.com/fecgov/openFEC/issues/4019)
- Add name to nicknames [\#4015](https://github.com/fecgov/openFEC/issues/4015)
- Get "No file image" when loading current Mur. [\#4010](https://github.com/fecgov/openFEC/issues/4010)
- Increase committee ID limit for schedule A to 10 [\#3996](https://github.com/fecgov/openFEC/issues/3996)
- Test efiling improvements [\#3991](https://github.com/fecgov/openFEC/issues/3991)
- Check logs PI 10.3 week 2 [\#3990](https://github.com/fecgov/openFEC/issues/3990)
- More than five campaigns returns no results, but also no error message [\#3988](https://github.com/fecgov/openFEC/issues/3988)
- Research and prep for API outage drill [\#3965](https://github.com/fecgov/openFEC/issues/3965)
- remove unused libraries [\#3955](https://github.com/fecgov/openFEC/issues/3955)
- use and maintain forked marshmallow-pagination [\#3952](https://github.com/fecgov/openFEC/issues/3952)
- Optimize only one Schedule\_a query [\#3939](https://github.com/fecgov/openFEC/issues/3939)

**Merged pull requests:**

- \[MERGE WITH GITFLOW\] Release/public 20191028 [\#4037](https://github.com/fecgov/openFEC/pull/4037) ([patphongs](https://github.com/patphongs))
- updated requirements.txt to used forked version of marshmallow-pagina… [\#4029](https://github.com/fecgov/openFEC/pull/4029) ([jason-upchurch](https://github.com/jason-upchurch))
- Add filter by committee\_id on aggregate schedule A, B, E and Deprecate 9 endpoints  [\#4022](https://github.com/fecgov/openFEC/pull/4022) ([fec-jli](https://github.com/fec-jli))
- Increase maximum number of committeeIDs to 10 [\#4014](https://github.com/fecgov/openFEC/pull/4014) ([lbeaufort](https://github.com/lbeaufort))
- remove unused python libraries  [\#4013](https://github.com/fecgov/openFEC/pull/4013) ([pkfec](https://github.com/pkfec))
- Add designation filters to committee history endpoints [\#4009](https://github.com/fecgov/openFEC/pull/4009) ([lbeaufort](https://github.com/lbeaufort))

## [public-20191015](https://github.com/fecgov/openFEC/tree/public-20191015) (2019-10-16)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20191001...public-20191015)

**Fixed bugs:**

- Future cycle candidate profile pages missing committee info [\#4008](https://github.com/fecgov/openFEC/issues/4008)
- Counts estimate significantly off from actual count on raw IE datatable [\#3948](https://github.com/fecgov/openFEC/issues/3948)

**Security fixes:**

- \[Snyk: Med\] Cross-site scripting in eslint-plugin-no-unsanitized \(Due: 10/20/2019\) [\#3921](https://github.com/fecgov/openFEC/issues/3921)

**Closed issues:**

- /candidate/\[candidate\_id\]/committees/history/\[cycle\]/ not filtering designation [\#4007](https://github.com/fecgov/openFEC/issues/4007)
- Keep only four months of real\_efile/real\_pfile data [\#4004](https://github.com/fecgov/openFEC/issues/4004)
- Check logs PI 10.3 week 1 [\#3989](https://github.com/fecgov/openFEC/issues/3989)
- API key documentation [\#3987](https://github.com/fecgov/openFEC/issues/3987)
- Candidate corrections for Oracle data [\#3986](https://github.com/fecgov/openFEC/issues/3986)
- Server error for loading page 2 of MUR results [\#3985](https://github.com/fecgov/openFEC/issues/3985)
- Check logs PI 10.2 week 2 [\#3963](https://github.com/fecgov/openFEC/issues/3963)
- Create materialized view to get current\_version for each filing [\#3946](https://github.com/fecgov/openFEC/issues/3946)
- resolve version problem with marshmallow-pagination [\#3929](https://github.com/fecgov/openFEC/issues/3929)
- Only keep four months of raw filings data in PG [\#3789](https://github.com/fecgov/openFEC/issues/3789)
- Update apispec, stop using forked copy [\#3776](https://github.com/fecgov/openFEC/issues/3776)

**Merged pull requests:**

- \[MERGE WITH GITFLOW\] Release/public 20191015 [\#4011](https://github.com/fecgov/openFEC/pull/4011) ([fecjjeng](https://github.com/fecjjeng))
- Use actual counts for Schedule E efile endpoint [\#4002](https://github.com/fecgov/openFEC/pull/4002) ([lbeaufort](https://github.com/lbeaufort))
- Add retries to elasticsearch connection, fix unpublish logic for "all murs" reload [\#3998](https://github.com/fecgov/openFEC/pull/3998) ([lbeaufort](https://github.com/lbeaufort))
- Remove eslint-plugin-no-unsanitized from package due to vulnerability [\#3993](https://github.com/fecgov/openFEC/pull/3993) ([patphongs](https://github.com/patphongs))
- update apispec to nonforked version [\#3984](https://github.com/fecgov/openFEC/pull/3984) ([jason-upchurch](https://github.com/jason-upchurch))
- Recalculate most\_recent flag of filings by using v\_sum table [\#3975](https://github.com/fecgov/openFEC/pull/3975) ([hcaofec](https://github.com/hcaofec))
- Add ofec\_sched\_a\_agg\_state\_mv to solve the slowness of ScheduleAByStateCandidate [\#3974](https://github.com/fecgov/openFEC/pull/3974) ([fecjjeng](https://github.com/fecjjeng))
- Add ofec\_sched\_a\_agg\_state\_mv to solve the slowness of ScheduleAByStateCandidate [\#3972](https://github.com/fecgov/openFEC/pull/3972) ([fecjjeng](https://github.com/fecjjeng))

## [public-20191001](https://github.com/fecgov/openFEC/tree/public-20191001) (2019-10-01)

[Full Changelog](https://github.com/fecgov/openFEC/compare/fec-cms-3163-fix-candidate-404...public-20191001)

**Fixed bugs:**

- Candidate profile pages 404ing [\#3977](https://github.com/fecgov/openFEC/issues/3977)
- Full organization type \(organization\_type\_full\) is blank for H's and I's [\#3967](https://github.com/fecgov/openFEC/issues/3967)

**Closed issues:**

- Research why /schedules/schedule\_a/by\_state/by\_candidate is slow [\#3970](https://github.com/fecgov/openFEC/issues/3970)
- test python upgrade on api stage \(Due 9/30/2019 before release deploy\) [\#3969](https://github.com/fecgov/openFEC/issues/3969)
- Check logs PI 10.2 week 1 [\#3964](https://github.com/fecgov/openFEC/issues/3964)
- Upgrade python version to 3.7.4 [\#3951](https://github.com/fecgov/openFEC/issues/3951)
- Check logs PI 10.1 week 2 [\#3934](https://github.com/fecgov/openFEC/issues/3934)
- Drop fec\_vsum\_sched\_xxx views [\#3908](https://github.com/fecgov/openFEC/issues/3908)

**Merged pull requests:**

- Bring "Schedule A by state" speed improvements into the release [\#3973](https://github.com/fecgov/openFEC/pull/3973) ([lbeaufort](https://github.com/lbeaufort))
- \[MERGE WITH GIT FLOW\] Release/public 20191001 [\#3971](https://github.com/fecgov/openFEC/pull/3971) ([lbeaufort](https://github.com/lbeaufort))
- update python version to 3.7.4 [\#3961](https://github.com/fecgov/openFEC/pull/3961) ([jason-upchurch](https://github.com/jason-upchurch))
- drop unused fec vsum sched tables, correct views with columns of data type unknown, switch MV definition to use base tables  [\#3959](https://github.com/fecgov/openFEC/pull/3959) ([fecjjeng](https://github.com/fecjjeng))
- Fix download protection settings [\#3944](https://github.com/fecgov/openFEC/pull/3944) ([lbeaufort](https://github.com/lbeaufort))

## [fec-cms-3163-fix-candidate-404](https://github.com/fecgov/openFEC/tree/fec-cms-3163-fix-candidate-404) (2019-09-13)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20190910...fec-cms-3163-fix-candidate-404)

**Closed issues:**

- decide on what recommendations from python package audit to implement [\#3940](https://github.com/fecgov/openFEC/issues/3940)
- Check logs PI 10.1 week 1 [\#3933](https://github.com/fecgov/openFEC/issues/3933)
- Download protections are on when env var is unset [\#3718](https://github.com/fecgov/openFEC/issues/3718)
- Test Autopilot alternatives [\#3597](https://github.com/fecgov/openFEC/issues/3597)

**Merged pull requests:**

- \[MERGE WITH GIT FLOW\] Fix candidate 404 [\#3958](https://github.com/fecgov/openFEC/pull/3958) ([lbeaufort](https://github.com/lbeaufort))

## [public-20190910](https://github.com/fecgov/openFEC/tree/public-20190910) (2019-09-10)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20190820...public-20190910)

**Fixed bugs:**

- Refactor CandidateTotalsView based on new ofec\_candidate\_totals\_detail\_mv [\#3917](https://github.com/fecgov/openFEC/issues/3917)
- Research: For paper filings, we're missing current version information [\#3455](https://github.com/fecgov/openFEC/issues/3455)

**Security fixes:**

- \[Snyk: Med\] Deserialization of Untrusted Data found in parso \[due: 10/5/2019 \(as of 8/5, no remediation\)\] [\#3894](https://github.com/fecgov/openFEC/issues/3894)
- \[GitHub\] Vulnerable package: mem \(due 9/29/19\) [\#3889](https://github.com/fecgov/openFEC/issues/3889)
- \[GitHub\] Vulnerable package: js-yaml \(due 8/30/19\) [\#3888](https://github.com/fecgov/openFEC/issues/3888)
- \[Tenable\] API missing/inadequate response headers \(due 8/31/19\)  [\#3876](https://github.com/fecgov/openFEC/issues/3876)

**Closed issues:**

- Check logs PI 10 planning week [\#3943](https://github.com/fecgov/openFEC/issues/3943)
- discuss replacing ".xlsx" with ".csv" wherever they occur [\#3927](https://github.com/fecgov/openFEC/issues/3927)
- One candidate with inconsistent totals  [\#3925](https://github.com/fecgov/openFEC/issues/3925)
- User reports receiving numerous 502 bad gateway messages on API end point [\#3924](https://github.com/fecgov/openFEC/issues/3924)
- Update apispec in requirements.txt and modify codebase for breaking changes [\#3923](https://github.com/fecgov/openFEC/issues/3923)
- Reach out `CandidateTotalsView` API users replace full\_election to election\_full [\#3922](https://github.com/fecgov/openFEC/issues/3922)
- Add restriction on cand\_cmte\_linkage related code \(database and API\) to exclude leadership PAC \(cmte\_dsgn=D\) [\#3907](https://github.com/fecgov/openFEC/issues/3907)
- Check logs PI 9 innovation week 3 [\#3906](https://github.com/fecgov/openFEC/issues/3906)
- Check logs PI 9 innovation week 2 [\#3905](https://github.com/fecgov/openFEC/issues/3905)
- Audit python and package versions [\#3782](https://github.com/fecgov/openFEC/issues/3782)
- Hold meeting to determine how/if to streamline and improve log review process [\#3761](https://github.com/fecgov/openFEC/issues/3761)
- Research: Investigate few download/export query requests to DB [\#3730](https://github.com/fecgov/openFEC/issues/3730)
- Research printing API key in logs for /downloads/ for tracking purposes [\#3617](https://github.com/fecgov/openFEC/issues/3617)
- AOs: Create a way to manually add citations that are missed and exclude false positives [\#3302](https://github.com/fecgov/openFEC/issues/3302)
- Load archived MUR 1412 once it's on classic [\#3297](https://github.com/fecgov/openFEC/issues/3297)
- Speed up build: Investigate whether we still need `pandas` in `requirements-dev.txt` [\#3117](https://github.com/fecgov/openFEC/issues/3117)

**Merged pull requests:**

- \[MERGE WITH GITFLOW\] Release/public 20190910 [\#3941](https://github.com/fecgov/openFEC/pull/3941) ([pkfec](https://github.com/pkfec))
- Fix inconsistent totals derived from misfiled F3\* data [\#3935](https://github.com/fecgov/openFEC/pull/3935) ([fecjjeng](https://github.com/fecjjeng))
- Exclude leadership PAC from calculation of election\_yr\_to\_be\_included [\#3932](https://github.com/fecgov/openFEC/pull/3932) ([fecjjeng](https://github.com/fecjjeng))
- \[Merge with cms 3120\]Refactor CandidateTotalsView,CandidateHistoryView,CommitteeHistoryView. [\#3919](https://github.com/fecgov/openFEC/pull/3919) ([fec-jli](https://github.com/fec-jli))
- Update js-yaml package [\#3918](https://github.com/fecgov/openFEC/pull/3918) ([lbeaufort](https://github.com/lbeaufort))
- fix double rows in ofec\_agg\_coverage\_date\_mv [\#3916](https://github.com/fecgov/openFEC/pull/3916) ([fecjjeng](https://github.com/fecjjeng))
- Add ofec\_candidate\_totals\_detail\_mv [\#3914](https://github.com/fecgov/openFEC/pull/3914) ([fec-jli](https://github.com/fec-jli))
- Add columns to ofec\_candidate\_history\_mv to help filtering "valid" fec\_election\_year [\#3913](https://github.com/fecgov/openFEC/pull/3913) ([fecjjeng](https://github.com/fecjjeng))
- Add security-related headers [\#3891](https://github.com/fecgov/openFEC/pull/3891) ([lbeaufort](https://github.com/lbeaufort))

## [public-20190820](https://github.com/fecgov/openFEC/tree/public-20190820) (2019-08-20)

[Full Changelog](https://github.com/fecgov/openFEC/compare/disable-newrelic...public-20190820)

**Security fixes:**

- \[Synk: High\] CRLF injection and Improper Certificate Validation found in urllib3 \[due: 9/5/2019\] [\#3897](https://github.com/fecgov/openFEC/issues/3897)
- \[Snyk: High\] CRLF injection found in urllib3 \[due: 9/5/2019\] [\#3896](https://github.com/fecgov/openFEC/issues/3896)
- \[Synk: High\] Arbitrary Code Execution found in numpy \[due: 9/5/2019\] [\#3895](https://github.com/fecgov/openFEC/issues/3895)
- \[Snyk: High\] urllib3 vulnerability \[due 9/5/2019\] [\#3893](https://github.com/fecgov/openFEC/issues/3893)
- \[GitHub\] Vulnerable package: lodash \(due 8/30/19\) [\#3887](https://github.com/fecgov/openFEC/issues/3887)
- upgrade lodash in package.json, rebuild package-lock.json [\#3892](https://github.com/fecgov/openFEC/pull/3892) ([jason-upchurch](https://github.com/jason-upchurch))

**Closed issues:**

- Fix ofec\_agg\_coverage\_date\_mv to remove double entries from committee\_id/fec\_election\_yr at the turn of 2002/2003 [\#3915](https://github.com/fecgov/openFEC/issues/3915)
- add two columns fec\_cycles\_in\_election and rounded\_election\_years  into ofec\_candidate\_history\_mv [\#3912](https://github.com/fecgov/openFEC/issues/3912)
- Check logs PI 9 innovation week 1 [\#3904](https://github.com/fecgov/openFEC/issues/3904)
- PA zip code mappings reported to be inaccurate post-litigation [\#3903](https://github.com/fecgov/openFEC/issues/3903)
- Refactor ofec\_totals\_candidate\_committees\_mv based on ofec\_totals\_combined\_mv [\#3890](https://github.com/fecgov/openFEC/issues/3890)
- Add filters to /schedules/schedule\_e/efile [\#3813](https://github.com/fecgov/openFEC/issues/3813)
- efile/filings broken? [\#3453](https://github.com/fecgov/openFEC/issues/3453)

**Merged pull requests:**

- \[MERGE WITH GITFLOW\] Release/public 20190820 [\#3910](https://github.com/fecgov/openFEC/pull/3910) ([hcaofec](https://github.com/hcaofec))
- feature/add raw efile filters [\#3900](https://github.com/fecgov/openFEC/pull/3900) ([pkfec](https://github.com/pkfec))
- Add a template migration file that describe the materialized view update process [\#3899](https://github.com/fecgov/openFEC/pull/3899) ([fecjjeng](https://github.com/fecjjeng))
- drop unused database objects; alter ownership [\#3898](https://github.com/fecgov/openFEC/pull/3898) ([hcaofec](https://github.com/hcaofec))

## [disable-newrelic](https://github.com/fecgov/openFEC/tree/disable-newrelic) (2019-08-08)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20190806...disable-newrelic)

**Closed issues:**

- Create a template for MV related changes [\#3882](https://github.com/fecgov/openFEC/issues/3882)
- Check logs sprint 9.6 week 2 [\#3881](https://github.com/fecgov/openFEC/issues/3881)
- Clean some unused views and MVs for F3,F3P,F3X [\#3866](https://github.com/fecgov/openFEC/issues/3866)

**Merged pull requests:**

- \[MERGE WITH GIT FLOW\] Hotfix/disable newrelic [\#3901](https://github.com/fecgov/openFEC/pull/3901) ([pkfec](https://github.com/pkfec))

## [public-20190806](https://github.com/fecgov/openFEC/tree/public-20190806) (2019-08-06)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20190723...public-20190806)

**Fixed bugs:**

- Research: Make sure sqlAlchemy decimal places are rounded to two places [\#3856](https://github.com/fecgov/openFEC/issues/3856)
- account for accents in alphanumeric input for tsvector [\#3852](https://github.com/fecgov/openFEC/issues/3852)
- Itemized contributions being double-counted for two candidates in "by size" breakdown [\#3816](https://github.com/fecgov/openFEC/issues/3816)

**Closed issues:**

- Check logs sprint 9.6 week 1 [\#3880](https://github.com/fecgov/openFEC/issues/3880)
- Two entries per state from schedule\_a/by\_state/by\_candidate when election\_full=true [\#3874](https://github.com/fecgov/openFEC/issues/3874)
- Only strip out login-related Flyway error messages [\#3869](https://github.com/fecgov/openFEC/issues/3869)
- Research: Setup New Relic alert for celery-worker jobs [\#3299](https://github.com/fecgov/openFEC/issues/3299)
- Drop ofec\_reports\_pacs\_parties\_mv since it is replaced by another view [\#3145](https://github.com/fecgov/openFEC/issues/3145)

**Merged pull requests:**

- \[MERGE WITH GITFLOW\] Release/public 20190806 [\#3884](https://github.com/fecgov/openFEC/pull/3884) ([patphongs](https://github.com/patphongs))
- Fix doubled SA aggregate totals: by\_size\_by\_candidate/by\_state\_by\_candidate [\#3879](https://github.com/fecgov/openFEC/pull/3879) ([hcaofec](https://github.com/hcaofec))
- Use API error instead of marshmallow error, mild refactor for /reports/ [\#3868](https://github.com/fecgov/openFEC/pull/3868) ([lbeaufort](https://github.com/lbeaufort))
- Add org\_tp and cmte\_dsgn columns and related indexes to fec\_fitem\_sch… [\#3867](https://github.com/fecgov/openFEC/pull/3867) ([fecjjeng](https://github.com/fecjjeng))
- Handle diacritical marks in data [\#3864](https://github.com/fecgov/openFEC/pull/3864) ([jason-upchurch](https://github.com/jason-upchurch))
- Add org\_type and designation to schedules a and b [\#3837](https://github.com/fecgov/openFEC/pull/3837) ([lbeaufort](https://github.com/lbeaufort))

## [public-20190723](https://github.com/fecgov/openFEC/tree/public-20190723) (2019-07-25)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20190709...public-20190723)

**Fixed bugs:**

- \[Merge to release 9.4\] Fix ofec\_reports\_xxxxxxx\_mvs refresh flow [\#3871](https://github.com/fecgov/openFEC/issues/3871)
- investigate election\_full flag for schedules/schedule\_a/by\_state/by\_candidate/ [\#3865](https://github.com/fecgov/openFEC/issues/3865)
- Filings downloads missing committee names [\#3844](https://github.com/fecgov/openFEC/issues/3844)
- Add org type, designation to Schedule A and B tables [\#3787](https://github.com/fecgov/openFEC/issues/3787)
- Fix "Internal server error" message on query [\#3785](https://github.com/fecgov/openFEC/issues/3785)
- Change /candidates/totals to default to election\_full=true [\#3686](https://github.com/fecgov/openFEC/issues/3686)

**Closed issues:**

- Install postgres extension "unaccent" for related tsvector work [\#3862](https://github.com/fecgov/openFEC/issues/3862)
- Determine SLA for AWS [\#3859](https://github.com/fecgov/openFEC/issues/3859)
- Check logs sprint 9.5 week 2 [\#3855](https://github.com/fecgov/openFEC/issues/3855)
- Check logs sprint 9.5 week 1 [\#3854](https://github.com/fecgov/openFEC/issues/3854)
- Test candidate totals 7/17/19 \(After Q2s\) [\#3843](https://github.com/fecgov/openFEC/issues/3843)
- Add org type to API for Schedules A and B [\#3841](https://github.com/fecgov/openFEC/issues/3841)
- Monitor celery-worker memory usage in Prod [\#3840](https://github.com/fecgov/openFEC/issues/3840)
- Check logs sprint 9.4 week 2 [\#3839](https://github.com/fecgov/openFEC/issues/3839)
- non-schedule\_a and non-schedule\_b tables: Update .\*\_text columns for tables with new tsvector [\#3836](https://github.com/fecgov/openFEC/issues/3836)
- Review website status after July 18/19 Tenable scan [\#3833](https://github.com/fecgov/openFEC/issues/3833)
- Add totals endpoint for /schedules/schedule\_a/by\_state/by\_candidate  [\#3819](https://github.com/fecgov/openFEC/issues/3819)
- Research: Add connected org to committee history [\#3807](https://github.com/fecgov/openFEC/issues/3807)
- Add most\_recent logic to /schedules/schedule\_e/efile/ [\#3708](https://github.com/fecgov/openFEC/issues/3708)

**Merged pull requests:**

- Add postgres@9.6 login errors and change default return [\#3877](https://github.com/fecgov/openFEC/pull/3877) ([jason-upchurch](https://github.com/jason-upchurch))
- Fix MV refresh flow [\#3873](https://github.com/fecgov/openFEC/pull/3873) ([fecjjeng](https://github.com/fecjjeng))
- \[MERGE WITH GITFLOW\] Release/public 20190723 [\#3870](https://github.com/fecgov/openFEC/pull/3870) ([fec-jli](https://github.com/fec-jli))
- Add extension unaccent [\#3863](https://github.com/fecgov/openFEC/pull/3863) ([fecjjeng](https://github.com/fecjjeng))
- Add committee\_name into 3 committee reports MV and export files [\#3860](https://github.com/fecgov/openFEC/pull/3860) ([fec-jli](https://github.com/fec-jli))
- Add cand\_pty\_affiliation and most\_recent to real\_efile\_se\_f57\_vw [\#3853](https://github.com/fecgov/openFEC/pull/3853) ([hcaofec](https://github.com/hcaofec))
- Add swagger tests back. [\#3851](https://github.com/fecgov/openFEC/pull/3851) ([pkfec](https://github.com/pkfec))
- Add connected org to committee history and committee detail [\#3847](https://github.com/fecgov/openFEC/pull/3847) ([lbeaufort](https://github.com/lbeaufort))
- Change default value of election\_full to True [\#3846](https://github.com/fecgov/openFEC/pull/3846) ([lbeaufort](https://github.com/lbeaufort))
- Add /schedules/schedule\_a/by\_state/by\_candidate/totals endpoint [\#3835](https://github.com/fecgov/openFEC/pull/3835) ([jason-upchurch](https://github.com/jason-upchurch))

## [public-20190709](https://github.com/fecgov/openFEC/tree/public-20190709) (2019-07-09)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20190625...public-20190709)

**Closed issues:**

- Check logs sprint 9.4 week 1 [\#3838](https://github.com/fecgov/openFEC/issues/3838)
- Add candidate ID - committee ID link for leadership PACs [\#3765](https://github.com/fecgov/openFEC/issues/3765)
- Replace pathlib with pathlib2 [\#3612](https://github.com/fecgov/openFEC/issues/3612)

**Merged pull requests:**

- \[MERGE WITH GIT FLOW\] Release/public 20190709 [\#3848](https://github.com/fecgov/openFEC/pull/3848) ([lbeaufort](https://github.com/lbeaufort))
- Update celery and related packages [\#3842](https://github.com/fecgov/openFEC/pull/3842) ([lbeaufort](https://github.com/lbeaufort))
- Remove unused filters from Swagger API docs [\#3832](https://github.com/fecgov/openFEC/pull/3832) ([lbeaufort](https://github.com/lbeaufort))
- Add historical data of candidate\_inactve to ofec\_candidate\_detail\_mv [\#3828](https://github.com/fecgov/openFEC/pull/3828) ([hcaofec](https://github.com/hcaofec))
- Redefine function definitions for TSVECTOR columns [\#3811](https://github.com/fecgov/openFEC/pull/3811) ([jason-upchurch](https://github.com/jason-upchurch))

## [public-20190625](https://github.com/fecgov/openFEC/tree/public-20190625) (2019-06-28)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20190611...public-20190625)

**Fixed bugs:**

- Add Line 25 to disbursement details filter [\#3826](https://github.com/fecgov/openFEC/issues/3826)
- Add test coverage for CandidateTotalsView [\#3806](https://github.com/fecgov/openFEC/issues/3806)
- Individual contributions by state aggregate doesn't equal sum of transactions [\#3802](https://github.com/fecgov/openFEC/issues/3802)
- Exported excel file was blank [\#3799](https://github.com/fecgov/openFEC/issues/3799)
- Fix TSVECTOR trigger definitions for search [\#3798](https://github.com/fecgov/openFEC/issues/3798)
- Candidate totals incorrect for one candidate [\#3709](https://github.com/fecgov/openFEC/issues/3709)

**Closed issues:**

- Look at MV/VWs using election\_duration function and switch to new candidate\_election\_duration function [\#3823](https://github.com/fecgov/openFEC/issues/3823)
- Check logs sprint 9.3 week 2 [\#3821](https://github.com/fecgov/openFEC/issues/3821)
- Check logs sprint 9.3 week 1 [\#3820](https://github.com/fecgov/openFEC/issues/3820)
- Closing 15 issues June 2019 repository clean-up [\#3818](https://github.com/fecgov/openFEC/issues/3818)
- candidate\_inactive column in ofec\_candidate\_detail\_mv does not include historical data [\#3810](https://github.com/fecgov/openFEC/issues/3810)
- Check logs sprint 9.2 week 2 [\#3795](https://github.com/fecgov/openFEC/issues/3795)
- Test /schedule\_a/by\_state/by\_candidate data [\#3777](https://github.com/fecgov/openFEC/issues/3777)
- Add "won/lost" data back to /elections/ [\#3250](https://github.com/fecgov/openFEC/issues/3250)
- Make a plan to systematically check endpoint data for data issues [\#3239](https://github.com/fecgov/openFEC/issues/3239)
- Research: De-dupe 24 and 48-hour reports of Independent Expenditures [\#3233](https://github.com/fecgov/openFEC/issues/3233)
- cycle filter for /candidate/\<id\>/totals not consistent with /candidates/totals behavior [\#3220](https://github.com/fecgov/openFEC/issues/3220)
- Research - Best Practices and code of conduct for Github repos [\#3162](https://github.com/fecgov/openFEC/issues/3162)
- QA Legal Citations Results for final AOs [\#3144](https://github.com/fecgov/openFEC/issues/3144)
- Elasticsearch: use asynchronous mode when reindexing all documents [\#3118](https://github.com/fecgov/openFEC/issues/3118)
- Research on schedule\_b query condition  [\#3101](https://github.com/fecgov/openFEC/issues/3101)
- Canary in the coal mine - automated data to API check [\#3051](https://github.com/fecgov/openFEC/issues/3051)
- Create rules for software development version [\#2997](https://github.com/fecgov/openFEC/issues/2997)
- Add to API documentation for "exclude" functionality [\#2957](https://github.com/fecgov/openFEC/issues/2957)
- Add "exclude" load tests to locust [\#2954](https://github.com/fecgov/openFEC/issues/2954)
- Locust tests call API URLs that result in errors for Schedule A and B [\#2933](https://github.com/fecgov/openFEC/issues/2933)
- Special Election Data issues for two Senate Candidates [\#2882](https://github.com/fecgov/openFEC/issues/2882)
- Create View functions [\#2878](https://github.com/fecgov/openFEC/issues/2878)

**Merged pull requests:**

- Remove credentials from migration url [\#3830](https://github.com/fecgov/openFEC/pull/3830) ([lbeaufort](https://github.com/lbeaufort))
- Add contributor zip back to secondary index list [\#3829](https://github.com/fecgov/openFEC/pull/3829) ([lbeaufort](https://github.com/lbeaufort))
- \[MERGE WITH GITFLOW\] Release/public 20190625 [\#3825](https://github.com/fecgov/openFEC/pull/3825) ([rjayasekera](https://github.com/rjayasekera))
- Fix PR candidate totals on candidate and election profile pages [\#3824](https://github.com/fecgov/openFEC/pull/3824) ([lbeaufort](https://github.com/lbeaufort))
- Fix download blank page bug for form\_type=RFAI [\#3814](https://github.com/fecgov/openFEC/pull/3814) ([fec-jli](https://github.com/fec-jli))
- Add more candidate integrated tests [\#3809](https://github.com/fecgov/openFEC/pull/3809) ([lbeaufort](https://github.com/lbeaufort))
- Fix candidate missing from candidate totals [\#3808](https://github.com/fecgov/openFEC/pull/3808) ([fecjjeng](https://github.com/fecjjeng))

## [public-20190611](https://github.com/fecgov/openFEC/tree/public-20190611) (2019-06-11)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20190521...public-20190611)

**Fixed bugs:**

- Candidate missing from /candidates/totals [\#3768](https://github.com/fecgov/openFEC/issues/3768)
- Incorrect candidate list from candidates endpoint [\#3673](https://github.com/fecgov/openFEC/issues/3673)
- Schedule\_e pagination and missing transactions bug [\#3396](https://github.com/fecgov/openFEC/issues/3396)
- Create ofec\_all\_report\_mv [\#3373](https://github.com/fecgov/openFEC/issues/3373)

**Security fixes:**

- \[Med\] Snyk: Race Condition \(due 5/20/19\) [\#3642](https://github.com/fecgov/openFEC/issues/3642)

**Closed issues:**

- Restore parse\_fulltext\(\) to original definition [\#3812](https://github.com/fecgov/openFEC/issues/3812)
- Add is\_active\_candidate flag to /candidates/ to mirror /candidates/totals/ [\#3796](https://github.com/fecgov/openFEC/issues/3796)
- Check logs sprint 9.2 week 1  [\#3794](https://github.com/fecgov/openFEC/issues/3794)
- Update download key limit to 100/IP/hour [\#3793](https://github.com/fecgov/openFEC/issues/3793)
- Write test case for /candidates/totals/ [\#3791](https://github.com/fecgov/openFEC/issues/3791)
- \[issue moved\] Update user email address for api umbrella [\#3786](https://github.com/fecgov/openFEC/issues/3786)
- Check logs sprint 9.1 week 2 [\#3774](https://github.com/fecgov/openFEC/issues/3774)
- Check logs sprint 9.1 week 1 [\#3773](https://github.com/fecgov/openFEC/issues/3773)
- Meeting with Four Points and AWS [\#3769](https://github.com/fecgov/openFEC/issues/3769)
- research inconsistency between snyk cli and web interface [\#3760](https://github.com/fecgov/openFEC/issues/3760)
- Move two TRUSTED\_PROXIES IP addresses into env variables [\#3757](https://github.com/fecgov/openFEC/issues/3757)
- Change default behavior of deploy task to skip migrations [\#3754](https://github.com/fecgov/openFEC/issues/3754)
- Fix logic in calculation of election\_yr\_to\_be\_included column in ofec\_cand\_cmte\_linkage\_mv [\#3747](https://github.com/fecgov/openFEC/issues/3747)
- re-test and re-evaluate line number-filtering loading performance and add data format validation in line number [\#3741](https://github.com/fecgov/openFEC/issues/3741)
- Check slow queries [\#3739](https://github.com/fecgov/openFEC/issues/3739)
- Fix cand\_election\_yr in ofec\_candidate\_history\_mv [\#3736](https://github.com/fecgov/openFEC/issues/3736)
- Investigate setting db timeout for 'fec\_api' to match application timeout [\#3724](https://github.com/fecgov/openFEC/issues/3724)
- Investigate python buildpack depreciation warning [\#3703](https://github.com/fecgov/openFEC/issues/3703)
- Research making totals-level data available for filings after 7:30 pm [\#3701](https://github.com/fecgov/openFEC/issues/3701)
- Clear out unneeded raw filing data [\#3636](https://github.com/fecgov/openFEC/issues/3636)
- Procurement for website project [\#3288](https://github.com/fecgov/openFEC/issues/3288)
- Deploy New Relic on proxy \(pairing opportunity\) [\#2995](https://github.com/fecgov/openFEC/issues/2995)
- API user request: add transaction ID and amendment ID to /schedules/schedule\_e/ endpoint [\#2925](https://github.com/fecgov/openFEC/issues/2925)

**Merged pull requests:**

- \[MERGE WITH GIT FLOW\] Release/public 20190611 [\#3805](https://github.com/fecgov/openFEC/pull/3805) ([jason-upchurch](https://github.com/jason-upchurch))
- add test\_candidate.py [\#3803](https://github.com/fecgov/openFEC/pull/3803) ([jason-upchurch](https://github.com/jason-upchurch))
- Add 'is\_active\_candidate' to /candidates/ [\#3801](https://github.com/fecgov/openFEC/pull/3801) ([lbeaufort](https://github.com/lbeaufort))
- Set trusted proxies as an API environment variable. [\#3783](https://github.com/fecgov/openFEC/pull/3783) ([pkfec](https://github.com/pkfec))
- fix cand election yr ofec candidate history mv [\#3763](https://github.com/fecgov/openFEC/pull/3763) ([fecjjeng](https://github.com/fecjjeng))
- Update deploy task to skip migrations by default [\#3756](https://github.com/fecgov/openFEC/pull/3756) ([lbeaufort](https://github.com/lbeaufort))
- Update Flask-SQLAlchemy to 2.4.0 [\#3753](https://github.com/fecgov/openFEC/pull/3753) ([lbeaufort](https://github.com/lbeaufort))
- adding line\_number validation code [\#3746](https://github.com/fecgov/openFEC/pull/3746) ([qqss88](https://github.com/qqss88))

## [public-20190521](https://github.com/fecgov/openFEC/tree/public-20190521) (2019-05-22)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20190507...public-20190521)

**Fixed bugs:**

- Fix transaction\_id type specification in models to be string [\#3750](https://github.com/fecgov/openFEC/issues/3750)
- fix parse\_fulltext\(\) [\#3716](https://github.com/fecgov/openFEC/issues/3716)

**Security fixes:**

- \[Med\] Snyk: race condition \(due 7/16/19\) [\#3780](https://github.com/fecgov/openFEC/issues/3780)
- \[High\] Snyk: Integer Overflow \(due 5/17/19\) [\#3706](https://github.com/fecgov/openFEC/issues/3706)

**Closed issues:**

- Repository label inventory [\#3781](https://github.com/fecgov/openFEC/issues/3781)
- User looking for Form 2 [\#3778](https://github.com/fecgov/openFEC/issues/3778)
- Find power users to test usability less restricted data tables [\#3772](https://github.com/fecgov/openFEC/issues/3772)
- Lift two-year restriction on schedule b [\#3770](https://github.com/fecgov/openFEC/issues/3770)
- User looking for Form 2 [\#3767](https://github.com/fecgov/openFEC/issues/3767)
- Check logs PI planning week [\#3766](https://github.com/fecgov/openFEC/issues/3766)
- fix privilege escalation vulnerability  [\#3752](https://github.com/fecgov/openFEC/issues/3752)
- Exclude SL from ofec\_totals\_combined\_mv [\#3740](https://github.com/fecgov/openFEC/issues/3740)
- Notify /schedules/schedule\_a/ API users of default behavior change [\#3729](https://github.com/fecgov/openFEC/issues/3729)
- \[HIGH\] CRLF injection -- need a fix by May 24, 2019 [\#3722](https://github.com/fecgov/openFEC/issues/3722)
- Check logs sprint 8.7 week 2 [\#3721](https://github.com/fecgov/openFEC/issues/3721)
- Create FEC owned DNS for stage.fec.gov [\#3704](https://github.com/fecgov/openFEC/issues/3704)
- Investigate requirements.txt and requirements-dev.txt package specification [\#3680](https://github.com/fecgov/openFEC/issues/3680)
- Raw efiling data improvements [\#3627](https://github.com/fecgov/openFEC/issues/3627)
- Update Flask-SQLAlchemy to the newest version [\#3404](https://github.com/fecgov/openFEC/issues/3404)

**Merged pull requests:**

- update webargs to 5.3.1 fix race condition [\#3779](https://github.com/fecgov/openFEC/pull/3779) ([jason-upchurch](https://github.com/jason-upchurch))
- \[MERGE WITH GIT FLOW\] Release/public 20190521 [\#3771](https://github.com/fecgov/openFEC/pull/3771) ([patphongs](https://github.com/patphongs))
- fix privilege escalation add exclude group mysql to build.gradle [\#3759](https://github.com/fecgov/openFEC/pull/3759) ([jason-upchurch](https://github.com/jason-upchurch))
- fix tran\_id and back\_ref\_tran\_id type to String [\#3751](https://github.com/fecgov/openFEC/pull/3751) ([jason-upchurch](https://github.com/jason-upchurch))
- Exclude SLs from ofec\_totals\_combined\_mv [\#3749](https://github.com/fecgov/openFEC/pull/3749) ([hcaofec](https://github.com/hcaofec))
- Upgrade requests package to latest version 2.21.0 [\#3744](https://github.com/fecgov/openFEC/pull/3744) ([pkfec](https://github.com/pkfec))
- resolve integer overflow vulnerability by adding exclude group to bui… [\#3743](https://github.com/fecgov/openFEC/pull/3743) ([jason-upchurch](https://github.com/jason-upchurch))
- fix parse\_fulltext match [\#3732](https://github.com/fecgov/openFEC/pull/3732) ([jason-upchurch](https://github.com/jason-upchurch))

## [public-20190507](https://github.com/fecgov/openFEC/tree/public-20190507) (2019-05-07)

[Full Changelog](https://github.com/fecgov/openFEC/compare/limit-large-sch-a...public-20190507)

**Fixed bugs:**

- Bernie Sanders totals incorrect [\#3700](https://github.com/fecgov/openFEC/issues/3700)

**Closed issues:**

- change committee total api argument 'full\_election' to 'election\_full' to be aligned with all other APIs [\#3734](https://github.com/fecgov/openFEC/issues/3734)
- removing line\_number from secondary parameter list from schedule\_a api [\#3733](https://github.com/fecgov/openFEC/issues/3733)
- Check logs sprint 8.7 week 1 [\#3720](https://github.com/fecgov/openFEC/issues/3720)
- Add validation for missing or multiple 2-year periods [\#3717](https://github.com/fecgov/openFEC/issues/3717)
- Check slow queries \(sprint 8.6\) [\#3697](https://github.com/fecgov/openFEC/issues/3697)
- Baseline metrics - part 1: set up read replicas on stage [\#3618](https://github.com/fecgov/openFEC/issues/3618)
- Add filter to only show published cases on /legal/ [\#3573](https://github.com/fecgov/openFEC/issues/3573)
- Load test legal after-hours [\#3336](https://github.com/fecgov/openFEC/issues/3336)

**Merged pull requests:**

- fix election\_yr\_to\_be\_included logic [\#3748](https://github.com/fecgov/openFEC/pull/3748) ([fecjjeng](https://github.com/fecjjeng))
- \[MERGE WITH GITFLOW\]Release/public 20190507 [\#3738](https://github.com/fecgov/openFEC/pull/3738) ([fec-jli](https://github.com/fec-jli))
- fix syntax error [\#3737](https://github.com/fecgov/openFEC/pull/3737) ([fecjjeng](https://github.com/fecjjeng))
- remove line\_number from sched\_a secondary index list. [\#3735](https://github.com/fecgov/openFEC/pull/3735) ([qqss88](https://github.com/qqss88))
- Fix bernie sanders totals incorrect [\#3726](https://github.com/fecgov/openFEC/pull/3726) ([fecjjeng](https://github.com/fecjjeng))
- add fec\_fitem\_sched\_a\_2019\_2020 and fec\_fitem\_sched\_b\_2019\_2020 tables [\#3715](https://github.com/fecgov/openFEC/pull/3715) ([fecjjeng](https://github.com/fecjjeng))
- Fix schedule\_c endpoints incurred date filter not work [\#3714](https://github.com/fecgov/openFEC/pull/3714) ([fec-jli](https://github.com/fec-jli))
- Fix search by analyst title and email [\#3710](https://github.com/fecgov/openFEC/pull/3710) ([jason-upchurch](https://github.com/jason-upchurch))
- Test published/unpublished cases [\#3688](https://github.com/fecgov/openFEC/pull/3688) ([pkfec](https://github.com/pkfec))
- add sort args to /schedule/schedule\_d/{sub\_id}/ endpoint [\#3682](https://github.com/fecgov/openFEC/pull/3682) ([pkfec](https://github.com/pkfec))

## [limit-large-sch-a](https://github.com/fecgov/openFEC/tree/limit-large-sch-a) (2019-04-26)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20190423...limit-large-sch-a)

**Fixed bugs:**

- INCURRED DATE filter not working on loans page [\#3712](https://github.com/fecgov/openFEC/issues/3712)
- /rad-analyst/ doesn't filter by analyst title or email [\#3699](https://github.com/fecgov/openFEC/issues/3699)
- /schedule\_d/{sub\_id} is not working [\#3681](https://github.com/fecgov/openFEC/issues/3681)

**Closed issues:**

- \[4/23 after release\] Turn on download protections [\#3711](https://github.com/fecgov/openFEC/issues/3711)
- Loans:/schedules/schedule\_c/{sub\_id} is not working [\#3696](https://github.com/fecgov/openFEC/issues/3696)
- Check logs sprint 8.6 week 2 [\#3692](https://github.com/fecgov/openFEC/issues/3692)
- create fec\_fitem\_sched\_a/b\_2019\_2020 partition tables and related objects [\#3657](https://github.com/fecgov/openFEC/issues/3657)

**Merged pull requests:**

- \[MERGE WITH GIT FLOW\] Hotfix: Limit large Schedule A queries [\#3725](https://github.com/fecgov/openFEC/pull/3725) ([lbeaufort](https://github.com/lbeaufort))

## [public-20190423](https://github.com/fecgov/openFEC/tree/public-20190423) (2019-04-23)

[Full Changelog](https://github.com/fecgov/openFEC/compare/temporarily-block-ip...public-20190423)

**Closed issues:**

- Check logs sprint 8.6 week 1 [\#3691](https://github.com/fecgov/openFEC/issues/3691)
- Block one IP [\#3689](https://github.com/fecgov/openFEC/issues/3689)
- Research - Create FEC owned DNS entries  [\#3667](https://github.com/fecgov/openFEC/issues/3667)
- Check slow queries \(sprint 8.5\) [\#3664](https://github.com/fecgov/openFEC/issues/3664)
- incorrect totals for C00508416 \(FRIENDS OF JOHN DELANEY\)  on committee profile page [\#3656](https://github.com/fecgov/openFEC/issues/3656)
- \[High\] fecgov/openFEC:data/flyway/build.gradle - need a fix by Apr. 28, 2019 [\#3654](https://github.com/fecgov/openFEC/issues/3654)
- Implement download endpoint limits [\#3651](https://github.com/fecgov/openFEC/issues/3651)
- Upgrade node version [\#3639](https://github.com/fecgov/openFEC/issues/3639)
- Don’t run the download query in API if the estimate is over 500K [\#3614](https://github.com/fecgov/openFEC/issues/3614)
- Research/test pinning kombu version [\#3608](https://github.com/fecgov/openFEC/issues/3608)
- Make new /candidates/totals/by\_party/by\_office endpoint [\#3549](https://github.com/fecgov/openFEC/issues/3549)

**Merged pull requests:**

- \[MERGE WITH GITFLOW\]Release/public 20190423 [\#3707](https://github.com/fecgov/openFEC/pull/3707) ([qqss88](https://github.com/qqss88))
- Limit access to /downloads/ to one API key [\#3695](https://github.com/fecgov/openFEC/pull/3695) ([lbeaufort](https://github.com/lbeaufort))
- Fix incorrect totals for C00508416 \(FRIENDS OF JOHN DELANEY\) on committee profile page [\#3694](https://github.com/fecgov/openFEC/pull/3694) ([hcaofec](https://github.com/hcaofec))
- pin requirements for kombu 4.5.0 [\#3693](https://github.com/fecgov/openFEC/pull/3693) ([jason-upchurch](https://github.com/jason-upchurch))
- candidate totals by party by office [\#3687](https://github.com/fecgov/openFEC/pull/3687) ([fecjjeng](https://github.com/fecjjeng))
- Update Flyway to version 5.2.4 [\#3676](https://github.com/fecgov/openFEC/pull/3676) ([lbeaufort](https://github.com/lbeaufort))
- Upgraded node and npm versions [\#3670](https://github.com/fecgov/openFEC/pull/3670) ([patphongs](https://github.com/patphongs))

## [temporarily-block-ip](https://github.com/fecgov/openFEC/tree/temporarily-block-ip) (2019-04-11)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20190409.6...temporarily-block-ip)

**Closed issues:**

- Check logs sprint 8.5 week 2 [\#3653](https://github.com/fecgov/openFEC/issues/3653)

**Merged pull requests:**

- \[MERGE WITH GIT FLOW\] Hotfix: Temporarily block ip [\#3690](https://github.com/fecgov/openFEC/pull/3690) ([lbeaufort](https://github.com/lbeaufort))

## [public-20190409.6](https://github.com/fecgov/openFEC/tree/public-20190409.6) (2019-04-10)

[Full Changelog](https://github.com/fecgov/openFEC/compare/deploy-release...public-20190409.6)

## [deploy-release](https://github.com/fecgov/openFEC/tree/deploy-release) (2019-04-10)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20190409.5...deploy-release)

**Merged pull requests:**

- \[MERGE WITH GITFLOW\] Remove extra space [\#3684](https://github.com/fecgov/openFEC/pull/3684) ([pkfec](https://github.com/pkfec))
- Update SQLA\_SAMPLE\_DB\_CONN instructions [\#3679](https://github.com/fecgov/openFEC/pull/3679) ([lbeaufort](https://github.com/lbeaufort))
- update sched\_a.py and sched\_b.py and remove two year restriction. [\#3674](https://github.com/fecgov/openFEC/pull/3674) ([qqss88](https://github.com/qqss88))

## [public-20190409.5](https://github.com/fecgov/openFEC/tree/public-20190409.5) (2019-04-10)

[Full Changelog](https://github.com/fecgov/openFEC/compare/empty-deploy...public-20190409.5)

**Closed issues:**

- Remove the two-year restriction from the API and test performance [\#3595](https://github.com/fecgov/openFEC/issues/3595)

## [empty-deploy](https://github.com/fecgov/openFEC/tree/empty-deploy) (2019-04-09)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20190409_4...empty-deploy)

**Merged pull requests:**

- make flyway readme more user friendly \#3675 [\#3678](https://github.com/fecgov/openFEC/pull/3678) ([jason-upchurch](https://github.com/jason-upchurch))
- adding download tests to locust. [\#3666](https://github.com/fecgov/openFEC/pull/3666) ([qqss88](https://github.com/qqss88))

## [public-20190409_4](https://github.com/fecgov/openFEC/tree/public-20190409_4) (2019-04-09)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20190409.2...public-20190409_4)

**Merged pull requests:**

- \[MERGE WITH GIT FLOW\] Empty commit for deploy [\#3683](https://github.com/fecgov/openFEC/pull/3683) ([pkfec](https://github.com/pkfec))

## [public-20190409.2](https://github.com/fecgov/openFEC/tree/public-20190409.2) (2019-04-09)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20190409.3...public-20190409.2)

## [public-20190409.3](https://github.com/fecgov/openFEC/tree/public-20190409.3) (2019-04-09)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20190409...public-20190409.3)

**Fixed bugs:**

- AO 2019-01 missing citations [\#3669](https://github.com/fecgov/openFEC/issues/3669)

**Closed issues:**

- Make Flyway instructions more user friendly [\#3675](https://github.com/fecgov/openFEC/issues/3675)
- DEMO\_KEY rate limit inconsistent with messaging [\#3648](https://github.com/fecgov/openFEC/issues/3648)
- Research: Reduce the number of our celery workers [\#3637](https://github.com/fecgov/openFEC/issues/3637)

## [public-20190409](https://github.com/fecgov/openFEC/tree/public-20190409) (2019-04-04)

[Full Changelog](https://github.com/fecgov/openFEC/compare/load-arc-murs-without-subject...public-20190409)

**Fixed bugs:**

- API rate limits not enforced correctly [\#3668](https://github.com/fecgov/openFEC/issues/3668)

**Closed issues:**

- Expand two year restriction to allow users to search up to 6 year periods: schedule\_a api update/re-implementation [\#3659](https://github.com/fecgov/openFEC/issues/3659)
- Check logs sprint 8.5 week 1 [\#3655](https://github.com/fecgov/openFEC/issues/3655)
- Check logs Sprint 8.5 week 1 [\#3652](https://github.com/fecgov/openFEC/issues/3652)
- Identify slow queries and performance tuning [\#3641](https://github.com/fecgov/openFEC/issues/3641)
- COH for John Delaney incorrect on /candidates/totals [\#3635](https://github.com/fecgov/openFEC/issues/3635)
- Update the security vulnerabilities links on fec repo [\#3547](https://github.com/fecgov/openFEC/issues/3547)
- Analyze and optimize one slow ScheduleA query [\#3050](https://github.com/fecgov/openFEC/issues/3050)

**Merged pull requests:**

- \[MERGE WITH GIT FLOW\] Release/public 20190409 [\#3672](https://github.com/fecgov/openFEC/pull/3672) ([pkfec](https://github.com/pkfec))
- fix the synk links to show the vulnerabilities counts  [\#3671](https://github.com/fecgov/openFEC/pull/3671) ([pkfec](https://github.com/pkfec))
- update ofec\_candidate\_totals\_mv to handle coh aggregation for candida…te with multiple form type and/or multiple committees [\#3660](https://github.com/fecgov/openFEC/pull/3660) ([fecjjeng](https://github.com/fecjjeng))
- OPENFEC - Add snyk links [\#3658](https://github.com/fecgov/openFEC/pull/3658) ([pkfec](https://github.com/pkfec))
- Fix Financial:/elections/ to include F3 for presidential election\_profile totals [\#3647](https://github.com/fecgov/openFEC/pull/3647) ([hcaofec](https://github.com/hcaofec))
- fix-mv-refresh-sequence [\#3640](https://github.com/fecgov/openFEC/pull/3640) ([fecjjeng](https://github.com/fecjjeng))

## [load-arc-murs-without-subject](https://github.com/fecgov/openFEC/tree/load-arc-murs-without-subject) (2019-03-29)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20190326...load-arc-murs-without-subject)

**Closed issues:**

- Check logs Sprint 8.4 week 2 [\#3623](https://github.com/fecgov/openFEC/issues/3623)

**Merged pull requests:**

- \[MERGE WITH GIT FLOW\]Load the archived murs when the subject is not available. [\#3662](https://github.com/fecgov/openFEC/pull/3662) ([pkfec](https://github.com/pkfec))

## [public-20190326](https://github.com/fecgov/openFEC/tree/public-20190326) (2019-03-28)

[Full Changelog](https://github.com/fecgov/openFEC/compare/block-one-ip...public-20190326)

**Fixed bugs:**

- Totals for John Delaney incorrect on election profile page\(/elections/\) [\#3611](https://github.com/fecgov/openFEC/issues/3611)

**Closed issues:**

- Query against processed sched tables should use two\_year\_transaction\_period instead of re-calculated in the query [\#3634](https://github.com/fecgov/openFEC/issues/3634)
- ofec\_candidate\_history\_with\_future\_election\_mv need to be refreshed before ofec\_candidate\_totals\_mv [\#3632](https://github.com/fecgov/openFEC/issues/3632)
- Research options for protecting downloads endpoint [\#3630](https://github.com/fecgov/openFEC/issues/3630)
- Whitelist cloud.gov IP address for /downloads/ endpoint [\#3626](https://github.com/fecgov/openFEC/issues/3626)
- Check logs Sprint 8.4 week 1 [\#3622](https://github.com/fecgov/openFEC/issues/3622)
- Research improving postgresql counts performance [\#3586](https://github.com/fecgov/openFEC/issues/3586)
- Upgrade RDS instance size [\#3580](https://github.com/fecgov/openFEC/issues/3580)
- Extend base cache for API beyond 1 hour [\#3545](https://github.com/fecgov/openFEC/issues/3545)

**Merged pull requests:**

- updateing circleci docker base image to 3.6.4-stretch. [\#3650](https://github.com/fecgov/openFEC/pull/3650) ([qqss88](https://github.com/qqss88))
- Limit extra caching to /schedules/ [\#3645](https://github.com/fecgov/openFEC/pull/3645) ([lbeaufort](https://github.com/lbeaufort))
- use two\_year\_transaction\_period in join for fec\_fitem\_sched\_a/b [\#3644](https://github.com/fecgov/openFEC/pull/3644) ([fecjjeng](https://github.com/fecjjeng))
- \[MERGE WITH GIT FLOW\] Release/public 20190326 [\#3638](https://github.com/fecgov/openFEC/pull/3638) ([lbeaufort](https://github.com/lbeaufort))
- Change default behavior of /candidates/totals/by\_office/ [\#3624](https://github.com/fecgov/openFEC/pull/3624) ([hcaofec](https://github.com/hcaofec))
- Upgrade SQLAlchemy to latest version 1.3.1. [\#3621](https://github.com/fecgov/openFEC/pull/3621) ([pkfec](https://github.com/pkfec))
- update ofec\_totals\_combined\_mv to fix ttl\_fed\_disb null problem [\#3619](https://github.com/fecgov/openFEC/pull/3619) ([fecjjeng](https://github.com/fecjjeng))
- Temporarily remove prance\[osv\] and swagger validation [\#3615](https://github.com/fecgov/openFEC/pull/3615) ([lbeaufort](https://github.com/lbeaufort))
- Add all-day cache between 9am and 7:30pm ET [\#3610](https://github.com/fecgov/openFEC/pull/3610) ([lbeaufort](https://github.com/lbeaufort))
- Update OS stack to cflinuxfs3  [\#3606](https://github.com/fecgov/openFEC/pull/3606) ([pkfec](https://github.com/pkfec))

## [block-one-ip](https://github.com/fecgov/openFEC/tree/block-one-ip) (2019-03-14)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20190312...block-one-ip)

**Fixed bugs:**

- PAC "Total Federal Disbursements" returning "null" [\#3581](https://github.com/fecgov/openFEC/issues/3581)

**Closed issues:**

- Change default behavior of /candidates/totals/by\_office/ to include all by default [\#3604](https://github.com/fecgov/openFEC/issues/3604)
- Check logs Sprint 8.3 week 2 [\#3591](https://github.com/fecgov/openFEC/issues/3591)
- \[HIGH\] Snyk - SQL Injection - Fix by 20190327 [\#3589](https://github.com/fecgov/openFEC/issues/3589)

**Merged pull requests:**

- \[MERGE WITH GIT FLOW\] Temporarily block one IP address [\#3628](https://github.com/fecgov/openFEC/pull/3628) ([lbeaufort](https://github.com/lbeaufort))

## [public-20190312](https://github.com/fecgov/openFEC/tree/public-20190312) (2019-03-12)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20190214...public-20190312)

**Fixed bugs:**

- API not properly caching [\#3601](https://github.com/fecgov/openFEC/issues/3601)
- Problem with candidate profile page party affiliation [\#3592](https://github.com/fecgov/openFEC/issues/3592)
- Operating expenditures wrong on committee profile page [\#3582](https://github.com/fecgov/openFEC/issues/3582)
- Exclude inactive candidates from election pages [\#3564](https://github.com/fecgov/openFEC/issues/3564)
- Filter for single day \(raw filings\) [\#3563](https://github.com/fecgov/openFEC/issues/3563)
- COH incorrect for election profile pages \(/elections\) [\#3562](https://github.com/fecgov/openFEC/issues/3562)
- RFAI missing from filings tab of committee profile page [\#2574](https://github.com/fecgov/openFEC/issues/2574)

**Closed issues:**

- Update redis to fix celery worker/beat connectivity issue when kombu is upgraded  [\#3607](https://github.com/fecgov/openFEC/issues/3607)
- Check logs Sprint 8.3 week 1 [\#3590](https://github.com/fecgov/openFEC/issues/3590)
- Data design research for lifting year restriction on transactions [\#3574](https://github.com/fecgov/openFEC/issues/3574)
- Add filter to include only active candidates for /candidates/totals [\#3572](https://github.com/fecgov/openFEC/issues/3572)
- Add totals capability for raising/spending breakdown charts [\#3571](https://github.com/fecgov/openFEC/issues/3571)
- Check logs Sprint 8.2 week 2 [\#3569](https://github.com/fecgov/openFEC/issues/3569)
- Check logs Sprint 8.2 week 1 [\#3568](https://github.com/fecgov/openFEC/issues/3568)
- Update buildpack to cflinuxfs3 before April 2019 [\#3566](https://github.com/fecgov/openFEC/issues/3566)
- Increase database performance [\#3543](https://github.com/fecgov/openFEC/issues/3543)

**Merged pull requests:**

- \(Release PR\) Temporarily remove prance\[osv\] and swagger validation [\#3616](https://github.com/fecgov/openFEC/pull/3616) ([lbeaufort](https://github.com/lbeaufort))
- Upgrade redis to version 3.2.0  [\#3605](https://github.com/fecgov/openFEC/pull/3605) ([pkfec](https://github.com/pkfec))
- \[MERGE WITH GITFLOW\] Release/public 20190312 [\#3603](https://github.com/fecgov/openFEC/pull/3603) ([patphongs](https://github.com/patphongs))
- adding active\_candidates filter to totalCandidateView with unit tests. [\#3602](https://github.com/fecgov/openFEC/pull/3602) ([qqss88](https://github.com/qqss88))
- Increase API timeout to 300 [\#3600](https://github.com/fecgov/openFEC/pull/3600) ([patphongs](https://github.com/patphongs))
- update ofec\_candidate\_history\_mv to fix cand\_inactive value [\#3596](https://github.com/fecgov/openFEC/pull/3596) ([fecjjeng](https://github.com/fecjjeng))
- Endpoint to calculate candidate totals by office by election year [\#3593](https://github.com/fecgov/openFEC/pull/3593) ([hcaofec](https://github.com/hcaofec))
- Modified eFiling date range filter to use filed\_date [\#3584](https://github.com/fecgov/openFEC/pull/3584) ([rjayasekera](https://github.com/rjayasekera))
- update op\_exp calculation in ofec\_totals\_combined\_mv [\#3583](https://github.com/fecgov/openFEC/pull/3583) ([fecjjeng](https://github.com/fecjjeng))
- Fix COH on election profile pages [\#3578](https://github.com/fecgov/openFEC/pull/3578) ([pkfec](https://github.com/pkfec))

## [public-20190214](https://github.com/fecgov/openFEC/tree/public-20190214) (2019-02-14)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20190205...public-20190214)

**Closed issues:**

- Investigate increasing application server memory [\#3560](https://github.com/fecgov/openFEC/issues/3560)
- Additional /schedule\_a/by\_state/totals API work [\#3559](https://github.com/fecgov/openFEC/issues/3559)
- Add ability to filter schedule A by active candidates [\#3552](https://github.com/fecgov/openFEC/issues/3552)
- Update /schedule\_a/by\_state/totals endpoint or create new endpoint to support raising map \(Part I\) [\#3548](https://github.com/fecgov/openFEC/issues/3548)
- Remove Schedule A year restriction [\#3544](https://github.com/fecgov/openFEC/issues/3544)
- Remove the `mur\_` filters from the API [\#3504](https://github.com/fecgov/openFEC/issues/3504)
- Fix incumbent flags  [\#3262](https://github.com/fecgov/openFEC/issues/3262)
- drop ofec\_sched\_e table and related process [\#3100](https://github.com/fecgov/openFEC/issues/3100)

**Merged pull requests:**

- \[MERGE WITH GITFLOW\] Release/public 20190214 [\#3579](https://github.com/fecgov/openFEC/pull/3579) ([pkfec](https://github.com/pkfec))
- drop unused sched c d e f tables and related process [\#3570](https://github.com/fecgov/openFEC/pull/3570) ([fecjjeng](https://github.com/fecjjeng))
- Remove mur-specific query fields - use 'case' [\#3505](https://github.com/fecgov/openFEC/pull/3505) ([lbeaufort](https://github.com/lbeaufort))

## [public-20190205](https://github.com/fecgov/openFEC/tree/public-20190205) (2019-02-05)

[Full Changelog](https://github.com/fecgov/openFEC/compare/update_react_webpack...public-20190205)

**Fixed bugs:**

- Typo in committe name in docquery file [\#3500](https://github.com/fecgov/openFEC/issues/3500)

**Closed issues:**

- Check logs Sprint 8.1 week 2 [\#3558](https://github.com/fecgov/openFEC/issues/3558)
- Check logs Sprint 8.1 week 1 [\#3557](https://github.com/fecgov/openFEC/issues/3557)
- Check logs Sprint 8.2 week 2 [\#3554](https://github.com/fecgov/openFEC/issues/3554)
- Check logs Sprint 8.2 week 1 [\#3553](https://github.com/fecgov/openFEC/issues/3553)
- Add active candidates only endpoint [\#3551](https://github.com/fecgov/openFEC/issues/3551)
- Full cycle totals breakdown and future cycles 2012-2024 [\#3550](https://github.com/fecgov/openFEC/issues/3550)
- Filtering problem between PAC and Political Party Committee [\#3540](https://github.com/fecgov/openFEC/issues/3540)
- \[Med\] Regular Expression Denial of Service due 2/4/19  [\#3529](https://github.com/fecgov/openFEC/issues/3529)
- \[Med\] Snyk: Cross-site Scripting \(XSS\) due 2/4/19  [\#3528](https://github.com/fecgov/openFEC/issues/3528)
- Upgrade smart\_open to 1.6.0 or higher [\#3398](https://github.com/fecgov/openFEC/issues/3398)
- Exclude inactive and unverified candidates from /elections/ [\#3260](https://github.com/fecgov/openFEC/issues/3260)

**Merged pull requests:**

- \[MERGE WITH GITFLOW\] Release/public 20190205 [\#3567](https://github.com/fecgov/openFEC/pull/3567) ([patphongs](https://github.com/patphongs))
- Fix logic for full cycle candidate committee totals \(Part 1\) [\#3561](https://github.com/fecgov/openFEC/pull/3561) ([lbeaufort](https://github.com/lbeaufort))
- Filter totals for committee type of pac and party. [\#3546](https://github.com/fecgov/openFEC/pull/3546) ([pkfec](https://github.com/pkfec))

## [update_react_webpack](https://github.com/fecgov/openFEC/tree/update_react_webpack) (2019-01-15)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20181221...update_react_webpack)

**Closed issues:**

- Check logs Sprint 8.0 \(week 2\) [\#3539](https://github.com/fecgov/openFEC/issues/3539)
- Check logs Sprint 8.1 week 2 [\#3514](https://github.com/fecgov/openFEC/issues/3514)
- Check logs Sprint 8.1 week 1 [\#3513](https://github.com/fecgov/openFEC/issues/3513)

**Merged pull requests:**

- \[WIP\]\[MERGE WITH GITFLOW\]update react and react-dom to ^16.7.0, modify webpack to 4.19.1. [\#3556](https://github.com/fecgov/openFEC/pull/3556) ([fec-jli](https://github.com/fec-jli))

## [public-20181221](https://github.com/fecgov/openFEC/tree/public-20181221) (2018-12-21)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20181204...public-20181221)

**Fixed bugs:**

- 48-hour notices not showing up in /reports/house-senate/ [\#3507](https://github.com/fecgov/openFEC/issues/3507)

**Closed issues:**

- Check logs Sprint 8.0 \(week 1\) [\#3538](https://github.com/fecgov/openFEC/issues/3538)
- Check logs Sprint 7.7 Week 3 [\#3537](https://github.com/fecgov/openFEC/issues/3537)
- Add payee\_name and payee\_st fields to /electioneering/ endpoint results. [\#3535](https://github.com/fecgov/openFEC/issues/3535)
- Update sched\_e MV to support sort on non-standard s\_o\_ind value [\#3532](https://github.com/fecgov/openFEC/issues/3532)
- clean `requests module` in webservices/tasks/utils.py [\#3527](https://github.com/fecgov/openFEC/issues/3527)
- Swagger has incorrect field format for the load\_date field of candidates endpoint? [\#3496](https://github.com/fecgov/openFEC/issues/3496)
- Update Bastion Host tunnel variables [\#3492](https://github.com/fecgov/openFEC/issues/3492)
- Check logs Sprint 7.7 week 2 [\#3490](https://github.com/fecgov/openFEC/issues/3490)
- \[Med\] Snyk: Information Exposure requests module\(same as cms issue\) \[due 01/06/19\] [\#3478](https://github.com/fecgov/openFEC/issues/3478)
- Switching API to the fecp-driven sched tables: schedule c, schedule d, schedule e, schedule f tables and related objects [\#3089](https://github.com/fecgov/openFEC/issues/3089)

**Merged pull requests:**

- \[MERGE WITH GITFLOW\]Release/public 20181221 [\#3542](https://github.com/fecgov/openFEC/pull/3542) ([fec-jli](https://github.com/fec-jli))
- add-payee-columns-to-ec-endpoint [\#3536](https://github.com/fecgov/openFEC/pull/3536) ([pkfec](https://github.com/pkfec))
- Upgrade smart-open==1.7.1 and remove request module from task/utils.py  [\#3534](https://github.com/fecgov/openFEC/pull/3534) ([rjayasekera](https://github.com/rjayasekera))
- update ofec\_sched\_e\_mv to handle non-standard s\_o\_ind value [\#3533](https://github.com/fecgov/openFEC/pull/3533) ([fecjjeng](https://github.com/fecjjeng))
- switch to use fecp driven sched\_c, sched\_d, sched\_e, sched\_f tables [\#3526](https://github.com/fecgov/openFEC/pull/3526) ([fecjjeng](https://github.com/fecjjeng))
- ofec-3478 requests update to newest version 2.20.1 [\#3525](https://github.com/fecgov/openFEC/pull/3525) ([qqss88](https://github.com/qqss88))
- Modify the list of report types in report endpoints [\#3524](https://github.com/fecgov/openFEC/pull/3524) ([hcaofec](https://github.com/hcaofec))
- Change candidate load date datatype [\#3522](https://github.com/fecgov/openFEC/pull/3522) ([fec-jli](https://github.com/fec-jli))
- Upgrade marshmallow to 2\_16\_3 and marshmallow-sqlalchemy to 0\_15\_0 [\#3519](https://github.com/fecgov/openFEC/pull/3519) ([fec-jli](https://github.com/fec-jli))
- Rename 'contributor\_committee\_type' to 'recipient\_committee\_type' [\#3512](https://github.com/fecgov/openFEC/pull/3512) ([lbeaufort](https://github.com/lbeaufort))

## [public-20181204](https://github.com/fecgov/openFEC/tree/public-20181204) (2018-12-04)

[Full Changelog](https://github.com/fecgov/openFEC/compare/fix-disposition-data...public-20181204)

**Closed issues:**

- Make ScheE endpoint sortable by support oppose indicator from the API. [\#3518](https://github.com/fecgov/openFEC/issues/3518)
- Incorrect disposition data for MURs [\#3515](https://github.com/fecgov/openFEC/issues/3515)
- \[Med\] Snyk: Information Exposure: Upgrade marshmallow to version \[due 01/06/19\] [\#3479](https://github.com/fecgov/openFEC/issues/3479)

**Merged pull requests:**

- Make ScheE endpoint sortable by support\_oppose\_indicator [\#3520](https://github.com/fecgov/openFEC/pull/3520) ([pkfec](https://github.com/pkfec))
- \[MERGE WITH GIT FLOW\] Release/public 20181204 [\#3510](https://github.com/fecgov/openFEC/pull/3510) ([pkfec](https://github.com/pkfec))
- Fix elasticsearch backup logic [\#3508](https://github.com/fecgov/openFEC/pull/3508) ([lbeaufort](https://github.com/lbeaufort))
- drop original dsc\_sched\_b\_aggregate tables [\#3502](https://github.com/fecgov/openFEC/pull/3502) ([fecjjeng](https://github.com/fecjjeng))
- Add searchability to filings/operations-log endpoint [\#3493](https://github.com/fecgov/openFEC/pull/3493) ([hcaofec](https://github.com/hcaofec))
- Automate elasticsearch backups [\#3491](https://github.com/fecgov/openFEC/pull/3491) ([lbeaufort](https://github.com/lbeaufort))
- Create Bastion Host Tunnel in CircleCI configuration [\#3488](https://github.com/fecgov/openFEC/pull/3488) ([fec-jli](https://github.com/fec-jli))
- Test All endpoints automatically [\#3487](https://github.com/fecgov/openFEC/pull/3487) ([qqss88](https://github.com/qqss88))
- fix dev branch requirements.txt file. [\#3484](https://github.com/fecgov/openFEC/pull/3484) ([qqss88](https://github.com/qqss88))

## [fix-disposition-data](https://github.com/fecgov/openFEC/tree/fix-disposition-data) (2018-11-29)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20181120...fix-disposition-data)

**Fixed bugs:**

- Schedule\_e/by\_candidate bug [\#3343](https://github.com/fecgov/openFEC/issues/3343)

**Closed issues:**

- Rename `contributor\_committee\_type` to `recipient\_committee\_type` [\#3511](https://github.com/fecgov/openFEC/issues/3511)
- Missing information from bulk data [\#3503](https://github.com/fecgov/openFEC/issues/3503)
- Senate candidate showing up in wrong Senate class [\#3501](https://github.com/fecgov/openFEC/issues/3501)
- Check logs Sprint 7.7 week 1 [\#3489](https://github.com/fecgov/openFEC/issues/3489)
- Add searchability to filings/operations-log endpoint [\#3467](https://github.com/fecgov/openFEC/issues/3467)
- Drop old dsc\_sched\_b\_aggregate\_xxxxx tables after complete switch to new tables with update business logic [\#3459](https://github.com/fecgov/openFEC/issues/3459)
- Create FEC owned DNS entry for staging space [\#3320](https://github.com/fecgov/openFEC/issues/3320)
- Create Python tests [\#3273](https://github.com/fecgov/openFEC/issues/3273)
- Create the same test in PGTap and pytest for comparison [\#3272](https://github.com/fecgov/openFEC/issues/3272)
- Refine "Print full query" function [\#3238](https://github.com/fecgov/openFEC/issues/3238)
- Set up CloudFront for the stage space as well [\#3236](https://github.com/fecgov/openFEC/issues/3236)

**Merged pull requests:**

- \[MERGE WITH GIT FLOW\] Update disposition data to filter for case\_id [\#3517](https://github.com/fecgov/openFEC/pull/3517) ([lbeaufort](https://github.com/lbeaufort))

## [public-20181120](https://github.com/fecgov/openFEC/tree/public-20181120) (2018-11-20)

[Full Changelog](https://github.com/fecgov/openFEC/compare/show-2020-house-cand-history...public-20181120)

**Fixed bugs:**

- Example 1: Disbursements missing from /schedule\_b/by\_recipient/ [\#3390](https://github.com/fecgov/openFEC/issues/3390)

**Closed issues:**

- 502 errors for datatables [\#3495](https://github.com/fecgov/openFEC/issues/3495)
- Check logs Sprint 7.6 week 2 [\#3469](https://github.com/fecgov/openFEC/issues/3469)
- Check logs Sprint 7.6 week 1 [\#3468](https://github.com/fecgov/openFEC/issues/3468)
- Automate elasticsearch backups [\#3143](https://github.com/fecgov/openFEC/issues/3143)

**Merged pull requests:**

- Disable sort\_nulls\_last for Sch A and B [\#3494](https://github.com/fecgov/openFEC/pull/3494) ([lbeaufort](https://github.com/lbeaufort))
- \[MERGE WITH GIT FLOW\] Release/public 20181120 [\#3486](https://github.com/fecgov/openFEC/pull/3486) ([hcaofec](https://github.com/hcaofec))
- Show history for first-time, future-cycle house candidates [\#3483](https://github.com/fecgov/openFEC/pull/3483) ([lbeaufort](https://github.com/lbeaufort))
- Revert "fixing requirements.txt on develop branch." [\#3482](https://github.com/fecgov/openFEC/pull/3482) ([lbeaufort](https://github.com/lbeaufort))
- Switch to new schedule B aggrgeate tables with memo totals [\#3481](https://github.com/fecgov/openFEC/pull/3481) ([hcaofec](https://github.com/hcaofec))
- Add ‘count’ col to ScheduleABySizeCandidateView and  ScheduleAByStateCandidateView [\#3475](https://github.com/fecgov/openFEC/pull/3475) ([fec-jli](https://github.com/fec-jli))
- Add optional parameter to sort nulls last [\#3474](https://github.com/fecgov/openFEC/pull/3474) ([lbeaufort](https://github.com/lbeaufort))
- Update sale or use link in open api [\#3473](https://github.com/fecgov/openFEC/pull/3473) ([dorothyyeager](https://github.com/dorothyyeager))
- Add contributor committee type filter to sched\_a end point. [\#3472](https://github.com/fecgov/openFEC/pull/3472) ([rjayasekera](https://github.com/rjayasekera))
- refactor ofec\_filings\_all\_mv to remove redundent RFAI rows [\#3471](https://github.com/fecgov/openFEC/pull/3471) ([fecjjeng](https://github.com/fecjjeng))
- Add handling for include/exclude AO citations [\#3465](https://github.com/fecgov/openFEC/pull/3465) ([lbeaufort](https://github.com/lbeaufort))

## [show-2020-house-cand-history](https://github.com/fecgov/openFEC/tree/show-2020-house-cand-history) (2018-11-09)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20181106...show-2020-house-cand-history)

**Fixed bugs:**

- Fields in results returned by the /committee/{committee\_id}/reports/ endpoint are mis-mapped. [\#3435](https://github.com/fecgov/openFEC/issues/3435)

**Closed issues:**

- Raw house/senate efilings throwing 500 error [\#3476](https://github.com/fecgov/openFEC/issues/3476)
- Add ability to sort nulls last [\#3470](https://github.com/fecgov/openFEC/issues/3470)
- AOs: Short-term fix for AO missed/false positive citations [\#3461](https://github.com/fecgov/openFEC/issues/3461)
- No count for /schedule\_a/by\_size/by\_candidate/ [\#3456](https://github.com/fecgov/openFEC/issues/3456)
- Check logs Sprint 7.5 week 2 [\#3446](https://github.com/fecgov/openFEC/issues/3446)
- IE missing from /schedule\_e/by\_candidate [\#3417](https://github.com/fecgov/openFEC/issues/3417)

**Merged pull requests:**

- \[MERGE WITH GIT FLOW\] Show 2020 house candidate history [\#3485](https://github.com/fecgov/openFEC/pull/3485) ([lbeaufort](https://github.com/lbeaufort))

## [public-20181106](https://github.com/fecgov/openFEC/tree/public-20181106) (2018-11-06)

[Full Changelog](https://github.com/fecgov/openFEC/compare/add-fallback-zero-values...public-20181106)

**Closed issues:**

- Add committee\_type filter to schedules/schedule\_a endpoint [\#3248](https://github.com/fecgov/openFEC/issues/3248)

**Merged pull requests:**

- \[MERGE WITH GIT FLOW\] Release/public 20181106 [\#3464](https://github.com/fecgov/openFEC/pull/3464) ([lbeaufort](https://github.com/lbeaufort))
- Feature/add amndt number to sched e mv [\#3463](https://github.com/fecgov/openFEC/pull/3463) ([pkfec](https://github.com/pkfec))
- add memo agg to sched b agg tables [\#3460](https://github.com/fecgov/openFEC/pull/3460) ([fecjjeng](https://github.com/fecjjeng))
- Add missing Form 4 totals to PAC/Party totals [\#3458](https://github.com/fecgov/openFEC/pull/3458) ([lbeaufort](https://github.com/lbeaufort))
- \[MERGE TO DEVELOP\]feature/fix-3448-IE-bug [\#3452](https://github.com/fecgov/openFEC/pull/3452) ([pkfec](https://github.com/pkfec))
- Add spender committee type filter into ScheduleBView [\#3449](https://github.com/fecgov/openFEC/pull/3449) ([fec-jli](https://github.com/fec-jli))
- Feature/fix missing f4 and f13 committees [\#3432](https://github.com/fecgov/openFEC/pull/3432) ([pkfec](https://github.com/pkfec))

## [add-fallback-zero-values](https://github.com/fecgov/openFEC/tree/add-fallback-zero-values) (2018-11-06)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20181023...add-fallback-zero-values)

**Fixed bugs:**

- /filings/ count incorrectly counting RFAI's twice [\#3440](https://github.com/fecgov/openFEC/issues/3440)
- Missing: Committee profiles of inaugural committees [\#3382](https://github.com/fecgov/openFEC/issues/3382)
- Inconsistency between information displayed on data page and download file [\#3353](https://github.com/fecgov/openFEC/issues/3353)

**Closed issues:**

- Add Amendment number to schedule e endpoint [\#3462](https://github.com/fecgov/openFEC/issues/3462)
- Missing summary fields for F4 filers [\#3457](https://github.com/fecgov/openFEC/issues/3457)
- Check logs Sprint 7.5 week 1 [\#3445](https://github.com/fecgov/openFEC/issues/3445)
- Mis-mapped fields at /committee/{committee\_id}/reports/ for Senate/paper reports [\#3434](https://github.com/fecgov/openFEC/issues/3434)
- Change sched\_b\_aggregate tables to include count and totals for memo entries [\#3431](https://github.com/fecgov/openFEC/issues/3431)

**Merged pull requests:**

- \[MERGE WITH GIT FLOW\] Add fallback zero values for Form 3 cash-on-hand [\#3477](https://github.com/fecgov/openFEC/pull/3477) ([lbeaufort](https://github.com/lbeaufort))

## [public-20181023](https://github.com/fecgov/openFEC/tree/public-20181023) (2018-10-23)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20181009...public-20181023)

**Fixed bugs:**

- Add prev\_file\_num and amndt\_ind to /schedules/schedule\_e/ endpoint [\#3448](https://github.com/fecgov/openFEC/issues/3448)
- Count estimate for receipts search approximately doubles the amount returned [\#3104](https://github.com/fecgov/openFEC/issues/3104)

**Closed issues:**

- invoke-restmethod : Cannot send a content-body with this verb-type [\#3447](https://github.com/fecgov/openFEC/issues/3447)
- Only show authorized committee\_ids on /elections/ endpoint [\#3442](https://github.com/fecgov/openFEC/issues/3442)
- Create Table for party committees that need to be distinguished beyond normal form 1 data [\#3441](https://github.com/fecgov/openFEC/issues/3441)
- Example 2:  disbursements missing from /schedule\_b/by\_recipient/ [\#3429](https://github.com/fecgov/openFEC/issues/3429)
- Flask upgrade testing - a followup on \#3403 [\#3409](https://github.com/fecgov/openFEC/issues/3409)
- Research visualization framework options [\#3406](https://github.com/fecgov/openFEC/issues/3406)
- Refactor materialized views and insert test data into base tables to include  F13 and F4. [\#3400](https://github.com/fecgov/openFEC/issues/3400)
- Check logs Sprint 7.3 week 2 [\#3395](https://github.com/fecgov/openFEC/issues/3395)
- Add column cmte\_tp to fec\_fitem\_sched\_a and fec\_fitem\_sched\_b tables [\#3379](https://github.com/fecgov/openFEC/issues/3379)
- upgrade Flask and Flask-related modules to the newest version [\#3371](https://github.com/fecgov/openFEC/issues/3371)
- Add `spender\_committee\_type` filter to schedules/schedule\_b/ endpoint [\#3274](https://github.com/fecgov/openFEC/issues/3274)

**Merged pull requests:**

- \[MERGE TO RELEASE\]feature/fix-3448-IE-bug [\#3451](https://github.com/fecgov/openFEC/pull/3451) ([pkfec](https://github.com/pkfec))
- \[MERGE WITH GIT FLOW\] Release/public 20181023 [\#3444](https://github.com/fecgov/openFEC/pull/3444) ([patphongs](https://github.com/patphongs))
- Show only authorized \(P, A\) committee\_ids [\#3443](https://github.com/fecgov/openFEC/pull/3443) ([lbeaufort](https://github.com/lbeaufort))
- remove duplicated rows of staging.ref\_rpt\_tp in sample\_db.sql [\#3427](https://github.com/fecgov/openFEC/pull/3427) ([hcaofec](https://github.com/hcaofec))
- add cmte\_tp column and related indexes to fec\_fitem\_sched\_a and fec\_f… [\#3425](https://github.com/fecgov/openFEC/pull/3425) ([fecjjeng](https://github.com/fecjjeng))
- Refactor mv and add testing data to sample db [\#3424](https://github.com/fecgov/openFEC/pull/3424) ([hcaofec](https://github.com/hcaofec))
- Use full text filter for aggregate resources [\#3423](https://github.com/fecgov/openFEC/pull/3423) ([lbeaufort](https://github.com/lbeaufort))
- Set 500k threshold estimate for all endpoints [\#3421](https://github.com/fecgov/openFEC/pull/3421) ([lbeaufort](https://github.com/lbeaufort))
- Disables strict slashes in API, add 404 error handler [\#3419](https://github.com/fecgov/openFEC/pull/3419) ([patphongs](https://github.com/patphongs))
- Update Flask and Flask-related packages. [\#3403](https://github.com/fecgov/openFEC/pull/3403) ([qqss88](https://github.com/qqss88))

## [public-20181009](https://github.com/fecgov/openFEC/tree/public-20181009) (2018-10-09)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20180925...public-20181009)

**Fixed bugs:**

- Senate committees don't display the Raw electronic filings box [\#3413](https://github.com/fecgov/openFEC/issues/3413)
- Maps and district search don't work in IE [\#3407](https://github.com/fecgov/openFEC/issues/3407)
- Need to remove AO citation from AO 2011-12 canonical page [\#3393](https://github.com/fecgov/openFEC/issues/3393)
- /filings/ endpoint marking more than one `most\_recent` Form 1 \(Statement of Organization\) [\#3096](https://github.com/fecgov/openFEC/issues/3096)

**Closed issues:**

- Research performance impact of better counts [\#3415](https://github.com/fecgov/openFEC/issues/3415)
- Offboard Andrew Burnes [\#3411](https://github.com/fecgov/openFEC/issues/3411)
- Offboard Vraj Mohan [\#3410](https://github.com/fecgov/openFEC/issues/3410)
- Drop public.ofec\_entity\_chart\_mv [\#3399](https://github.com/fecgov/openFEC/issues/3399)
- Check logs Sprint 7.3 week 1 [\#3394](https://github.com/fecgov/openFEC/issues/3394)
- Missing links to transaction level data: Candidate and committee profile pages [\#3391](https://github.com/fecgov/openFEC/issues/3391)
- Counts - when to use exact and when to use estimates [\#3389](https://github.com/fecgov/openFEC/issues/3389)
- Backup & reload legal docs in stage & prod [\#3376](https://github.com/fecgov/openFEC/issues/3376)
- Check logs Sprint 7.2 week 2 [\#3367](https://github.com/fecgov/openFEC/issues/3367)

**Merged pull requests:**

- \[MERGE WITH GIT FLOW\] Release/public 20181009 [\#3416](https://github.com/fecgov/openFEC/pull/3416) ([lbeaufort](https://github.com/lbeaufort))
- drop ofec\_entity\_chart and its nightly refreshing [\#3414](https://github.com/fecgov/openFEC/pull/3414) ([hcaofec](https://github.com/hcaofec))
- Use cache key prefix for finer control of cache [\#3397](https://github.com/fecgov/openFEC/pull/3397) ([vrajmohan](https://github.com/vrajmohan))
- Fix "most recent" logic for Forms 1, 2, and 1M [\#3392](https://github.com/fecgov/openFEC/pull/3392) ([lbeaufort](https://github.com/lbeaufort))
- Add Swagger docs for legal API [\#3387](https://github.com/fecgov/openFEC/pull/3387) ([vrajmohan](https://github.com/vrajmohan))
- Update apispec package to use fecgov's forked repo [\#3362](https://github.com/fecgov/openFEC/pull/3362) ([lbeaufort](https://github.com/lbeaufort))

## [public-20180925](https://github.com/fecgov/openFEC/tree/public-20180925) (2018-09-25)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20180911...public-20180925)

**Fixed bugs:**

- Research: Unable to get a complete pull of schedules/schedule\_a/ [\#3369](https://github.com/fecgov/openFEC/issues/3369)
- Research: Investigate possible bug in /schedules/schedule\_a/ - compare data to line totals on report [\#3105](https://github.com/fecgov/openFEC/issues/3105)

**Security fixes:**

- \[Med\] Snyk - Arbitrary Code Execution \(due 9/10\) [\#3280](https://github.com/fecgov/openFEC/issues/3280)

**Closed issues:**

- Test raising counts.count\_exact threshold for endpoints [\#3385](https://github.com/fecgov/openFEC/issues/3385)
- Remove display of count estimate for receipts and disbursements [\#3381](https://github.com/fecgov/openFEC/issues/3381)
- Research: Investigate how to best optimize slow queries [\#3380](https://github.com/fecgov/openFEC/issues/3380)
- Analyze and optimize: Slow queries [\#3378](https://github.com/fecgov/openFEC/issues/3378)
- Add /legal/ to API developer docs [\#3377](https://github.com/fecgov/openFEC/issues/3377)
- Check logs Sprint 7.2 week 1 [\#3366](https://github.com/fecgov/openFEC/issues/3366)
- Research: Slow queries performance tuning [\#3360](https://github.com/fecgov/openFEC/issues/3360)
- Add ADR and AF to API [\#3359](https://github.com/fecgov/openFEC/issues/3359)
- Discuss baseline flyway migrations [\#3358](https://github.com/fecgov/openFEC/issues/3358)
- Research: Add committee type column for schedule\_a and schedule\_b [\#3357](https://github.com/fecgov/openFEC/issues/3357)
- Upgrade to latest apispec and flask-apispec versions [\#3356](https://github.com/fecgov/openFEC/issues/3356)
- Show Committee ID on Committees CFD page [\#3354](https://github.com/fecgov/openFEC/issues/3354)
- Check logs Sprint 7.1 week 2 [\#3347](https://github.com/fecgov/openFEC/issues/3347)
- \[High\] Synk - Improper Input Validation \(due 09/21/18\) [\#3344](https://github.com/fecgov/openFEC/issues/3344)
- Add filters for candidate state, district, and party affiliation to /schedules/schedule\_e/ [\#3276](https://github.com/fecgov/openFEC/issues/3276)
- Research  ofec\_all\_report\_mv [\#3230](https://github.com/fecgov/openFEC/issues/3230)
- Refactor AO and MUR schema creation for tests [\#2835](https://github.com/fecgov/openFEC/issues/2835)

**Merged pull requests:**

- Use cache key prefix for finer control of cache [\#3402](https://github.com/fecgov/openFEC/pull/3402) ([patphongs](https://github.com/patphongs))
- Release/public 20180925 [\#3388](https://github.com/fecgov/openFEC/pull/3388) ([pkfec](https://github.com/pkfec))
- Flask upgrade from 0.12 to 0.12.4 [\#3386](https://github.com/fecgov/openFEC/pull/3386) ([johnnyporkchops](https://github.com/johnnyporkchops))
- Add ADR and AF to celery reload task [\#3374](https://github.com/fecgov/openFEC/pull/3374) ([lbeaufort](https://github.com/lbeaufort))
- openFEC\#3344: Flask upgrade from 0.12 to 0.12.3. [\#3372](https://github.com/fecgov/openFEC/pull/3372) ([qqss88](https://github.com/qqss88))
- Feature/refactor ao mur test schema [\#3368](https://github.com/fecgov/openFEC/pull/3368) ([vrajmohan](https://github.com/vrajmohan))
- Add ADRs and AFs to API [\#3365](https://github.com/fecgov/openFEC/pull/3365) ([lbeaufort](https://github.com/lbeaufort))
- Add filters to schedule\_e endpoint. [\#3348](https://github.com/fecgov/openFEC/pull/3348) ([pkfec](https://github.com/pkfec))

## [public-20180911](https://github.com/fecgov/openFEC/tree/public-20180911) (2018-09-11)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20180828...public-20180911)

**Fixed bugs:**

- Statutory citation filter broken [\#3271](https://github.com/fecgov/openFEC/issues/3271)

**Closed issues:**

- Add `candidate\_office\_sought` to schedules/schedule\_e [\#3370](https://github.com/fecgov/openFEC/issues/3370)
- Update pytest version to 3.7.4 [\#3350](https://github.com/fecgov/openFEC/issues/3350)
- Check logs Sprint 7.1 week 1 [\#3346](https://github.com/fecgov/openFEC/issues/3346)
- Check logs - 'bug week and planning'  [\#3345](https://github.com/fecgov/openFEC/issues/3345)
- Add upcoming election data to Map feature [\#3168](https://github.com/fecgov/openFEC/issues/3168)
- Transfer GSA managed AWS account to FEC [\#3158](https://github.com/fecgov/openFEC/issues/3158)

**Merged pull requests:**

- Feature/fix statutory citation bug [\#3363](https://github.com/fecgov/openFEC/pull/3363) ([vrajmohan](https://github.com/vrajmohan))
- Rename 'ofec\_rad\_analyst\_vw.assignment\_update' to 'assignment\_update\_date' [\#3361](https://github.com/fecgov/openFEC/pull/3361) ([lbeaufort](https://github.com/lbeaufort))
- Release/public 20180911 [\#3355](https://github.com/fecgov/openFEC/pull/3355) ([lbeaufort](https://github.com/lbeaufort))
- Bump pytest to 3.7.4 [\#3351](https://github.com/fecgov/openFEC/pull/3351) ([vrajmohan](https://github.com/vrajmohan))
- Feature/refactor tests [\#3342](https://github.com/fecgov/openFEC/pull/3342) ([vrajmohan](https://github.com/vrajmohan))
- Remove stale code [\#3340](https://github.com/fecgov/openFEC/pull/3340) ([vrajmohan](https://github.com/vrajmohan))
- Add filters to help ServiceNow query more efficiently [\#3316](https://github.com/fecgov/openFEC/pull/3316) ([lbeaufort](https://github.com/lbeaufort))

## [public-20180828](https://github.com/fecgov/openFEC/tree/public-20180828) (2018-08-28)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20180814...public-20180828)

**Fixed bugs:**

- Missing Total - Discrepancy between two API calls [\#3215](https://github.com/fecgov/openFEC/issues/3215)

**Closed issues:**

- Check logs sprint 6.6 \(Dr. Smith\) week 3 [\#3338](https://github.com/fecgov/openFEC/issues/3338)
- Making "updated" fields available & searchable in API endpoints [\#3333](https://github.com/fecgov/openFEC/issues/3333)
- Add column orig\_amndt\_dt to form\_9 tables [\#3330](https://github.com/fecgov/openFEC/issues/3330)
- Check logs sprint 6.6 \(Dr. Smith\) week 2 [\#3319](https://github.com/fecgov/openFEC/issues/3319)

**Merged pull requests:**

- \[MERGE WITH GITFLOW\] Release/public 20180828 [\#3339](https://github.com/fecgov/openFEC/pull/3339) ([hcaofec](https://github.com/hcaofec))
- Remove Code Climate badge \(not used\) [\#3337](https://github.com/fecgov/openFEC/pull/3337) ([vrajmohan](https://github.com/vrajmohan))
- add column orig\_amndt\_dt to form\_9 [\#3335](https://github.com/fecgov/openFEC/pull/3335) ([fecjjeng](https://github.com/fecjjeng))
- Use FEC-wide license and contributing documents [\#3334](https://github.com/fecgov/openFEC/pull/3334) ([lbeaufort](https://github.com/lbeaufort))

## [public-20180814](https://github.com/fecgov/openFEC/tree/public-20180814) (2018-08-14)

[Full Changelog](https://github.com/fecgov/openFEC/compare/revert-es-settings...public-20180814)

**Fixed bugs:**

- Dead link in Documentation needs to be fixed [\#3296](https://github.com/fecgov/openFEC/issues/3296)
- Fix archived MURs with wrong names, only partial PDFs [\#3234](https://github.com/fecgov/openFEC/issues/3234)
- Change coverage end date logic for candidate and committee raising/spending pages [\#3217](https://github.com/fecgov/openFEC/issues/3217)

**Closed issues:**

- Add no migrations flag for manual deploy [\#3324](https://github.com/fecgov/openFEC/issues/3324)
- Check logs sprint 6.6 \(Dr. Smith\) week 1 [\#3318](https://github.com/fecgov/openFEC/issues/3318)
- Update ofec\_agg\_coverage\_date\_mv logic [\#3313](https://github.com/fecgov/openFEC/issues/3313)
- Check logs sprint 6.5 \(Penny Robinson\) week 2 [\#3301](https://github.com/fecgov/openFEC/issues/3301)
- Intermittent page not found errors from AO search [\#3270](https://github.com/fecgov/openFEC/issues/3270)
- Show non-US states in Schedule A by state aggregates [\#3246](https://github.com/fecgov/openFEC/issues/3246)
- 2020/2022 elections missing from /elections/ [\#3243](https://github.com/fecgov/openFEC/issues/3243)
- Set caching headers in the API [\#3237](https://github.com/fecgov/openFEC/issues/3237)

**Merged pull requests:**

- \[MERGE WITH GITFLOW\] Release/public 20180814 [\#3329](https://github.com/fecgov/openFEC/pull/3329) ([fecjjeng](https://github.com/fecjjeng))
- Add better error message for missing migrator environmental variable [\#3327](https://github.com/fecgov/openFEC/pull/3327) ([lbeaufort](https://github.com/lbeaufort))
- Add ability to deploy without running migrations [\#3325](https://github.com/fecgov/openFEC/pull/3325) ([lbeaufort](https://github.com/lbeaufort))
- Add endpoint-specific caching [\#3322](https://github.com/fecgov/openFEC/pull/3322) ([lbeaufort](https://github.com/lbeaufort))
- Show non-US states\(Other\) in Committee Schedule A by state aggregates [\#3321](https://github.com/fecgov/openFEC/pull/3321) ([fec-jli](https://github.com/fec-jli))
- Update instructions on loading archived MURs [\#3317](https://github.com/fecgov/openFEC/pull/3317) ([lbeaufort](https://github.com/lbeaufort))
- Feature/update ofec agg coverage date mv logic [\#3314](https://github.com/fecgov/openFEC/pull/3314) ([fecjjeng](https://github.com/fecjjeng))
- Fixed dead SQL links in API docs [\#3311](https://github.com/fecgov/openFEC/pull/3311) ([patphongs](https://github.com/patphongs))
- Add transaction\_coverage\_date to candidate and committee totals [\#3310](https://github.com/fecgov/openFEC/pull/3310) ([lbeaufort](https://github.com/lbeaufort))
- fix mv node in flow file [\#3309](https://github.com/fecgov/openFEC/pull/3309) ([fecjjeng](https://github.com/fecjjeng))
- Update hotfix instructions in README [\#3305](https://github.com/fecgov/openFEC/pull/3305) ([lbeaufort](https://github.com/lbeaufort))
- \[WIP\]Enable zipcode search for foreign zipcodes, and remove input of 5-digits restricition [\#3264](https://github.com/fecgov/openFEC/pull/3264) ([hcaofec](https://github.com/hcaofec))

## [revert-es-settings](https://github.com/fecgov/openFEC/tree/revert-es-settings) (2018-07-31)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20180731...revert-es-settings)

**Merged pull requests:**

- \[MERGE WITH GIT FLOW\] Hotfix: Revert elasticsearch connection settings to the defaults [\#3315](https://github.com/fecgov/openFEC/pull/3315) ([lbeaufort](https://github.com/lbeaufort))

## [public-20180731](https://github.com/fecgov/openFEC/tree/public-20180731) (2018-07-31)

[Full Changelog](https://github.com/fecgov/openFEC/compare/elastic-search-connection-retry-on-timeouts...public-20180731)

**Closed issues:**

- Fix materialized view refresh error message [\#3308](https://github.com/fecgov/openFEC/issues/3308)
- Check logs sprint 6.5 \(Penny Robinson\) week 1 [\#3300](https://github.com/fecgov/openFEC/issues/3300)
- By Aug 1: Update the DNS entry for api.open.fec.gov [\#3293](https://github.com/fecgov/openFEC/issues/3293)
- Enable zipcode search for foreign zipcodes  [\#3054](https://github.com/fecgov/openFEC/issues/3054)

**Merged pull requests:**

- \[MERGE WITH GITFLOW\] Release/public 20180731 [\#3307](https://github.com/fecgov/openFEC/pull/3307) ([fec-jli](https://github.com/fec-jli))
- Fix elections endpoint to handle per\_page=0 [\#3303](https://github.com/fecgov/openFEC/pull/3303) ([fec-jli](https://github.com/fec-jli))
- Create itemized sched\_e related tables and transfer data from fecp to postgresql database in cloud [\#3298](https://github.com/fecgov/openFEC/pull/3298) ([fecjjeng](https://github.com/fecjjeng))
- \[WIP\]Refactor elections endpoint to handle candidate finance totals export function [\#3292](https://github.com/fecgov/openFEC/pull/3292) ([fec-jli](https://github.com/fec-jli))
- update migration file for permission problem [\#3287](https://github.com/fecgov/openFEC/pull/3287) ([fecjjeng](https://github.com/fecjjeng))
- Feature/enhance flask shell [\#3285](https://github.com/fecgov/openFEC/pull/3285) ([vrajmohan](https://github.com/vrajmohan))
- Remove `bandit` as it is no longer used [\#3284](https://github.com/fecgov/openFEC/pull/3284) ([vrajmohan](https://github.com/vrajmohan))
- Remove unused test code [\#3283](https://github.com/fecgov/openFEC/pull/3283) ([vrajmohan](https://github.com/vrajmohan))
- drop ofec\_sched\_a objects and process [\#3281](https://github.com/fecgov/openFEC/pull/3281) ([fecjjeng](https://github.com/fecjjeng))
- Modify `load\_archived\_murs` to properly handle MURs with multiple PDFs [\#3278](https://github.com/fecgov/openFEC/pull/3278) ([rjayasekera](https://github.com/rjayasekera))
- Allow more complex parsing of AO citations [\#3269](https://github.com/fecgov/openFEC/pull/3269) ([lbeaufort](https://github.com/lbeaufort))
- \[V0094, V0095 - merge after PR \#3223\] Change /totals/by\_entity/ to pull from entity\_chart\_vw; create ofec\_agg\_coverage\_date\_mv; [\#3251](https://github.com/fecgov/openFEC/pull/3251) ([hcaofec](https://github.com/hcaofec))
- Updating with pre-release testing [\#3077](https://github.com/fecgov/openFEC/pull/3077) ([patphongs](https://github.com/patphongs))

## [elastic-search-connection-retry-on-timeouts](https://github.com/fecgov/openFEC/tree/elastic-search-connection-retry-on-timeouts) (2018-07-25)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20180717...elastic-search-connection-retry-on-timeouts)

**Fixed bugs:**

- Individual contributor table loading slowly [\#3294](https://github.com/fecgov/openFEC/issues/3294)
- Reports missing on Committee \> Filings page in IE [\#3286](https://github.com/fecgov/openFEC/issues/3286)
- Research - Most recent filing of form 5s doesn't work for first time filers [\#3173](https://github.com/fecgov/openFEC/issues/3173)

**Closed issues:**

- Research: Coverage end date logic for /elections/ endpoint  [\#3295](https://github.com/fecgov/openFEC/issues/3295)
- Form 6 missing from Committee page 24/48 hr report section [\#3289](https://github.com/fecgov/openFEC/issues/3289)
- Check logs sprint 6.4 \(Maj. Don West\) week 2 [\#3267](https://github.com/fecgov/openFEC/issues/3267)
- Refactor elections \(ElectionView\) endpoint to extend ApiResource [\#3254](https://github.com/fecgov/openFEC/issues/3254)
- 18F training task: Figure out automated testing [\#3182](https://github.com/fecgov/openFEC/issues/3182)
- drop ofec\_sched\_a\_xxxx tables and related process [\#3099](https://github.com/fecgov/openFEC/issues/3099)
- Create itemized sched\_e related tables and transfer data from fecp to postgresql database in cloud [\#3007](https://github.com/fecgov/openFEC/issues/3007)

**Merged pull requests:**

- \[MERGE WITH GIT FLOW\] ElasticSearch connection is now set to retry on timeout [\#3306](https://github.com/fecgov/openFEC/pull/3306) ([pkfec](https://github.com/pkfec))

## [public-20180717](https://github.com/fecgov/openFEC/tree/public-20180717) (2018-07-17)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20180705...public-20180717)

**Fixed bugs:**

- AO's missing OCR text, leading to missing citations [\#3259](https://github.com/fecgov/openFEC/issues/3259)
- Elections endpoint is including joint fundraisers and inflating candidate receipts and disbursements [\#3221](https://github.com/fecgov/openFEC/issues/3221)
- Allow more complex parsing of citations in AOs [\#2276](https://github.com/fecgov/openFEC/issues/2276)
- \[V0086\] Fix candidate totals for future elections [\#3219](https://github.com/fecgov/openFEC/pull/3219) ([lbeaufort](https://github.com/lbeaufort))

**Closed issues:**

- Test new operations\_log endpoint [\#3282](https://github.com/fecgov/openFEC/issues/3282)
- \[High\] Arbitrary Code Execution [\#3279](https://github.com/fecgov/openFEC/issues/3279)
- Test multiple AO citations parsing [\#3277](https://github.com/fecgov/openFEC/issues/3277)
- Check logs sprint 6.4 \(Maj. Don West\) week 1 [\#3266](https://github.com/fecgov/openFEC/issues/3266)
- Load missing archived MUR 3620 [\#3256](https://github.com/fecgov/openFEC/issues/3256)
- Change /totals/by\_entity/ endpoint to pull from new data source [\#3240](https://github.com/fecgov/openFEC/issues/3240)
- Check logs sprint 6.3  \(Judy Robinson\) week 2 [\#3213](https://github.com/fecgov/openFEC/issues/3213)
- Investigate and expand committee\_id limit beyond five values [\#3209](https://github.com/fecgov/openFEC/issues/3209)
- Test data for entity charts [\#3208](https://github.com/fecgov/openFEC/issues/3208)
- Unit testing data with pgTAP [\#3202](https://github.com/fecgov/openFEC/issues/3202)
- AWS access transfer [\#3189](https://github.com/fecgov/openFEC/issues/3189)
- Ongoing - Document existing database model [\#3188](https://github.com/fecgov/openFEC/issues/3188)
- Swagger upgrade testing in dev and stage [\#3184](https://github.com/fecgov/openFEC/issues/3184)
- Ask public facing offices if other pages are missing filters [\#3180](https://github.com/fecgov/openFEC/issues/3180)
- drop ofec\_sched\_b\_xxxx tables and related process [\#3098](https://github.com/fecgov/openFEC/issues/3098)
- Elections 'won' Field Frequently Incorrect [\#3076](https://github.com/fecgov/openFEC/issues/3076)

**Merged pull requests:**

- \[MERGE WITH GIT FLOW\] Release/public 20180717 [\#3275](https://github.com/fecgov/openFEC/pull/3275) ([johnnyporkchops](https://github.com/johnnyporkchops))
- Feature/drop ofec sched b [\#3263](https://github.com/fecgov/openFEC/pull/3263) ([fecjjeng](https://github.com/fecjjeng))
- Feature/disable s3 cache calls [\#3257](https://github.com/fecgov/openFEC/pull/3257) ([pkfec](https://github.com/pkfec))
- Hide incumbent from /elections/search [\#3252](https://github.com/fecgov/openFEC/pull/3252) ([lbeaufort](https://github.com/lbeaufort))
- Add /committee/\<ID\>/totals/ to API docs [\#3245](https://github.com/fecgov/openFEC/pull/3245) ([lbeaufort](https://github.com/lbeaufort))
- Remove 'won' from /elections/ [\#3225](https://github.com/fecgov/openFEC/pull/3225) ([lbeaufort](https://github.com/lbeaufort))
- \[V0093\] create operations log endpoint [\#3203](https://github.com/fecgov/openFEC/pull/3203) ([pkfec](https://github.com/pkfec))

## [public-20180705](https://github.com/fecgov/openFEC/tree/public-20180705) (2018-07-05)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20180626...public-20180705)

**Fixed bugs:**

- Remove incumbent data from /elections/search/ endpoint [\#3247](https://github.com/fecgov/openFEC/issues/3247)
- Candidate PCC not displaying on election profile page [\#3244](https://github.com/fecgov/openFEC/issues/3244)
- Missing filings part 2: F3 filers that file on F3X [\#3154](https://github.com/fecgov/openFEC/issues/3154)

**Closed issues:**

- Remove S3 caching [\#3235](https://github.com/fecgov/openFEC/issues/3235)
- Data from 1999-2000 cycle missing [\#3232](https://github.com/fecgov/openFEC/issues/3232)
- Presidential 2017 - 2020 data on adv data table not displaying properly [\#3214](https://github.com/fecgov/openFEC/issues/3214)
- Check logs sprint 6.3  \(Judy Robinson\) week 1 [\#3212](https://github.com/fecgov/openFEC/issues/3212)
- Delete `ofec\_candidate\_totals\_mv\_2020\_tmp` in `dev` once \#3219 is merged [\#3199](https://github.com/fecgov/openFEC/issues/3199)
- Confirm forms 5, 7, 9 and 13 filings are available on reports and filings page [\#3179](https://github.com/fecgov/openFEC/issues/3179)
- Research - Documentation - Wenchun sets up rotation for future sprints [\#3157](https://github.com/fecgov/openFEC/issues/3157)
- Deploy tested Swagger Upgrade [\#3155](https://github.com/fecgov/openFEC/issues/3155)
- Verify on API/Webpage for Switching API to the fecp-driven sched\_b tables [\#3115](https://github.com/fecgov/openFEC/issues/3115)
- Add swagger test for when "cached calls" is turned on [\#3014](https://github.com/fecgov/openFEC/issues/3014)
- Use Postgres metadata to infer materialized view dependencies [\#2874](https://github.com/fecgov/openFEC/issues/2874)

**Merged pull requests:**

- Remove the joint fundraisers inflating money from totals [\#3255](https://github.com/fecgov/openFEC/pull/3255) ([fec-jli](https://github.com/fec-jli))
- \[MERGE WITH GITFLOW\] Release/public 20180705 [\#3242](https://github.com/fecgov/openFEC/pull/3242) ([rjayasekera](https://github.com/rjayasekera))
- Renamed weekly reload AO task to match what's in schedule [\#3241](https://github.com/fecgov/openFEC/pull/3241) ([rjayasekera](https://github.com/rjayasekera))
- Add committee\_designation filter into audit-case endpoint [\#3231](https://github.com/fecgov/openFEC/pull/3231) ([fec-jli](https://github.com/fec-jli))
- Update Flyway to v. 5.1.3 [\#3223](https://github.com/fecgov/openFEC/pull/3223) ([lbeaufort](https://github.com/lbeaufort))

## [public-20180626](https://github.com/fecgov/openFEC/tree/public-20180626) (2018-06-26)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20180619...public-20180626)

**Fixed bugs:**

- Data Issues collection for everyone to add to [\#3201](https://github.com/fecgov/openFEC/issues/3201)
- Candidates missing from totals endpoint \(Ossoff\) [\#3200](https://github.com/fecgov/openFEC/issues/3200)
- Research - Data not showing for host committees [\#3197](https://github.com/fecgov/openFEC/issues/3197)
- Incorrect totals for /candidates/totals for some candidates [\#3196](https://github.com/fecgov/openFEC/issues/3196)
- Fix totals for off-year special candidates on /candidates/totals endpoint [\#3198](https://github.com/fecgov/openFEC/pull/3198) ([lbeaufort](https://github.com/lbeaufort))

**Closed issues:**

- Create ofec\_all\_reports\_mv [\#3229](https://github.com/fecgov/openFEC/issues/3229)
- \[High Severity\] Update Flyway to 5.1.3 [\#3222](https://github.com/fecgov/openFEC/issues/3222)
- Test the fix for the candidates/totals endpoint [\#3207](https://github.com/fecgov/openFEC/issues/3207)
- Check logs sprint 6.2  \(the robot\) week 2 [\#3187](https://github.com/fecgov/openFEC/issues/3187)
- Swagger user testing [\#3170](https://github.com/fecgov/openFEC/issues/3170)
- Cached calls causing connectivity conundrums [\#3078](https://github.com/fecgov/openFEC/issues/3078)
- Investigate issue with rename\_indexes method in the DB [\#2871](https://github.com/fecgov/openFEC/issues/2871)
- Set up periodic refresh of Advisory Opinions [\#2856](https://github.com/fecgov/openFEC/issues/2856)

**Merged pull requests:**

- flyway badge addition [\#3228](https://github.com/fecgov/openFEC/pull/3228) ([patphongs](https://github.com/patphongs))
- \[MERGE WITH GIT FLOW\] Release/public 20180626 [\#3224](https://github.com/fecgov/openFEC/pull/3224) ([patphongs](https://github.com/patphongs))
- Feature/periodic refresh ao [\#3216](https://github.com/fecgov/openFEC/pull/3216) ([rjayasekera](https://github.com/rjayasekera))
- Upgrade boto3 to 1.7.21 [\#3210](https://github.com/fecgov/openFEC/pull/3210) ([vrajmohan](https://github.com/vrajmohan))
- Update Swagger UI to the latest release [\#3068](https://github.com/fecgov/openFEC/pull/3068) ([ccostino](https://github.com/ccostino))

## [public-20180619](https://github.com/fecgov/openFEC/tree/public-20180619) (2018-06-19)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20180529...public-20180619)

**Fixed bugs:**

- Candidate not showing in CO 7 [\#3218](https://github.com/fecgov/openFEC/issues/3218)
- Schedule A aggregate by state incorrect  [\#3142](https://github.com/fecgov/openFEC/issues/3142)
- Research - Leadership PAC sponsor: candidate ID missing [\#3056](https://github.com/fecgov/openFEC/issues/3056)
- API work: add committee filing frequency to /committees/ endpoint [\#3049](https://github.com/fecgov/openFEC/issues/3049)
- Required API parameters are not marked as required in rest.py [\#2963](https://github.com/fecgov/openFEC/issues/2963)
- Financial Summary election filters not returning the correct results at Candidate Profile pages [\#2811](https://github.com/fecgov/openFEC/issues/2811)

**Closed issues:**

- Check logs 6/13/18 [\#3211](https://github.com/fecgov/openFEC/issues/3211)
- Add Entity\_Chart table [\#3204](https://github.com/fecgov/openFEC/issues/3204)
- Close an issue that is referenced in a PR [\#3191](https://github.com/fecgov/openFEC/issues/3191)
- Production releases - cuts [\#3190](https://github.com/fecgov/openFEC/issues/3190)
- Check logs sprint 6.2  \(the robot\) week 1 [\#3186](https://github.com/fecgov/openFEC/issues/3186)
- API - SA Zipcode search needs to allow 9 digit and foreign zips  [\#3185](https://github.com/fecgov/openFEC/issues/3185)
- Make election fixes as necessary based on feedback from Press/Public records [\#3183](https://github.com/fecgov/openFEC/issues/3183)
- Fix sched a aggregate by state materialized view [\#3181](https://github.com/fecgov/openFEC/issues/3181)
- Outage follow-up: Make sure New Relic is alerting us to issues in the `dev` environment [\#3177](https://github.com/fecgov/openFEC/issues/3177)
- Outage follow-up: Connect to redis with uri parameter [\#3174](https://github.com/fecgov/openFEC/issues/3174)
- Fix audit-case type error in front-end [\#3172](https://github.com/fecgov/openFEC/issues/3172)
- Fix audit-case endpoint type-error in front-end code. [\#3171](https://github.com/fecgov/openFEC/issues/3171)
- Swagger 3.0 security vulnerabilities [\#3166](https://github.com/fecgov/openFEC/issues/3166)
- Discuss Data endpoint strategy and data model plan [\#3165](https://github.com/fecgov/openFEC/issues/3165)
- Find and synthesize existing classic map research [\#3161](https://github.com/fecgov/openFEC/issues/3161)
- Research - inventory data filters on CFD [\#3160](https://github.com/fecgov/openFEC/issues/3160)
- Sending Election profile pages to press and public records for testing and validation [\#3159](https://github.com/fecgov/openFEC/issues/3159)
- Add candidate\_pcc\_name and modify candidate\_pcc on /elections/ endpoint [\#3146](https://github.com/fecgov/openFEC/issues/3146)
- Restore Paper filings missing from API /reports/ and /filings/ [\#3103](https://github.com/fecgov/openFEC/issues/3103)
- Switching API to the fecp-driven sched\_a tables  [\#3088](https://github.com/fecgov/openFEC/issues/3088)
- \[Low risk\] Upgrade boto3 to version 1.4.5 or higher  [\#3087](https://github.com/fecgov/openFEC/issues/3087)
- Check logs 6/06/18 [\#3083](https://github.com/fecgov/openFEC/issues/3083)
- Check logs 5/30/18 [\#3082](https://github.com/fecgov/openFEC/issues/3082)
- Upgrade API to use Elasticsearch 5.6 [\#2921](https://github.com/fecgov/openFEC/issues/2921)
- Implement "No data found" page for candidates like we have for committees [\#2849](https://github.com/fecgov/openFEC/issues/2849)
- Make schedule E a materialized view [\#2825](https://github.com/fecgov/openFEC/issues/2825)
- Create partitioned schedule tables in new website then transfer data to new website [\#2793](https://github.com/fecgov/openFEC/issues/2793)
- investigating custom ELK alerts  [\#2785](https://github.com/fecgov/openFEC/issues/2785)
- Figure out better ways of testing downloads- New Relic  [\#2750](https://github.com/fecgov/openFEC/issues/2750)
- Outline API changes to support compliance/election summary designs [\#2739](https://github.com/fecgov/openFEC/issues/2739)
- Access to celery-worker status email to FEC staff [\#2725](https://github.com/fecgov/openFEC/issues/2725)
- Finish testing multi-year cycle search of itemized data [\#2685](https://github.com/fecgov/openFEC/issues/2685)
- Start testing multiple cycle searches and filtering with schedule A and B data [\#2630](https://github.com/fecgov/openFEC/issues/2630)
- Year end report not showing as amended [\#2490](https://github.com/fecgov/openFEC/issues/2490)

**Merged pull requests:**

- \[MERGE WITH GIT FLOW\] Release/public 20180619 [\#3206](https://github.com/fecgov/openFEC/pull/3206) ([pkfec](https://github.com/pkfec))
- add table entity\_chart [\#3205](https://github.com/fecgov/openFEC/pull/3205) ([fecjjeng](https://github.com/fecjjeng))
- Fix missing reports from API's /reports/ endpoint [\#3195](https://github.com/fecgov/openFEC/pull/3195) ([hcaofec](https://github.com/hcaofec))
- Fix join on state for ofec\_sched\_a\_aggregate\_state\_recipient\_totals\_mv [\#3194](https://github.com/fecgov/openFEC/pull/3194) ([lbeaufort](https://github.com/lbeaufort))
- Fix test\_download function test\_download\_forbidden [\#3193](https://github.com/fecgov/openFEC/pull/3193) ([fec-jli](https://github.com/fec-jli))
- Closing issue using keyword "resolves" in PR [\#3192](https://github.com/fecgov/openFEC/pull/3192) ([patphongs](https://github.com/patphongs))
- Connect to Redis using URI parameter [\#3178](https://github.com/fecgov/openFEC/pull/3178) ([lbeaufort](https://github.com/lbeaufort))
- Feature/switch sched a [\#3169](https://github.com/fecgov/openFEC/pull/3169) ([fecjjeng](https://github.com/fecjjeng))
- add form\_tp to report mv [\#3164](https://github.com/fecgov/openFEC/pull/3164) ([hcaofec](https://github.com/hcaofec))
- Feature/upgrade sqlalchemy [\#3153](https://github.com/fecgov/openFEC/pull/3153) ([vrajmohan](https://github.com/vrajmohan))
- Restore Flask.app logger [\#3150](https://github.com/fecgov/openFEC/pull/3150) ([vrajmohan](https://github.com/vrajmohan))

## [public-20180529](https://github.com/fecgov/openFEC/tree/public-20180529) (2018-05-30)

[Full Changelog](https://github.com/fecgov/openFEC/compare/upgrade-celery-for-kombu-issues...public-20180529)

**Closed issues:**

- Complete Implementation of Swagger 3.0 [\#3163](https://github.com/fecgov/openFEC/issues/3163)
- Schedule A switch to FECP Tables - Continuation [\#3156](https://github.com/fecgov/openFEC/issues/3156)
- Implement Swagger 3.0 [\#3094](https://github.com/fecgov/openFEC/issues/3094)
- Research upgrading SQLAlchemy and other dependencies [\#3066](https://github.com/fecgov/openFEC/issues/3066)
- Candidate Data Incorrect [\#3055](https://github.com/fecgov/openFEC/issues/3055)
- Filings Search timing out issue [\#2900](https://github.com/fecgov/openFEC/issues/2900)

**Merged pull requests:**

- Upgrade Celery to fix kombu issues [\#3152](https://github.com/fecgov/openFEC/pull/3152) ([vrajmohan](https://github.com/vrajmohan))
- Release/public 20180529 [\#3149](https://github.com/fecgov/openFEC/pull/3149) ([lbeaufort](https://github.com/lbeaufort))
- Feature/create sample db data [\#3148](https://github.com/fecgov/openFEC/pull/3148) ([rjayasekera](https://github.com/rjayasekera))
- Add candidate primary campaign committee name [\#3147](https://github.com/fecgov/openFEC/pull/3147) ([lbeaufort](https://github.com/lbeaufort))
- Feature/required api parameter [\#3141](https://github.com/fecgov/openFEC/pull/3141) ([rjayasekera](https://github.com/rjayasekera))
- create new materialized view to include form\_3 submitted by pac and party [\#3139](https://github.com/fecgov/openFEC/pull/3139) ([hcaofec](https://github.com/hcaofec))
- Feature/cmte filing freq [\#3137](https://github.com/fecgov/openFEC/pull/3137) ([rjayasekera](https://github.com/rjayasekera))
- Add some comments for audit committee and candidate search. [\#3136](https://github.com/fecgov/openFEC/pull/3136) ([fec-jli](https://github.com/fec-jli))
- Fixed audit committee and candidate name sub-string search [\#3119](https://github.com/fecgov/openFEC/pull/3119) ([fec-jli](https://github.com/fec-jli))
- Clean up unused slack notification task [\#3116](https://github.com/fecgov/openFEC/pull/3116) ([lbeaufort](https://github.com/lbeaufort))
- Feature/refresh electronic amendments mvs [\#3114](https://github.com/fecgov/openFEC/pull/3114) ([vrajmohan](https://github.com/vrajmohan))
- Upgrade Elasticsearch to v. 5.6 [\#3111](https://github.com/fecgov/openFEC/pull/3111) ([lbeaufort](https://github.com/lbeaufort))
- Feature/refresh mvs [\#3107](https://github.com/fecgov/openFEC/pull/3107) ([vrajmohan](https://github.com/vrajmohan))
- Add candidate\_pcc to /elections/ endpoint [\#2901](https://github.com/fecgov/openFEC/pull/2901) ([lbeaufort](https://github.com/lbeaufort))

## [upgrade-celery-for-kombu-issues](https://github.com/fecgov/openFEC/tree/upgrade-celery-for-kombu-issues) (2018-05-22)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20180515...upgrade-celery-for-kombu-issues)

**Closed issues:**

- Update sample\_db SQL to include test data for ofec\_totals\_parties\_mv [\#3135](https://github.com/fecgov/openFEC/issues/3135)
- Update sample\_db SQL to include test data for ofec\_totals\_pacs\_parties\_mv [\#3134](https://github.com/fecgov/openFEC/issues/3134)
- Update sample\_db SQL to include test data for ofec\_totals\_pacs\_mv [\#3133](https://github.com/fecgov/openFEC/issues/3133)
- Update sample\_db SQL to include test data for ofec\_totals\_ie\_only\_mv [\#3132](https://github.com/fecgov/openFEC/issues/3132)
- Update sample\_db SQL to include test data for ofec\_totals\_candidate\_committees\_mv [\#3131](https://github.com/fecgov/openFEC/issues/3131)
- Update sample\_db SQL to include test data for ofec\_sched\_f\_mv [\#3130](https://github.com/fecgov/openFEC/issues/3130)
- Update sample\_db SQL to include test data for ofec\_sched\_e\_aggregate\_candidate\_mv [\#3129](https://github.com/fecgov/openFEC/issues/3129)
- Update sample\_db SQL to include test data for ofec\_sched\_c\_mv [\#3128](https://github.com/fecgov/openFEC/issues/3128)
- Update sample\_db SQL to include test data for ofec\_sched\_a\_aggregate\_state\_recipient\_totals\_mv [\#3127](https://github.com/fecgov/openFEC/issues/3127)
- Update sample\_db SQL to include test data for ofec\_rad\_mv [\#3126](https://github.com/fecgov/openFEC/issues/3126)
- Update sample\_db SQL to include test data for ofec\_entity\_chart\_mv [\#3125](https://github.com/fecgov/openFEC/issues/3125)
- Update sample\_db SQL to include test data for ofec\_elections\_list\_mv [\#3124](https://github.com/fecgov/openFEC/issues/3124)
- Update sample\_db SQL to include test data for ofec\_electioneering\_mv [\#3123](https://github.com/fecgov/openFEC/issues/3123)
- Update sample\_db SQL to include test data for ofec\_electioneering\_aggregate\_candidate\_mv [\#3122](https://github.com/fecgov/openFEC/issues/3122)
- Update sample\_db SQL to include test data for ofec\_election\_result\_mv [\#3121](https://github.com/fecgov/openFEC/issues/3121)
- Update sample\_db SQL to include test data for ofec\_communication\_cost\_mv [\#3120](https://github.com/fecgov/openFEC/issues/3120)
- Update sample\_db SQL to include test data for ofec\_communication\_cost\_aggregate\_candidate\_mv [\#3113](https://github.com/fecgov/openFEC/issues/3113)
- Update sample\_db SQL to include test data for ofec\_committee\_fulltext\_audit\_mv [\#3112](https://github.com/fecgov/openFEC/issues/3112)
- Update sample\_db SQL to include test data for ofec\_candidate\_totals\_mv [\#3110](https://github.com/fecgov/openFEC/issues/3110)
- Update sample\_db SQL to include test data for ofec\_candidate\_fulltext\_audit\_mv [\#3109](https://github.com/fecgov/openFEC/issues/3109)
- Extra `\<i` character in archived MUR ORC text causing display issue [\#3090](https://github.com/fecgov/openFEC/issues/3090)
- Update sample\_db SQL to include test data for all MV's  [\#3062](https://github.com/fecgov/openFEC/issues/3062)

**Merged pull requests:**

- \[Merge with git flow\] Hotfix/upgrade celery for kombu issues [\#3151](https://github.com/fecgov/openFEC/pull/3151) ([vrajmohan](https://github.com/vrajmohan))

## [public-20180515](https://github.com/fecgov/openFEC/tree/public-20180515) (2018-05-16)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20180502...public-20180515)

**Fixed bugs:**

- Research Paper filings missing from API /reports/ and /filings/ [\#3038](https://github.com/fecgov/openFEC/issues/3038)

**Closed issues:**

- \[Sync\] Command Injection \[High Risk\] [\#3138](https://github.com/fecgov/openFEC/issues/3138)
- Check logs 5/16/18 [\#3081](https://github.com/fecgov/openFEC/issues/3081)
- Check logs 5/9/18 [\#3080](https://github.com/fecgov/openFEC/issues/3080)
- Check logs 5/2/18 [\#3079](https://github.com/fecgov/openFEC/issues/3079)
- Switching API to the fecp-driven sched\_b tables [\#3045](https://github.com/fecgov/openFEC/issues/3045)

**Merged pull requests:**

- \[MERGE WITH GIT FLOW\] Release/public 20180515 [\#3108](https://github.com/fecgov/openFEC/pull/3108) ([patphongs](https://github.com/patphongs))
- Revert ES56 Services  [\#3106](https://github.com/fecgov/openFEC/pull/3106) ([pkfec](https://github.com/pkfec))
- Add redis to manifest task files [\#3102](https://github.com/fecgov/openFEC/pull/3102) ([lbeaufort](https://github.com/lbeaufort))
- Remove Gemnasium badge - now using Snyk [\#3097](https://github.com/fecgov/openFEC/pull/3097) ([lbeaufort](https://github.com/lbeaufort))
- Change the trc\_election\_id and trc\_election\_result\_id columns to bigint [\#3095](https://github.com/fecgov/openFEC/pull/3095) ([lbeaufort](https://github.com/lbeaufort))
- Add specific exception message, refactor `is\_url\_path\_cacheable` function [\#3093](https://github.com/fecgov/openFEC/pull/3093) ([lbeaufort](https://github.com/lbeaufort))
- Add error handling for when `load\_current\_murs` is passed an invalid or archived MUR number [\#3092](https://github.com/fecgov/openFEC/pull/3092) ([lbeaufort](https://github.com/lbeaufort))
- Add trc\_election\_result table [\#3091](https://github.com/fecgov/openFEC/pull/3091) ([lbeaufort](https://github.com/lbeaufort))
- Feature/switch schedule b [\#3086](https://github.com/fecgov/openFEC/pull/3086) ([fecjjeng](https://github.com/fecjjeng))
- Feature/upgrade elasticsearch [\#3084](https://github.com/fecgov/openFEC/pull/3084) ([fec-jli](https://github.com/fec-jli))

## [public-20180502](https://github.com/fecgov/openFEC/tree/public-20180502) (2018-05-02)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20180418...public-20180502)

**Fixed bugs:**

- Analyze slow raw/efiling queries [\#2916](https://github.com/fecgov/openFEC/issues/2916)

**Closed issues:**

- Check customizations of HBS and JS \(Swagger\) [\#3065](https://github.com/fecgov/openFEC/issues/3065)
- Implement vanilla version of Swagger 3.0 in API [\#3064](https://github.com/fecgov/openFEC/issues/3064)
- Reload legal docs on `stage` and `prod` after their respective deployments \(4/11 and 4/18\) [\#3052](https://github.com/fecgov/openFEC/issues/3052)
- Check logs 04/25/18 [\#3031](https://github.com/fecgov/openFEC/issues/3031)
- Check logs 04/18/18 [\#3030](https://github.com/fecgov/openFEC/issues/3030)
- Refactor /candidates/totals/ endpoint to use new materialized view and one model [\#3023](https://github.com/fecgov/openFEC/issues/3023)
- Refresh MUR and AO tables in DEV and STAGE from the tables in PROD. [\#3022](https://github.com/fecgov/openFEC/issues/3022)
- Create itemized tables \(sched\_a\) and transfer data from fecp to postgresql database in cloud [\#3006](https://github.com/fecgov/openFEC/issues/3006)
- \[ATO\] Research and implement new vulnerability tracking tool  [\#2996](https://github.com/fecgov/openFEC/issues/2996)
- Have meeting to make metrics plan [\#2942](https://github.com/fecgov/openFEC/issues/2942)

**Merged pull requests:**

- \[MERGE WITH GIT FLOW\] Release/public 20180502 [\#3085](https://github.com/fecgov/openFEC/pull/3085) ([lbeaufort](https://github.com/lbeaufort))
- Add Snyk vulnerability tracker badge [\#3075](https://github.com/fecgov/openFEC/pull/3075) ([lbeaufort](https://github.com/lbeaufort))
- Rename V0075\_\_add\_efile\_raw\_tabale\_indexes.sql -\> V0075\_\_add\_efile\_ra… [\#3073](https://github.com/fecgov/openFEC/pull/3073) ([rjayasekera](https://github.com/rjayasekera))
- Commented out aggregate sample data related to \#2917 [\#3072](https://github.com/fecgov/openFEC/pull/3072) ([apburnes](https://github.com/apburnes))
- \[Migration 76\] Refactor /candidates/totals to show candidates with $0 activity [\#3071](https://github.com/fecgov/openFEC/pull/3071) ([lbeaufort](https://github.com/lbeaufort))
- \[Migration 77 - wait for migration 76\] Add three committee type 'U','V','W' into MVs. [\#3070](https://github.com/fecgov/openFEC/pull/3070) ([fec-jli](https://github.com/fec-jli))
- alter\_table\_fec\_fitem\_sched\_a to rename a column and update a trigger… [\#3069](https://github.com/fecgov/openFEC/pull/3069) ([fecjjeng](https://github.com/fecjjeng))
- Efile raw data query performance improvement [\#3067](https://github.com/fecgov/openFEC/pull/3067) ([rjayasekera](https://github.com/rjayasekera))
- Fix missing space before \[APIinfo@fec.gov\] [\#3063](https://github.com/fecgov/openFEC/pull/3063) ([lbeaufort](https://github.com/lbeaufort))
- Change typeahead search on home page to sort by total activity [\#3058](https://github.com/fecgov/openFEC/pull/3058) ([lbeaufort](https://github.com/lbeaufort))

## [public-20180418](https://github.com/fecgov/openFEC/tree/public-20180418) (2018-04-18)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20180404...public-20180418)

**Fixed bugs:**

- Optimize IE queries [\#3046](https://github.com/fecgov/openFEC/issues/3046)
- Fix statute mapping where 2 USC contains a letter [\#2803](https://github.com/fecgov/openFEC/issues/2803)

**Closed issues:**

- Change Candidate search results to show candidates with no activity [\#3059](https://github.com/fecgov/openFEC/issues/3059)
- Independent expenditure search: difficulty finding Form 5 filers [\#3057](https://github.com/fecgov/openFEC/issues/3057)
- Make an elasticsearch backup [\#3053](https://github.com/fecgov/openFEC/issues/3053)
- Research on update past migration files for MVs to change from "WITH NO DATA" to "WITH DATA" [\#3047](https://github.com/fecgov/openFEC/issues/3047)
- Clicking aggregates on IE table should take users to filtered results, not all IEs [\#3043](https://github.com/fecgov/openFEC/issues/3043)
- Check logs 04/11/18 [\#3029](https://github.com/fecgov/openFEC/issues/3029)
- Check logs 04/04/18 [\#3028](https://github.com/fecgov/openFEC/issues/3028)
- Salient AO/MUR transfer to dev and stage [\#2989](https://github.com/fecgov/openFEC/issues/2989)
- Periodically check the Redis connection [\#2974](https://github.com/fecgov/openFEC/issues/2974)
- Update Docker Buildpack for Circle Builds [\#2972](https://github.com/fecgov/openFEC/issues/2972)
- Figure out if any other API changes or new endpoints are needed for the Election "About" section [\#2948](https://github.com/fecgov/openFEC/issues/2948)
- Research issue: Come up with a way of proactively assuring data quality of high profile committees after filing deadlines [\#2939](https://github.com/fecgov/openFEC/issues/2939)
- Investigate incorrect permissions for certain tables in postgres [\#2927](https://github.com/fecgov/openFEC/issues/2927)
- Update "create\_sample\_db" task to run "refresh\_materialized" task [\#2872](https://github.com/fecgov/openFEC/issues/2872)
- FTP File oth16.zip Fails to Download [\#2862](https://github.com/fecgov/openFEC/issues/2862)
- Create itemized tables \(sched\_b\) and transfer data from fecp to postgresql database in cloud [\#2854](https://github.com/fecgov/openFEC/issues/2854)
- Upgrade Swagger UI to most recent stable version [\#2851](https://github.com/fecgov/openFEC/issues/2851)

**Merged pull requests:**

- \[MERGE WITH GITFLOW\] Release/public 20180418 [\#3061](https://github.com/fecgov/openFEC/pull/3061) ([pkfec](https://github.com/pkfec))
- Update celery redis configuration and added log message to cached-calls [\#3060](https://github.com/fecgov/openFEC/pull/3060) ([rjayasekera](https://github.com/rjayasekera))
- update ofec\_sched\_e refresh script to specify data type for column sc… [\#3048](https://github.com/fecgov/openFEC/pull/3048) ([fecjjeng](https://github.com/fecjjeng))
- Fix AO statute mapping where section contains a letter [\#3044](https://github.com/fecgov/openFEC/pull/3044) ([lbeaufort](https://github.com/lbeaufort))
- Fix contribution\_refunds total [\#3042](https://github.com/fecgov/openFEC/pull/3042) ([lbeaufort](https://github.com/lbeaufort))
- update fec\_fitem\_sched\_b table to rename one column and update trigge… [\#3040](https://github.com/fecgov/openFEC/pull/3040) ([fecjjeng](https://github.com/fecjjeng))

## [public-20180404](https://github.com/fecgov/openFEC/tree/public-20180404) (2018-04-04)

[Full Changelog](https://github.com/fecgov/openFEC/compare/update-fec-readme...public-20180404)

**Fixed bugs:**

- Incorrect total refunds on `/candidate/{candidate\_id}/totals` endpoint [\#3041](https://github.com/fecgov/openFEC/issues/3041)
- Fix zipcode search - limit match to left\(5\) of parameter value. [\#2980](https://github.com/fecgov/openFEC/issues/2980)
- Investigate why 422 \(missing parameters\) errors are coming through as 500 \(Internal Server\) errors [\#2962](https://github.com/fecgov/openFEC/issues/2962)
- Fix retrieval of application space name in cloud.gov for Redis retries [\#2976](https://github.com/fecgov/openFEC/pull/2976) ([ccostino](https://github.com/ccostino))
- Attempt to fix Redis connection retries [\#2975](https://github.com/fecgov/openFEC/pull/2975) ([ccostino](https://github.com/ccostino))

**Closed issues:**

- drop mv public.ofec\_candidate\_flag [\#3017](https://github.com/fecgov/openFEC/issues/3017)
- \[fec-cms\]  set default sub\_category\_id=all for audit-case endpoint [\#3016](https://github.com/fecgov/openFEC/issues/3016)
- auto delete s3 cached requests after 3 days [\#3009](https://github.com/fecgov/openFEC/issues/3009)
- Once cache calls are in prod adjust manifest [\#3008](https://github.com/fecgov/openFEC/issues/3008)
- Update python version [\#2998](https://github.com/fecgov/openFEC/issues/2998)
- Archived MURs being found modified, causing all MURs to get reloaded [\#2993](https://github.com/fecgov/openFEC/issues/2993)
- remove extra coalesce function in schedule B query [\#2988](https://github.com/fecgov/openFEC/issues/2988)
- Optimize IE queries \(\#1614\) [\#2987](https://github.com/fecgov/openFEC/issues/2987)
- Switch to FECP driven itemized tables [\#2986](https://github.com/fecgov/openFEC/issues/2986)
- Add cycle parameter to schedules/schedule\_f` endpoint [\#2981](https://github.com/fecgov/openFEC/issues/2981)
- Enable House/Senate Downloads [\#2978](https://github.com/fecgov/openFEC/issues/2978)
- Check logs 03/28/18 [\#2968](https://github.com/fecgov/openFEC/issues/2968)
- Check logs 03/21/18 [\#2967](https://github.com/fecgov/openFEC/issues/2967)
- Check logs 03/14/18 [\#2966](https://github.com/fecgov/openFEC/issues/2966)
- Research on approach to execute migrations separately from regular build [\#2958](https://github.com/fecgov/openFEC/issues/2958)
- Transfer openFEC GitHub repo to FEC [\#2950](https://github.com/fecgov/openFEC/issues/2950)
- Mid-PI check-in [\#2944](https://github.com/fecgov/openFEC/issues/2944)
- FEC takes over ATO [\#2943](https://github.com/fecgov/openFEC/issues/2943)
- Create API endpoint for state election information [\#2938](https://github.com/fecgov/openFEC/issues/2938)
- Investigate and fix 500 errors for unexpected parameters passed to /legal/search/ endpoint [\#2934](https://github.com/fecgov/openFEC/issues/2934)
- Improve performance for cache calls \(\#2749\) & turn it on  [\#2913](https://github.com/fecgov/openFEC/issues/2913)
- Update cloud.gov manifest setup in API [\#2884](https://github.com/fecgov/openFEC/issues/2884)
- Migration timeout fix [\#2879](https://github.com/fecgov/openFEC/issues/2879)
- contains matches for zip code fields [\#2720](https://github.com/fecgov/openFEC/issues/2720)
- Enable downloads from candidate pages [\#2710](https://github.com/fecgov/openFEC/issues/2710)
- Improve performance when automatically loading MURs [\#2646](https://github.com/fecgov/openFEC/issues/2646)

**Merged pull requests:**

- \[MERGE WITH GITFLOW\] Release/public 20180404 [\#3039](https://github.com/fecgov/openFEC/pull/3039) ([rjayasekera](https://github.com/rjayasekera))
- Upgrade Python to 3.6 [\#3037](https://github.com/fecgov/openFEC/pull/3037) ([rjayasekera](https://github.com/rjayasekera))
- Feature/removeofec candidate flag [\#3036](https://github.com/fecgov/openFEC/pull/3036) ([fecjjeng](https://github.com/fecjjeng))
- Feature/refactor cache calls [\#3035](https://github.com/fecgov/openFEC/pull/3035) ([pkfec](https://github.com/pkfec))
- Use envvars instead of explicit connection params [\#3034](https://github.com/fecgov/openFEC/pull/3034) ([vrajmohan](https://github.com/vrajmohan))
- fix ofec\_sched\_e reoccurring permission problem [\#3032](https://github.com/fecgov/openFEC/pull/3032) ([fecjjeng](https://github.com/fecjjeng))
- Added test\_case for 5 endpoints in audit. [\#3027](https://github.com/fecgov/openFEC/pull/3027) ([fec-jli](https://github.com/fec-jli))
- Help debug and improve the cached calls for the API [\#3026](https://github.com/fecgov/openFEC/pull/3026) ([ccostino](https://github.com/ccostino))
- Feature/remove cache folder from s3 [\#3025](https://github.com/fecgov/openFEC/pull/3025) ([pkfec](https://github.com/pkfec))
- Feature/remove cache folder from s3 [\#3024](https://github.com/fecgov/openFEC/pull/3024) ([pkfec](https://github.com/pkfec))
- Enable candidate downloads [\#3021](https://github.com/fecgov/openFEC/pull/3021) ([lbeaufort](https://github.com/lbeaufort))
- Removed the cache calls env variable from DEV yml files [\#3020](https://github.com/fecgov/openFEC/pull/3020) ([pkfec](https://github.com/pkfec))
- exception handling for legal search endpoint, debug single test\_legal.py [\#3019](https://github.com/fecgov/openFEC/pull/3019) ([fec-jli](https://github.com/fec-jli))
- Prevent flask-restful from taking over all errors [\#3018](https://github.com/fecgov/openFEC/pull/3018) ([vrajmohan](https://github.com/vrajmohan))
- Update manifests - inheritance and host are depreciated [\#3015](https://github.com/fecgov/openFEC/pull/3015) ([lbeaufort](https://github.com/lbeaufort))
- Fixed the broken api link. [\#3013](https://github.com/fecgov/openFEC/pull/3013) ([pkfec](https://github.com/pkfec))
- Feature/add filter multi start with [\#3012](https://github.com/fecgov/openFEC/pull/3012) ([hcaofec](https://github.com/hcaofec))
- Endpoint for state election offices [\#3011](https://github.com/fecgov/openFEC/pull/3011) ([pkfec](https://github.com/pkfec))
- Modify MUR reload to only load specific MURs, check every 5 minutes [\#3010](https://github.com/fecgov/openFEC/pull/3010) ([lbeaufort](https://github.com/lbeaufort))
- fix mailto link [\#3004](https://github.com/fecgov/openFEC/pull/3004) ([LindsayYoung](https://github.com/LindsayYoung))
- Fix Legal search endpoint 500 error for unexpected parameters [\#3002](https://github.com/fecgov/openFEC/pull/3002) ([fec-jli](https://github.com/fec-jli))
- add missing permission [\#3001](https://github.com/fecgov/openFEC/pull/3001) ([fecjjeng](https://github.com/fecjjeng))
- Update hotfix instructions - deploy to dev first [\#3000](https://github.com/fecgov/openFEC/pull/3000) ([lbeaufort](https://github.com/lbeaufort))
- Create pull request template [\#2992](https://github.com/fecgov/openFEC/pull/2992) ([lbeaufort](https://github.com/lbeaufort))
- Feature/remove extra coalesce [\#2990](https://github.com/fecgov/openFEC/pull/2990) ([hcaofec](https://github.com/hcaofec))
- Add cycle filter and corresponding index to Schedule F endpoint [\#2982](https://github.com/fecgov/openFEC/pull/2982) ([lbeaufort](https://github.com/lbeaufort))
- changed transation to transaction in docs.py [\#2979](https://github.com/fecgov/openFEC/pull/2979) ([johnnyporkchops](https://github.com/johnnyporkchops))
- Retry Redis connection on startup [\#2973](https://github.com/fecgov/openFEC/pull/2973) ([rjayasekera](https://github.com/rjayasekera))
- Handle nulls in "exclude" filters, add request\_type to filings [\#2970](https://github.com/fecgov/openFEC/pull/2970) ([lbeaufort](https://github.com/lbeaufort))
- feature/retrieve-cache-calls [\#2846](https://github.com/fecgov/openFEC/pull/2846) ([pkfec](https://github.com/pkfec))

## [update-fec-readme](https://github.com/fecgov/openFEC/tree/update-fec-readme) (2018-03-09)

[Full Changelog](https://github.com/fecgov/openFEC/compare/fix-mur-refresh...update-fec-readme)

**Merged pull requests:**

- 🎉 Updating ownership from 18F to FEC  🎉 [\#2999](https://github.com/fecgov/openFEC/pull/2999) ([LindsayYoung](https://github.com/LindsayYoung))

## [fix-mur-refresh](https://github.com/fecgov/openFEC/tree/fix-mur-refresh) (2018-03-07)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20180307...fix-mur-refresh)

**Fixed bugs:**

- Server Error retrieving MUR-6875 [\#2977](https://github.com/fecgov/openFEC/issues/2977)
- \[MERGE WITH GIT FLOW\] Hotfix: Change celery task to check for just modified MURs [\#2994](https://github.com/fecgov/openFEC/pull/2994) ([lbeaufort](https://github.com/lbeaufort))

**Closed issues:**

- Check Logs 03/07/18 [\#2965](https://github.com/fecgov/openFEC/issues/2965)

## [public-20180307](https://github.com/fecgov/openFEC/tree/public-20180307) (2018-03-07)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20180220...public-20180307)

**Fixed bugs:**

- Change exclude logic to return null values [\#2969](https://github.com/fecgov/openFEC/issues/2969)
- Missing Filings -add column to view [\#2723](https://github.com/fecgov/openFEC/issues/2723)

**Closed issues:**

- Enable House/Senate downloads --- Refactor resource to use API base model [\#2985](https://github.com/fecgov/openFEC/issues/2985)
- Build additional end point for state election offices [\#2984](https://github.com/fecgov/openFEC/issues/2984)
- Change N/A to No authorized candidate in Audit Search  [\#2961](https://github.com/fecgov/openFEC/issues/2961)
- Refactor the /reports/ endpoint to use "exclude" in filters.py [\#2953](https://github.com/fecgov/openFEC/issues/2953)
- Research and adjust IOPS for RDS [\#2952](https://github.com/fecgov/openFEC/issues/2952)
- Transfer fec-eregs GitHub repo [\#2951](https://github.com/fecgov/openFEC/issues/2951)
- create/modify endpoint to produce state contact info for election work \(Joh know\) [\#2949](https://github.com/fecgov/openFEC/issues/2949)
- \*state election office \(in database table\) [\#2947](https://github.com/fecgov/openFEC/issues/2947)
- About election \*incumbent caniddate \*candidate pcc \*other authorized [\#2946](https://github.com/fecgov/openFEC/issues/2946)
- How to get election summary data for election summary updates and redesign ? [\#2945](https://github.com/fecgov/openFEC/issues/2945)
- CMS update moment version [\#2941](https://github.com/fecgov/openFEC/issues/2941)
- Add retries for Redis when connection is lost. [\#2940](https://github.com/fecgov/openFEC/issues/2940)
- Add remaining COALESCE indexes to Schedule B tables [\#2923](https://github.com/fecgov/openFEC/issues/2923)
- Circle CI nightly redeploy - change ATO [\#2914](https://github.com/fecgov/openFEC/issues/2914)
- Check logs 2/28/18 [\#2911](https://github.com/fecgov/openFEC/issues/2911)
- Check logs  2/21/18 [\#2910](https://github.com/fecgov/openFEC/issues/2910)
- Add exclusion argument \("exclude"\) capability to API [\#2897](https://github.com/fecgov/openFEC/issues/2897)
- Move archived MURs to their own index on staging and production environments [\#2860](https://github.com/fecgov/openFEC/issues/2860)
- Setup CircleCI with cron jobs for Auto Deploys [\#2855](https://github.com/fecgov/openFEC/issues/2855)
- add retries for redis [\#2773](https://github.com/fecgov/openFEC/issues/2773)

**Merged pull requests:**

- Originally we have renamed it to have \_mv at the end. But for back word [\#2991](https://github.com/fecgov/openFEC/pull/2991) ([rjayasekera](https://github.com/rjayasekera))
- \[MERGE WITH GITFLOW\] Release/public 20180307 [\#2971](https://github.com/fecgov/openFEC/pull/2971) ([fecjjeng](https://github.com/fecjjeng))
- Use gradle to build flyway distZip app [\#2964](https://github.com/fecgov/openFEC/pull/2964) ([vrajmohan](https://github.com/vrajmohan))
- Change N/A cand name to No authorized candidate. [\#2960](https://github.com/fecgov/openFEC/pull/2960) ([fec-jli](https://github.com/fec-jli))
- Modified audit MVs and Views change primary\_id and sub\_id default=all [\#2959](https://github.com/fecgov/openFEC/pull/2959) ([fec-jli](https://github.com/fec-jli))
- Remove unused ApiResource function, refactor /reports/ "exclude" report\_type  [\#2956](https://github.com/fecgov/openFEC/pull/2956) ([lbeaufort](https://github.com/lbeaufort))
- Remove check for old creds [\#2955](https://github.com/fecgov/openFEC/pull/2955) ([LindsayYoung](https://github.com/LindsayYoung))
- Add "exclude" capabilities to filters.py  [\#2937](https://github.com/fecgov/openFEC/pull/2937) ([lbeaufort](https://github.com/lbeaufort))
- Add multi-column sort to /elections/search/ endpoint, fix default sort order [\#2936](https://github.com/fecgov/openFEC/pull/2936) ([lbeaufort](https://github.com/lbeaufort))
- Fixed show sub\_category results when select only primary\_category\_id. [\#2935](https://github.com/fecgov/openFEC/pull/2935) ([fec-jli](https://github.com/fec-jli))
- Add remaining Schedule B COALESCE-based indexes [\#2932](https://github.com/fecgov/openFEC/pull/2932) ([ccostino](https://github.com/ccostino))
- Rename ofec\_candidate\_flag mv [\#2931](https://github.com/fecgov/openFEC/pull/2931) ([rjayasekera](https://github.com/rjayasekera))

## [public-20180220](https://github.com/fecgov/openFEC/tree/public-20180220) (2018-02-20)

[Full Changelog](https://github.com/fecgov/openFEC/compare/efile-cmteid-filter...public-20180220)

**Fixed bugs:**

- Time period incorrect for House special election candidates  [\#2845](https://github.com/fecgov/openFEC/issues/2845)

**Closed issues:**

- Mandatory Audit of Accounts: CMS [\#2930](https://github.com/fecgov/openFEC/issues/2930)
- Mandatory Audit of Accounts: AWS; Cloud.gov; RDS [\#2929](https://github.com/fecgov/openFEC/issues/2929)
- Mandatory Audit of Accounts: GitHub and API [\#2928](https://github.com/fecgov/openFEC/issues/2928)
- Test Schedule B/expression-based sort changes on `stage` [\#2922](https://github.com/fecgov/openFEC/issues/2922)
- Refine AuditCase endpoint to allow users to get results by selecting only a primary category. [\#2920](https://github.com/fecgov/openFEC/issues/2920)
- Transfer state election office information to postgres [\#2919](https://github.com/fecgov/openFEC/issues/2919)
- Rename public.ofec\_candidate\_flag [\#2912](https://github.com/fecgov/openFEC/issues/2912)
- Check logs 2/14/18 [\#2909](https://github.com/fecgov/openFEC/issues/2909)
- Check logs 2/8/18 [\#2908](https://github.com/fecgov/openFEC/issues/2908)
- Fix the committe\_id filter for /efile/reports/ endpoint [\#2902](https://github.com/fecgov/openFEC/issues/2902)
- Alphabetize by state name instead of state abbreviation [\#2888](https://github.com/fecgov/openFEC/issues/2888)
- Add AS, GU, MP, PR and VI to state drop down list [\#2887](https://github.com/fecgov/openFEC/issues/2887)
- Create new table - staging.ref\_zip\_to\_district [\#2876](https://github.com/fecgov/openFEC/issues/2876)
- Drop old aggregate tables  [\#2873](https://github.com/fecgov/openFEC/issues/2873)
- Per ATO, do a mandatory January accounts audit [\#2815](https://github.com/fecgov/openFEC/issues/2815)
- Optimize Schedule B query [\#2791](https://github.com/fecgov/openFEC/issues/2791)
- Cache calls in S3 and return the last result if there is a 500- API  [\#2749](https://github.com/fecgov/openFEC/issues/2749)
- Add "topics" to GitHub repos [\#2707](https://github.com/fecgov/openFEC/issues/2707)
- Update trc\_election tables with elections before 2004 [\#2694](https://github.com/fecgov/openFEC/issues/2694)
- Identify all spots that display special elections -- make module to handle these [\#2691](https://github.com/fecgov/openFEC/issues/2691)
- Refactor to get rid of ofec\_candidate\_totals\_mv\_tmp [\#2644](https://github.com/fecgov/openFEC/issues/2644)
- Handling nulls in columns that are aggregated by [\#2639](https://github.com/fecgov/openFEC/issues/2639)
- Introduce transaction boundaries within SQL scripts [\#2619](https://github.com/fecgov/openFEC/issues/2619)
- Figure out any other itemized schedules to switch Data/API [\#2615](https://github.com/fecgov/openFEC/issues/2615)
- 18F + FEC Pair on Cloudwatch [\#2607](https://github.com/fecgov/openFEC/issues/2607)
- Design solution for financial summaries of committees who file multiple form types [\#2596](https://github.com/fecgov/openFEC/issues/2596)
- Create endpoint for unverified candidates and committees [\#2595](https://github.com/fecgov/openFEC/issues/2595)
- Enable downloads for unverified candidates and committees [\#2593](https://github.com/fecgov/openFEC/issues/2593)
- Figure out how to switch schedules A and B to use FEC managed tables Data / API [\#2592](https://github.com/fecgov/openFEC/issues/2592)
- Figure out why the latest version of factory\_boy won't work [\#2573](https://github.com/fecgov/openFEC/issues/2573)
- Committee type vs Form type issue causes committee profiles to have incorrect or missing data [\#2547](https://github.com/fecgov/openFEC/issues/2547)
- Create endpoint for showing total receipts by size [\#2536](https://github.com/fecgov/openFEC/issues/2536)
- Show total IEs and party expenditures per state and district [\#2535](https://github.com/fecgov/openFEC/issues/2535)
- Make election summary API endpoint [\#2534](https://github.com/fecgov/openFEC/issues/2534)
- Research QuantifiedCode alternatives [\#2517](https://github.com/fecgov/openFEC/issues/2517)
- 24- and 48-hour Independent Expenditure data filing amendment indicator [\#2491](https://github.com/fecgov/openFEC/issues/2491)
- Provide coverage dates for C and E type committees [\#2486](https://github.com/fecgov/openFEC/issues/2486)
- Form 3L download [\#2484](https://github.com/fecgov/openFEC/issues/2484)
- Create schedule E filters for state, district and office [\#2479](https://github.com/fecgov/openFEC/issues/2479)
- Add correct state\_full label for aggregates from non-state states [\#2465](https://github.com/fecgov/openFEC/issues/2465)
- Service now integration improvements  [\#2452](https://github.com/fecgov/openFEC/issues/2452)
- Financial summary for committee with multiple committee types during two-year period [\#2419](https://github.com/fecgov/openFEC/issues/2419)
- Why are Sentate records ints and House records floats ? [\#2409](https://github.com/fecgov/openFEC/issues/2409)
- Look for performance issues with Python profiler [\#2395](https://github.com/fecgov/openFEC/issues/2395)
- set cache per endpoint [\#2389](https://github.com/fecgov/openFEC/issues/2389)
- Add custom logging to find long queries [\#2376](https://github.com/fecgov/openFEC/issues/2376)
- Remove extraneous and incorrect unverified candidates test [\#2358](https://github.com/fecgov/openFEC/issues/2358)
- Add Form 13 to /totals/ [\#2357](https://github.com/fecgov/openFEC/issues/2357)
- Improve F2 results on /filings/ [\#2344](https://github.com/fecgov/openFEC/issues/2344)
- Treat AO numbers as a single word when searching [\#2343](https://github.com/fecgov/openFEC/issues/2343)
- refactor validator  [\#2334](https://github.com/fecgov/openFEC/issues/2334)
- Add "report\_receipt\_date" to schedule D results [\#2317](https://github.com/fecgov/openFEC/issues/2317)
- Register indexes on the efiling filing  [\#2302](https://github.com/fecgov/openFEC/issues/2302)
- Add gemnaysium badges to supporting libraries [\#2280](https://github.com/fecgov/openFEC/issues/2280)
- Set up New Relic pings for new Dev and Stage [\#2279](https://github.com/fecgov/openFEC/issues/2279)
- Integrate API key signup on the site instead of linking off [\#2231](https://github.com/fecgov/openFEC/issues/2231)
- Create summary endpoint for location of individual contributions [\#1973](https://github.com/fecgov/openFEC/issues/1973)

**Merged pull requests:**

- add table fecapp.trc\_st\_elect\_offic [\#2926](https://github.com/fecgov/openFEC/pull/2926) ([fecjjeng](https://github.com/fecjjeng))
- \[MERGE WITH GITFLOW\] Release/public 20180220 [\#2924](https://github.com/fecgov/openFEC/pull/2924) ([fec-jli](https://github.com/fec-jli))
- removed old doc [\#2918](https://github.com/fecgov/openFEC/pull/2918) ([LindsayYoung](https://github.com/LindsayYoung))
- disable the call to old aggregate function [\#2917](https://github.com/fecgov/openFEC/pull/2917) ([hcaofec](https://github.com/hcaofec))
- Feature/audit mv refactor and fix bug for multi columns sorting [\#2915](https://github.com/fecgov/openFEC/pull/2915) ([fec-jli](https://github.com/fec-jli))
- add new MV ofec\_filings\_all\_mv to nightly refresh schedule [\#2907](https://github.com/fecgov/openFEC/pull/2907) ([fecjjeng](https://github.com/fecjjeng))
- Add support for expression-based sorts in API [\#2905](https://github.com/fecgov/openFEC/pull/2905) ([ccostino](https://github.com/ccostino))
- add\_expression\_based\_index\_for\_sched\_b\_tables [\#2904](https://github.com/fecgov/openFEC/pull/2904) ([fecjjeng](https://github.com/fecjjeng))
- Fix elasticsearch reindex timeouts, revert global connection setting [\#2899](https://github.com/fecgov/openFEC/pull/2899) ([lbeaufort](https://github.com/lbeaufort))
- Add coverage end date to /elections/endpoint [\#2898](https://github.com/fecgov/openFEC/pull/2898) ([lbeaufort](https://github.com/lbeaufort))
- Change "/elections/list" endpoint zip search to use new table [\#2892](https://github.com/fecgov/openFEC/pull/2892) ([lbeaufort](https://github.com/lbeaufort))
- feature/missing-filings-from-view [\#2885](https://github.com/fecgov/openFEC/pull/2885) ([pkfec](https://github.com/pkfec))

## [efile-cmteid-filter](https://github.com/fecgov/openFEC/tree/efile-cmteid-filter) (2018-02-05)

[Full Changelog](https://github.com/fecgov/openFEC/compare/deploy-updates...efile-cmteid-filter)

**Closed issues:**

- Investigate slack notifications for failed nightly updates [\#2894](https://github.com/fecgov/openFEC/issues/2894)
- return coverage end date to  /elections/ endpoint [\#2891](https://github.com/fecgov/openFEC/issues/2891)
- Refactor district-to-zip lookup to use new table [\#2875](https://github.com/fecgov/openFEC/issues/2875)
- RDS Dev instance needs a little TLC [\#2863](https://github.com/fecgov/openFEC/issues/2863)
- Check logs 1/31/18 [\#2843](https://github.com/fecgov/openFEC/issues/2843)
- Fix invoke deploy command for manual deploys [\#2834](https://github.com/fecgov/openFEC/issues/2834)
- Decode committee type consistently  [\#2827](https://github.com/fecgov/openFEC/issues/2827)
- API keys claim to give you 120 calls per minute but they don't [\#2819](https://github.com/fecgov/openFEC/issues/2819)
- Update swagger dependiencies [\#2356](https://github.com/fecgov/openFEC/issues/2356)
- Make fec.gov urls for downloads with proxy [\#2284](https://github.com/fecgov/openFEC/issues/2284)
- Remove "space name" from the names of services [\#2247](https://github.com/fecgov/openFEC/issues/2247)

**Merged pull requests:**

- \[MERGE WITH GIT FLOW\] \(Hotfix\) Fix the committe\_id filter for /efile/reports/ endpoint [\#2906](https://github.com/fecgov/openFEC/pull/2906) ([lbeaufort](https://github.com/lbeaufort))

## [deploy-updates](https://github.com/fecgov/openFEC/tree/deploy-updates) (2018-01-30)

[Full Changelog](https://github.com/fecgov/openFEC/compare/nightly-updates...deploy-updates)

**Merged pull requests:**

- Fixing nigtly slack notificaiton for updates [\#2896](https://github.com/fecgov/openFEC/pull/2896) ([LindsayYoung](https://github.com/LindsayYoung))

## [nightly-updates](https://github.com/fecgov/openFEC/tree/nightly-updates) (2018-01-30)

[Full Changelog](https://github.com/fecgov/openFEC/compare/elections-list-unique-idx...nightly-updates)

**Merged pull requests:**

- \[WIP\] feature/fix-candidates-showing-outside-cycle [\#2881](https://github.com/fecgov/openFEC/pull/2881) ([hcaofec](https://github.com/hcaofec))

## [elections-list-unique-idx](https://github.com/fecgov/openFEC/tree/elections-list-unique-idx) (2018-01-30)

[Full Changelog](https://github.com/fecgov/openFEC/compare/fix-repeating-districts...elections-list-unique-idx)

**Fixed bugs:**

- Districts missing from election pages [\#2844](https://github.com/fecgov/openFEC/issues/2844)

**Closed issues:**

- Improve message for off-election cycles in Puerto Rico [\#2890](https://github.com/fecgov/openFEC/issues/2890)
- Add records to FIPS-ZIP-congressional district file [\#2869](https://github.com/fecgov/openFEC/issues/2869)
- Update FIPS-ZIP-congressional district file [\#2867](https://github.com/fecgov/openFEC/issues/2867)
- Update FIPS codes [\#2866](https://github.com/fecgov/openFEC/issues/2866)

**Merged pull requests:**

- \[MERGE WITH GIT FLOW\] Hotfix/elections list unique idx [\#2893](https://github.com/fecgov/openFEC/pull/2893) ([lbeaufort](https://github.com/lbeaufort))

## [fix-repeating-districts](https://github.com/fecgov/openFEC/tree/fix-repeating-districts) (2018-01-25)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20180125...fix-repeating-districts)

**Merged pull requests:**

- \[MERGE WITH GIT FLOW\] Modify ofec\_elections\_list\_mv to handle multiple incumbents [\#2886](https://github.com/fecgov/openFEC/pull/2886) ([lbeaufort](https://github.com/lbeaufort))

## [public-20180125](https://github.com/fecgov/openFEC/tree/public-20180125) (2018-01-25)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20180117...public-20180125)

**Fixed bugs:**

- candidates showing up outside their cycle [\#2628](https://github.com/fecgov/openFEC/issues/2628)

**Closed issues:**

- Reload all AOs, MURs on 1/17/18 [\#2847](https://github.com/fecgov/openFEC/issues/2847)
- Check logs 1/24/18 [\#2842](https://github.com/fecgov/openFEC/issues/2842)
- Check logs 1/17/18 [\#2841](https://github.com/fecgov/openFEC/issues/2841)
- Once we've confirmed that AO, MUR reload slowness has been addressed, change logger back to DEBUG [\#2831](https://github.com/fecgov/openFEC/issues/2831)
- Implement backup and restore of just archived MURs [\#2810](https://github.com/fecgov/openFEC/issues/2810)
- Switching API to the new aggregate tables [\#2784](https://github.com/fecgov/openFEC/issues/2784)
- Switch off Mandril [\#2634](https://github.com/fecgov/openFEC/issues/2634)

**Merged pull requests:**

- \[MERGE WITH GITFLOW\]Release/public 20180125 [\#2880](https://github.com/fecgov/openFEC/pull/2880) ([rjayasekera](https://github.com/rjayasekera))
- add ref\_zip\_to\_district table [\#2877](https://github.com/fecgov/openFEC/pull/2877) ([fecjjeng](https://github.com/fecjjeng))
- Adding records for several states [\#2870](https://github.com/fecgov/openFEC/pull/2870) ([PaulClark2](https://github.com/PaulClark2))
- fix American Samoa, Guam and Puerto Rico listings [\#2868](https://github.com/fecgov/openFEC/pull/2868) ([PaulClark2](https://github.com/PaulClark2))
- update fips codes [\#2865](https://github.com/fecgov/openFEC/pull/2865) ([PaulClark2](https://github.com/PaulClark2))
- Add districts missing from elections search [\#2864](https://github.com/fecgov/openFEC/pull/2864) ([lbeaufort](https://github.com/lbeaufort))
- \[WIP\]Feature/switch to new aggregate tables [\#2858](https://github.com/fecgov/openFEC/pull/2858) ([hcaofec](https://github.com/hcaofec))
- Separate archived MURs into their own index for backup [\#2853](https://github.com/fecgov/openFEC/pull/2853) ([lbeaufort](https://github.com/lbeaufort))
- Added a slack function [\#2703](https://github.com/fecgov/openFEC/pull/2703) ([LindsayYoung](https://github.com/LindsayYoung))

## [public-20180117](https://github.com/fecgov/openFEC/tree/public-20180117) (2018-01-17)

[Full Changelog](https://github.com/fecgov/openFEC/compare/turnoff-request-cache...public-20180117)

**Closed issues:**

- Fix dev nightly update [\#2859](https://github.com/fecgov/openFEC/issues/2859)
- Check logs 1/10/18 [\#2840](https://github.com/fecgov/openFEC/issues/2840)
- Check logs 1/3/18 [\#2839](https://github.com/fecgov/openFEC/issues/2839)
- Make "Form Type" and "Report Type" on the /filings/ endpoint a dropdown, add documentation for different values [\#2761](https://github.com/fecgov/openFEC/issues/2761)
- Add automated checks for terminated processes - AWS RDS [\#2752](https://github.com/fecgov/openFEC/issues/2752)

**Merged pull requests:**

- \[MERGE WITH GITFLOW\]Release/public 20180117 [\#2857](https://github.com/fecgov/openFEC/pull/2857) ([pkfec](https://github.com/pkfec))
- Update API docs - add report type and form type [\#2848](https://github.com/fecgov/openFEC/pull/2848) ([lbeaufort](https://github.com/lbeaufort))
- Updated redis-py to latest version [\#2838](https://github.com/fecgov/openFEC/pull/2838) ([ccostino](https://github.com/ccostino))
- AO/MUR document permalinks: Use filename instead of document\_ID [\#2832](https://github.com/fecgov/openFEC/pull/2832) ([lbeaufort](https://github.com/lbeaufort))
- Add load tests for itemized Sch A, B [\#2798](https://github.com/fecgov/openFEC/pull/2798) ([lbeaufort](https://github.com/lbeaufort))

## [turnoff-request-cache](https://github.com/fecgov/openFEC/tree/turnoff-request-cache) (2018-01-03)

[Full Changelog](https://github.com/fecgov/openFEC/compare/deploy-again...turnoff-request-cache)

**Merged pull requests:**

- remove request caching  [\#2852](https://github.com/fecgov/openFEC/pull/2852) ([pkfec](https://github.com/pkfec))

## [deploy-again](https://github.com/fecgov/openFEC/tree/deploy-again) (2018-01-03)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20180103-b...deploy-again)

## [public-20180103-b](https://github.com/fecgov/openFEC/tree/public-20180103-b) (2018-01-03)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20180103...public-20180103-b)

**Merged pull requests:**

- empty commit for RSB2 [\#2850](https://github.com/fecgov/openFEC/pull/2850) ([fec-jli](https://github.com/fec-jli))

## [public-20180103](https://github.com/fecgov/openFEC/tree/public-20180103) (2018-01-03)

[Full Changelog](https://github.com/fecgov/openFEC/compare/fix-refresh-materialized...public-20180103)

**Fixed bugs:**

- Fix management, nightly update, and related commands to always run against master DB [\#2829](https://github.com/fecgov/openFEC/issues/2829)
- Operating expenditure fix [\#2532](https://github.com/fecgov/openFEC/issues/2532)

**Closed issues:**

- Ensure AO and MUR documents get permalinks [\#2817](https://github.com/fecgov/openFEC/issues/2817)
- Investigate delay in MUR/AO refresh documents appearing [\#2816](https://github.com/fecgov/openFEC/issues/2816)
- Check logs 12/27/17 [\#2778](https://github.com/fecgov/openFEC/issues/2778)
- Remove triggers  [\#2726](https://github.com/fecgov/openFEC/issues/2726)

**Merged pull requests:**

- \[MERGE WITH GITFLOW\]Release/public-20180103 [\#2837](https://github.com/fecgov/openFEC/pull/2837) ([hcaofec](https://github.com/hcaofec))
- streaming the data to s3 for cached calls [\#2836](https://github.com/fecgov/openFEC/pull/2836) ([pkfec](https://github.com/pkfec))
- Feature/refactor audit cmte audit vw [\#2833](https://github.com/fecgov/openFEC/pull/2833) ([fec-jli](https://github.com/fec-jli))
- Changed old 18F-fec@gsa.gov email to APIinfo@fec.gov [\#2822](https://github.com/fecgov/openFEC/pull/2822) ([jwchumley](https://github.com/jwchumley))
- Feature/sample db [\#2818](https://github.com/fecgov/openFEC/pull/2818) ([vrajmohan](https://github.com/vrajmohan))
- \[WIP\] feature/cache-all-s3-calls-in-after-request [\#2807](https://github.com/fecgov/openFEC/pull/2807) ([pkfec](https://github.com/pkfec))
- Feature/refactor audit search endpoint [\#2700](https://github.com/fecgov/openFEC/pull/2700) ([ccostino](https://github.com/ccostino))

## [fix-refresh-materialized](https://github.com/fecgov/openFEC/tree/fix-refresh-materialized) (2017-12-22)

[Full Changelog](https://github.com/fecgov/openFEC/compare/remove-api-cache...fix-refresh-materialized)

**Fixed bugs:**

- \[MERGE WITH GIT FLOW\] Fixed refresh materialized management method [\#2830](https://github.com/fecgov/openFEC/pull/2830) ([ccostino](https://github.com/ccostino))

**Closed issues:**

- Add command for installing test database [\#2788](https://github.com/fecgov/openFEC/issues/2788)
- Reminder to check logs per ATO: 12/20/17 [\#2777](https://github.com/fecgov/openFEC/issues/2777)

## [remove-api-cache](https://github.com/fecgov/openFEC/tree/remove-api-cache) (2017-12-21)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20171220...remove-api-cache)

**Fixed bugs:**

- Committees pagination error [\#2690](https://github.com/fecgov/openFEC/issues/2690)

**Merged pull requests:**

- \[Merge with git flow\] Hotfix/remove api cache [\#2828](https://github.com/fecgov/openFEC/pull/2828) ([vrajmohan](https://github.com/vrajmohan))

## [public-20171220](https://github.com/fecgov/openFEC/tree/public-20171220) (2017-12-20)

[Full Changelog](https://github.com/fecgov/openFEC/compare/calendar-hide-unpublished...public-20171220)

**Fixed bugs:**

- Reinstate nightly updates for schedule E data [\#2813](https://github.com/fecgov/openFEC/issues/2813)
- Reinstate nightly refreshes for schedule E data [\#2814](https://github.com/fecgov/openFEC/pull/2814) ([ccostino](https://github.com/ccostino))

**Closed issues:**

- Performing pgBadger analysis - knowledge transfer [\#2809](https://github.com/fecgov/openFEC/issues/2809)
- Migrate WIP items to DB migrations [\#2797](https://github.com/fecgov/openFEC/issues/2797)
- Investigate morning timeouts  [\#2779](https://github.com/fecgov/openFEC/issues/2779)
- Check logs 12/13/17 [\#2776](https://github.com/fecgov/openFEC/issues/2776)
- Postgres tuning: that is AWS RDS  [\#2748](https://github.com/fecgov/openFEC/issues/2748)
- Update API developer help email to FEC distribution list [\#2722](https://github.com/fecgov/openFEC/issues/2722)
- Make next election year for Senate classes \(function\) [\#2692](https://github.com/fecgov/openFEC/issues/2692)
- Automate SQL migrations [\#2681](https://github.com/fecgov/openFEC/issues/2681)

**Merged pull requests:**

- fixing permissions error [\#2824](https://github.com/fecgov/openFEC/pull/2824) ([LindsayYoung](https://github.com/LindsayYoung))
- Add logging to AO, MUR loading process [\#2821](https://github.com/fecgov/openFEC/pull/2821) ([lbeaufort](https://github.com/lbeaufort))
- Update docs [\#2820](https://github.com/fecgov/openFEC/pull/2820) ([LindsayYoung](https://github.com/LindsayYoung))
- \[MERGE WITH GITFLOW\] Release/public 20171220 [\#2812](https://github.com/fecgov/openFEC/pull/2812) ([fec-jli](https://github.com/fec-jli))
- Add docs for flyway repair [\#2806](https://github.com/fecgov/openFEC/pull/2806) ([vrajmohan](https://github.com/vrajmohan))
- Index tables on `comid` column. [\#2805](https://github.com/fecgov/openFEC/pull/2805) ([vrajmohan](https://github.com/vrajmohan))
- Feature/refactor state zip sql [\#2801](https://github.com/fecgov/openFEC/pull/2801) ([vrajmohan](https://github.com/vrajmohan))
- Feature/remove data functions [\#2800](https://github.com/fecgov/openFEC/pull/2800) ([vrajmohan](https://github.com/vrajmohan))
- Add swagger-tools installation back to README.md [\#2799](https://github.com/fecgov/openFEC/pull/2799) ([ccostino](https://github.com/ccostino))
- Add to README - PR approval and getting most recent branches [\#2790](https://github.com/fecgov/openFEC/pull/2790) ([lbeaufort](https://github.com/lbeaufort))
- Build swagger-ui from within openFEC [\#2789](https://github.com/fecgov/openFEC/pull/2789) ([xtine](https://github.com/xtine))
- Update readme API\_URL env var and added warning  [\#2787](https://github.com/fecgov/openFEC/pull/2787) ([cptechiegal](https://github.com/cptechiegal))
- Update build pack - needs load testing [\#2786](https://github.com/fecgov/openFEC/pull/2786) ([lbeaufort](https://github.com/lbeaufort))
- Feature/revert calendar [\#2783](https://github.com/fecgov/openFEC/pull/2783) ([LindsayYoung](https://github.com/LindsayYoung))
- Increase the threshold count to return the exact count for small queries [\#2782](https://github.com/fecgov/openFEC/pull/2782) ([pkfec](https://github.com/pkfec))
- Remove duplicate AO statute citations [\#2781](https://github.com/fecgov/openFEC/pull/2781) ([lbeaufort](https://github.com/lbeaufort))
- Remove deprecated references in README [\#2780](https://github.com/fecgov/openFEC/pull/2780) ([xtine](https://github.com/xtine))
- Feature/db migration [\#2768](https://github.com/fecgov/openFEC/pull/2768) ([vrajmohan](https://github.com/vrajmohan))
- Use environment variable otherwise default to INFO [\#2758](https://github.com/fecgov/openFEC/pull/2758) ([sharms](https://github.com/sharms))

## [calendar-hide-unpublished](https://github.com/fecgov/openFEC/tree/calendar-hide-unpublished) (2017-12-12)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20171206-deploy...calendar-hide-unpublished)

**Fixed bugs:**

- Statutory citations are sometimes repeated in a single AO [\#2762](https://github.com/fecgov/openFEC/issues/2762)

**Closed issues:**

- Remove WRITE\_AUTHORIZED\_TOKENS from api env creds [\#2802](https://github.com/fecgov/openFEC/issues/2802)
- Optimize `real\_efile\_sb4` and `real\_efile\_sa7` queries [\#2796](https://github.com/fecgov/openFEC/issues/2796)
- Restore swagger-tools install line in README [\#2795](https://github.com/fecgov/openFEC/issues/2795)
- Update uglify  [\#2794](https://github.com/fecgov/openFEC/issues/2794)
- Update swagger-ui to 3.x [\#2770](https://github.com/fecgov/openFEC/issues/2770)
- upgrade build pack [\#2765](https://github.com/fecgov/openFEC/issues/2765)

**Merged pull requests:**

- only show published events [\#2808](https://github.com/fecgov/openFEC/pull/2808) ([LindsayYoung](https://github.com/LindsayYoung))

## [public-20171206-deploy](https://github.com/fecgov/openFEC/tree/public-20171206-deploy) (2017-12-06)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20171206...public-20171206-deploy)

**Closed issues:**

- Check Logs 12/6/17 [\#2775](https://github.com/fecgov/openFEC/issues/2775)

**Merged pull requests:**

- Add logging to celery-beat [\#2774](https://github.com/fecgov/openFEC/pull/2774) ([lbeaufort](https://github.com/lbeaufort))
- \[MERGE WITH GITFLOW\] Release/public 20171206 [\#2772](https://github.com/fecgov/openFEC/pull/2772) ([lbeaufort](https://github.com/lbeaufort))

## [public-20171206](https://github.com/fecgov/openFEC/tree/public-20171206) (2017-12-06)

[Full Changelog](https://github.com/fecgov/openFEC/compare/update-swagger...public-20171206)

**Closed issues:**

- Add more logs for celery-beat [\#2771](https://github.com/fecgov/openFEC/issues/2771)
- Ensure schema parity between dev, stage and prod databases [\#2747](https://github.com/fecgov/openFEC/issues/2747)
- Create aggregates on FECP then transfer data to new website [\#2724](https://github.com/fecgov/openFEC/issues/2724)
- Check logs 11/29/17 [\#2718](https://github.com/fecgov/openFEC/issues/2718)

**Merged pull requests:**

- Feature/clean up [\#2763](https://github.com/fecgov/openFEC/pull/2763) ([LindsayYoung](https://github.com/LindsayYoung))

## [update-swagger](https://github.com/fecgov/openFEC/tree/update-swagger) (2017-11-28)

[Full Changelog](https://github.com/fecgov/openFEC/compare/swagger-update...update-swagger)

**Closed issues:**

- clean up sched A query in prod [\#2764](https://github.com/fecgov/openFEC/issues/2764)
- Fix issues surrounding API timeouts on 2017-11-15 [\#2756](https://github.com/fecgov/openFEC/issues/2756)
- Research task: research error logging in flask ahead of download training [\#2754](https://github.com/fecgov/openFEC/issues/2754)
- Add more logging to these processes - API  [\#2751](https://github.com/fecgov/openFEC/issues/2751)

## [swagger-update](https://github.com/fecgov/openFEC/tree/swagger-update) (2017-11-24)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20171122...swagger-update)

**Fixed bugs:**

- Modify public.ofec\_candidate\_history\_mv [\#2706](https://github.com/fecgov/openFEC/issues/2706)

**Closed issues:**

- Check logs 11/22/17 [\#2717](https://github.com/fecgov/openFEC/issues/2717)
- update schedule views  [\#2324](https://github.com/fecgov/openFEC/issues/2324)

**Merged pull requests:**

- Updating swagger template [\#2769](https://github.com/fecgov/openFEC/pull/2769) ([LindsayYoung](https://github.com/LindsayYoung))

## [public-20171122](https://github.com/fecgov/openFEC/tree/public-20171122) (2017-11-21)

[Full Changelog](https://github.com/fecgov/openFEC/compare/calendar-hotfix-deploy...public-20171122)

**Fixed bugs:**

- Add handling for "C.F.R." in regulation citations and extra space in statute citations [\#2740](https://github.com/fecgov/openFEC/pull/2740) ([lbeaufort](https://github.com/lbeaufort))

**Merged pull requests:**

- \[MERGE WITH GITFLOW\] Release/public 20171122 [\#2760](https://github.com/fecgov/openFEC/pull/2760) ([pkfec](https://github.com/pkfec))
- modify sql script to correct value in column candidate\_inactive [\#2727](https://github.com/fecgov/openFEC/pull/2727) ([hcaofec](https://github.com/hcaofec))
- Updated urls to avoid redirects [\#2704](https://github.com/fecgov/openFEC/pull/2704) ([mbrickn](https://github.com/mbrickn))

## [calendar-hotfix-deploy](https://github.com/fecgov/openFEC/tree/calendar-hotfix-deploy) (2017-11-21)

[Full Changelog](https://github.com/fecgov/openFEC/compare/calandar-filter...calendar-hotfix-deploy)

## [calandar-filter](https://github.com/fecgov/openFEC/tree/calandar-filter) (2017-11-21)

[Full Changelog](https://github.com/fecgov/openFEC/compare/improved-logging...calandar-filter)

**Fixed bugs:**

- canceled events showing on calendar [\#2696](https://github.com/fecgov/openFEC/issues/2696)
- Investigate issue with itemized schedule queues not being processed [\#2309](https://github.com/fecgov/openFEC/issues/2309)

**Closed issues:**

- CF cleanup [\#2744](https://github.com/fecgov/openFEC/issues/2744)
- Move remaining data files for the data catalog to S3 [\#2679](https://github.com/fecgov/openFEC/issues/2679)
- Replace hard-coded Senate special election years and classes [\#2621](https://github.com/fecgov/openFEC/issues/2621)
- remove write operations [\#2546](https://github.com/fecgov/openFEC/issues/2546)
- add indexes to dev and staging [\#2333](https://github.com/fecgov/openFEC/issues/2333)

**Merged pull requests:**

- Hotfix/calandar filter [\#2767](https://github.com/fecgov/openFEC/pull/2767) ([LindsayYoung](https://github.com/LindsayYoung))
- \[MERGE WITH GITFLOW\] Hotfix/calandar filter [\#2766](https://github.com/fecgov/openFEC/pull/2766) ([LindsayYoung](https://github.com/LindsayYoung))

## [improved-logging](https://github.com/fecgov/openFEC/tree/improved-logging) (2017-11-16)

[Full Changelog](https://github.com/fecgov/openFEC/compare/resource-adjustment...improved-logging)

**Merged pull requests:**

- \[MERGE WITH GIT FLOW\] Improve logging setup and update New Relic and requests [\#2759](https://github.com/fecgov/openFEC/pull/2759) ([ccostino](https://github.com/ccostino))

## [resource-adjustment](https://github.com/fecgov/openFEC/tree/resource-adjustment) (2017-11-15)

[Full Changelog](https://github.com/fecgov/openFEC/compare/better-logging...resource-adjustment)

**Merged pull requests:**

- increasing workers and resources, taking off debug, still working on b… [\#2757](https://github.com/fecgov/openFEC/pull/2757) ([LindsayYoung](https://github.com/LindsayYoung))

## [better-logging](https://github.com/fecgov/openFEC/tree/better-logging) (2017-11-15)

[Full Changelog](https://github.com/fecgov/openFEC/compare/build-pack-roll-back...better-logging)

**Fixed bugs:**

- Candidate profile doubles amounts when filers files wrong form and amends with correct form [\#2743](https://github.com/fecgov/openFEC/issues/2743)

**Closed issues:**

- Check logs 11/15/17 [\#2716](https://github.com/fecgov/openFEC/issues/2716)

**Merged pull requests:**

- this should give us better logging [\#2755](https://github.com/fecgov/openFEC/pull/2755) ([LindsayYoung](https://github.com/LindsayYoung))

## [build-pack-roll-back](https://github.com/fecgov/openFEC/tree/build-pack-roll-back) (2017-11-15)

[Full Changelog](https://github.com/fecgov/openFEC/compare/redeploy-10-11-2017...build-pack-roll-back)

**Closed issues:**

- Complete data load process upgrades [\#2746](https://github.com/fecgov/openFEC/issues/2746)
- Figure out download issues [\#2745](https://github.com/fecgov/openFEC/issues/2745)
- Golden Gate data loading time \(Wei\) [\#2686](https://github.com/fecgov/openFEC/issues/2686)

**Merged pull requests:**

- \[Merge with gitflow\] roll back buildpack [\#2753](https://github.com/fecgov/openFEC/pull/2753) ([LindsayYoung](https://github.com/LindsayYoung))

## [redeploy-10-11-2017](https://github.com/fecgov/openFEC/tree/redeploy-10-11-2017) (2017-11-11)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20171109...redeploy-10-11-2017)

**Merged pull requests:**

- Hotfix/restore queues [\#2737](https://github.com/fecgov/openFEC/pull/2737) ([LindsayYoung](https://github.com/LindsayYoung))

## [public-20171109](https://github.com/fecgov/openFEC/tree/public-20171109) (2017-11-09)

[Full Changelog](https://github.com/fecgov/openFEC/compare/remove-all-triggers...public-20171109)

**Closed issues:**

- Production timeouts 11/1/17 [\#2728](https://github.com/fecgov/openFEC/issues/2728)
- Check logs 11/8/17 [\#2715](https://github.com/fecgov/openFEC/issues/2715)
- Audit search: category & subcategory, performance, sort parameters & index checks [\#2677](https://github.com/fecgov/openFEC/issues/2677)

**Merged pull requests:**

- Update nvm and Node.js setup in CircleCI [\#2742](https://github.com/fecgov/openFEC/pull/2742) ([ccostino](https://github.com/ccostino))
- Add AO status to legal AO endpoint [\#2738](https://github.com/fecgov/openFEC/pull/2738) ([lbeaufort](https://github.com/lbeaufort))
- \[MERGE WITH GITFLOW\] Release/public 20171109 [\#2736](https://github.com/fecgov/openFEC/pull/2736) ([lbeaufort](https://github.com/lbeaufort))
- Set postgresql PATH correctly in CircleCI [\#2721](https://github.com/fecgov/openFEC/pull/2721) ([vrajmohan](https://github.com/vrajmohan))
- Feature/mur date filter [\#2712](https://github.com/fecgov/openFEC/pull/2712) ([lbeaufort](https://github.com/lbeaufort))
- Check for updates to MURs only [\#2709](https://github.com/fecgov/openFEC/pull/2709) ([vrajmohan](https://github.com/vrajmohan))
- Revert merge of 'feature/refactor-audit-search-endpoint' [\#2701](https://github.com/fecgov/openFEC/pull/2701) ([patphongs](https://github.com/patphongs))
- Modified "setup openFEC instruction" to add "nvm use --lts" and "npm … [\#2698](https://github.com/fecgov/openFEC/pull/2698) ([fec-jli](https://github.com/fec-jli))
- Update Python and Node.js runtimes and README [\#2670](https://github.com/fecgov/openFEC/pull/2670) ([ccostino](https://github.com/ccostino))
- feature/endpoint-for-totals-committe-type [\#2655](https://github.com/fecgov/openFEC/pull/2655) ([pkfec](https://github.com/pkfec))
- \[WIP\] feature/ Create query endpoint for AuditSearch [\#2626](https://github.com/fecgov/openFEC/pull/2626) ([rjayasekera](https://github.com/rjayasekera))
- Adding operating expenditures to F3x [\#2538](https://github.com/fecgov/openFEC/pull/2538) ([LindsayYoung](https://github.com/LindsayYoung))

## [remove-all-triggers](https://github.com/fecgov/openFEC/tree/remove-all-triggers) (2017-11-03)

[Full Changelog](https://github.com/fecgov/openFEC/compare/remove-aggregate-update-from-trigger...remove-all-triggers)

**Fixed bugs:**

- Image number search not working [\#2730](https://github.com/fecgov/openFEC/issues/2730)

**Closed issues:**

- try to replicate with multiple workers [\#2734](https://github.com/fecgov/openFEC/issues/2734)
- compare to @fecjjeng 's java program load times [\#2733](https://github.com/fecgov/openFEC/issues/2733)
- move to old aggregate creation on PG [\#2732](https://github.com/fecgov/openFEC/issues/2732)

**Merged pull requests:**

- Hotfix/disable fitem triggers [\#2735](https://github.com/fecgov/openFEC/pull/2735) ([vrajmohan](https://github.com/vrajmohan))

## [remove-aggregate-update-from-trigger](https://github.com/fecgov/openFEC/tree/remove-aggregate-update-from-trigger) (2017-11-02)

[Full Changelog](https://github.com/fecgov/openFEC/compare/no-Today-deploy-fix...remove-aggregate-update-from-trigger)

**Closed issues:**

- add second read replica back [\#2719](https://github.com/fecgov/openFEC/issues/2719)
- Check logs 11/1/17 [\#2714](https://github.com/fecgov/openFEC/issues/2714)
- Feedback tool not working on dev, stage environments [\#2713](https://github.com/fecgov/openFEC/issues/2713)
- Trigger MUR reloads only when MURs change, don't trigger on ADR or AF changes [\#2705](https://github.com/fecgov/openFEC/issues/2705)
- How do I get election \(votes\) data? [\#2702](https://github.com/fecgov/openFEC/issues/2702)
- add second read replica back [\#2699](https://github.com/fecgov/openFEC/issues/2699)
- Finalize API changes to remove the 2-year restriciton and add 6 year restriction [\#2684](https://github.com/fecgov/openFEC/issues/2684)
- Add MUR date to /legal/ API endpoint [\#2683](https://github.com/fecgov/openFEC/issues/2683)
- Setup time to discuss SQL tests with CM [\#2682](https://github.com/fecgov/openFEC/issues/2682)
- Terraform and concourse autopilot  [\#2680](https://github.com/fecgov/openFEC/issues/2680)
- Performance enhancements for audit search [\#2678](https://github.com/fecgov/openFEC/issues/2678)
- Review sort parameters of audit search [\#2675](https://github.com/fecgov/openFEC/issues/2675)
- Check logs 10/25/17 [\#2674](https://github.com/fecgov/openFEC/issues/2674)
- Check logs 10/18/17 [\#2673](https://github.com/fecgov/openFEC/issues/2673)
- Check logs 10/11/17 [\#2672](https://github.com/fecgov/openFEC/issues/2672)
- Check logs 10/4/17 [\#2671](https://github.com/fecgov/openFEC/issues/2671)
- Slack Integration: CircleCI and Github [\#2660](https://github.com/fecgov/openFEC/issues/2660)
- Document data update changes [\#2633](https://github.com/fecgov/openFEC/issues/2633)
- Add additional fields and filters to /totals/{committee-type} endpoint [\#2631](https://github.com/fecgov/openFEC/issues/2631)
- High availability redis [\#2629](https://github.com/fecgov/openFEC/issues/2629)
- Random bug: Last\_index pagination sometimes doesn't work for certain committees [\#2582](https://github.com/fecgov/openFEC/issues/2582)
- Reach out to FTP users to notify about new location [\#2541](https://github.com/fecgov/openFEC/issues/2541)
- Check and verify record counts of itemized schedule A and B data [\#2531](https://github.com/fecgov/openFEC/issues/2531)
- Salient update the datestamp in the AO/MUR main table when any child table is updated [\#2512](https://github.com/fecgov/openFEC/issues/2512)
- Salient to insert directly from raging wire AO and MUR tables to PG [\#2511](https://github.com/fecgov/openFEC/issues/2511)
- 24- and 48-hour Independent Expenditure transactions seem to be missing [\#2492](https://github.com/fecgov/openFEC/issues/2492)
- Check for and remove older software versions \[ATO\] [\#2488](https://github.com/fecgov/openFEC/issues/2488)
- Add automated migrations to the API [\#2427](https://github.com/fecgov/openFEC/issues/2427)

**Merged pull requests:**

- \[Merge with git flow\] Hotfix/remove aggregate update from trigger [\#2731](https://github.com/fecgov/openFEC/pull/2731) ([vrajmohan](https://github.com/vrajmohan))

## [no-Today-deploy-fix](https://github.com/fecgov/openFEC/tree/no-Today-deploy-fix) (2017-10-02)

[Full Changelog](https://github.com/fecgov/openFEC/compare/deploy-calander...no-Today-deploy-fix)

## [deploy-calander](https://github.com/fecgov/openFEC/tree/deploy-calander) (2017-10-02)

[Full Changelog](https://github.com/fecgov/openFEC/compare/re-deploy-calander...deploy-calander)

## [re-deploy-calander](https://github.com/fecgov/openFEC/tree/re-deploy-calander) (2017-10-02)

[Full Changelog](https://github.com/fecgov/openFEC/compare/fix-no-Today...re-deploy-calander)

## [fix-no-Today](https://github.com/fecgov/openFEC/tree/fix-no-Today) (2017-10-02)

[Full Changelog](https://github.com/fecgov/openFEC/compare/no-Today...fix-no-Today)

## [no-Today](https://github.com/fecgov/openFEC/tree/no-Today) (2017-10-02)

[Full Changelog](https://github.com/fecgov/openFEC/compare/no-Today-fix...no-Today)

## [no-Today-fix](https://github.com/fecgov/openFEC/tree/no-Today-fix) (2017-10-02)

[Full Changelog](https://github.com/fecgov/openFEC/compare/deploy-tag...no-Today-fix)

**Fixed bugs:**

- Fix itemized retry script  [\#2556](https://github.com/fecgov/openFEC/issues/2556)
- investigate data slowness [\#2263](https://github.com/fecgov/openFEC/issues/2263)
- Missing presidential candidates from 1992 [\#2095](https://github.com/fecgov/openFEC/issues/2095)
- Check aggregates by employer [\#2011](https://github.com/fecgov/openFEC/issues/2011)
- Seems like contributions are moving slower than they should be [\#1998](https://github.com/fecgov/openFEC/issues/1998)
- Record count very incorrect [\#1800](https://github.com/fecgov/openFEC/issues/1800)
- Bugs with election lookup [\#1757](https://github.com/fecgov/openFEC/issues/1757)
- National Party Nonfederal account committees not on /committees [\#1755](https://github.com/fecgov/openFEC/issues/1755)
- Zipcode search wrong about MD 20754 district [\#1599](https://github.com/fecgov/openFEC/issues/1599)
- elections summary missing consistent "results: : \[ \] formatting [\#1553](https://github.com/fecgov/openFEC/issues/1553)

**Closed issues:**

- Refactor category endpoint for audit search [\#2676](https://github.com/fecgov/openFEC/issues/2676)
- Nightly data transfer from Oracle\(DC4\) to Postgres\(AWS\) using Golden Gate [\#2653](https://github.com/fecgov/openFEC/issues/2653)
- Check logs 09/27/2017 [\#2643](https://github.com/fecgov/openFEC/issues/2643)
- check logs 09/20/2017 [\#2642](https://github.com/fecgov/openFEC/issues/2642)
- filter 'delete\_ind is null' needs to be added to these views in PG to exclude the committees that have been deleted [\#2627](https://github.com/fecgov/openFEC/issues/2627)
- add re-indexing test [\#2617](https://github.com/fecgov/openFEC/issues/2617)
- Create endpoints for Audit Search [\#2608](https://github.com/fecgov/openFEC/issues/2608)
- check logs 08/30/17 [\#2580](https://github.com/fecgov/openFEC/issues/2580)
- follow up on API limits [\#2569](https://github.com/fecgov/openFEC/issues/2569)
- Try to consolidate totals logic [\#2520](https://github.com/fecgov/openFEC/issues/2520)
- Bug: API should return empty string if no fecfile is present [\#2455](https://github.com/fecgov/openFEC/issues/2455)
- Refactor itemized schedule A and B setup [\#2446](https://github.com/fecgov/openFEC/issues/2446)
- RAD Analyst API Update Request [\#2261](https://github.com/fecgov/openFEC/issues/2261)
- Set up test coverage on code climate instead of code coverage [\#2194](https://github.com/fecgov/openFEC/issues/2194)
- Add filter tests for `efile\reports\\*` endpoints [\#2183](https://github.com/fecgov/openFEC/issues/2183)
- Investigate issues with the RDBMS subsetter tool [\#2170](https://github.com/fecgov/openFEC/issues/2170)
- Add legal endpoints to API docs [\#2161](https://github.com/fecgov/openFEC/issues/2161)
- Add plain language summaries to MURs [\#2155](https://github.com/fecgov/openFEC/issues/2155)
- Decide how to move forward with the Slate library [\#2154](https://github.com/fecgov/openFEC/issues/2154)
- Add plain language summaries to AOs [\#2153](https://github.com/fecgov/openFEC/issues/2153)
- Better manage advisory opinion dropdown constants [\#2150](https://github.com/fecgov/openFEC/issues/2150)
- Add API to data.gov [\#2132](https://github.com/fecgov/openFEC/issues/2132)
- Link to Federal Register notices on AO pages [\#2125](https://github.com/fecgov/openFEC/issues/2125)
- Clean up MUR reg and statute citation metadata and serve over API [\#2123](https://github.com/fecgov/openFEC/issues/2123)
- add synthetics to chart endpoints [\#2121](https://github.com/fecgov/openFEC/issues/2121)
- Load and index Administrative Fines \(AF\) [\#2085](https://github.com/fecgov/openFEC/issues/2085)
- Load and index Alternative Dispute Resolutions \(ADR\)  [\#2084](https://github.com/fecgov/openFEC/issues/2084)
- Develop way to print all case materials in a single PDF [\#2070](https://github.com/fecgov/openFEC/issues/2070)
- Add new documents to MURs [\#2055](https://github.com/fecgov/openFEC/issues/2055)
- New itemized views "..\_vsum\_xyz" need indexes on root tables [\#2046](https://github.com/fecgov/openFEC/issues/2046)
- ofec\_sched\_a\_aggregate\_state has 271 distinct state values [\#2010](https://github.com/fecgov/openFEC/issues/2010)
- Add legal data to the test dataset  [\#2006](https://github.com/fecgov/openFEC/issues/2006)
- create goldengate update log [\#2004](https://github.com/fecgov/openFEC/issues/2004)
- Add party like its [\#1999](https://github.com/fecgov/openFEC/issues/1999)
- Create endpoint for total IEs per state [\#1997](https://github.com/fecgov/openFEC/issues/1997)
- Add some indexes to the new data fields [\#1949](https://github.com/fecgov/openFEC/issues/1949)
- Enable exports/downloads for candidate office endpoints [\#1946](https://github.com/fecgov/openFEC/issues/1946)
- Figure out how to deal with approximate record differences for large table pages [\#1851](https://github.com/fecgov/openFEC/issues/1851)
-  non UTF-8 data [\#1841](https://github.com/fecgov/openFEC/issues/1841)
- Add additional logging for partitioning [\#1838](https://github.com/fecgov/openFEC/issues/1838)
- revisit Disbursements to committees [\#1835](https://github.com/fecgov/openFEC/issues/1835)
- purpose of disbursement aggregates [\#1833](https://github.com/fecgov/openFEC/issues/1833)
- make sure schedule A size merged stays up [\#1822](https://github.com/fecgov/openFEC/issues/1822)
- Information Architecture Usability Results [\#1809](https://github.com/fecgov/openFEC/issues/1809)
- Add sorting to name fields on schedule A and B [\#1806](https://github.com/fecgov/openFEC/issues/1806)
- Election page: Account for loans when presenting candidate comparisons [\#1758](https://github.com/fecgov/openFEC/issues/1758)
- Home button not obvious on mobile [\#1732](https://github.com/fecgov/openFEC/issues/1732)
- Date field usability finding: prefilled text in date fields proved cumbersome to replace [\#1727](https://github.com/fecgov/openFEC/issues/1727)
- API improvements [\#1725](https://github.com/fecgov/openFEC/issues/1725)
- When prompted to find a major donor, users could not find "individual contributions" [\#1722](https://github.com/fecgov/openFEC/issues/1722)
- When seeking filing deadlines, users routinely go first to Registration & Reporting [\#1721](https://github.com/fecgov/openFEC/issues/1721)
- IE summary and discription is flipped on the calendar [\#1698](https://github.com/fecgov/openFEC/issues/1698)
- Make further improvements to typeahead filter design based on testing [\#1672](https://github.com/fecgov/openFEC/issues/1672)
- Deliver a list of user centered reading sources  [\#1660](https://github.com/fecgov/openFEC/issues/1660)
- Usability finding: confusion in how applied filters work [\#1653](https://github.com/fecgov/openFEC/issues/1653)
- Update linters and run on travis and/or hound [\#1646](https://github.com/fecgov/openFEC/issues/1646)
- Replace proxy app with cf paths [\#1621](https://github.com/fecgov/openFEC/issues/1621)
- Convert views to tables [\#1618](https://github.com/fecgov/openFEC/issues/1618)
- Isolate 18F-specific content in our README to its own home [\#1614](https://github.com/fecgov/openFEC/issues/1614)
- Evaluate consolidating overlapping models [\#1612](https://github.com/fecgov/openFEC/issues/1612)
- Figure out what to do with these instructions and notes [\#1608](https://github.com/fecgov/openFEC/issues/1608)
- Make schedule\_b filter for operating expenditures [\#1607](https://github.com/fecgov/openFEC/issues/1607)
- Document rationale and rules for styleguide components [\#1602](https://github.com/fecgov/openFEC/issues/1602)
- Operating expenditure filter: Filing date [\#1589](https://github.com/fecgov/openFEC/issues/1589)
- Operating expenditures filter: Spending committee type / designation [\#1588](https://github.com/fecgov/openFEC/issues/1588)
- Operating expenditure filter: Spending committee's affiliated candidate [\#1587](https://github.com/fecgov/openFEC/issues/1587)
- Individual contribution filter: Filing date [\#1586](https://github.com/fecgov/openFEC/issues/1586)
- Individual contribution filters: associated candidate [\#1585](https://github.com/fecgov/openFEC/issues/1585)
- Individual contribution filters: Recipient committee type & designation [\#1584](https://github.com/fecgov/openFEC/issues/1584)
- Amazon scaling  [\#1574](https://github.com/fecgov/openFEC/issues/1574)
- Restore referer restriction on api.data.gov [\#1532](https://github.com/fecgov/openFEC/issues/1532)
- redirect open.fec.gov to beta.fec.gov [\#1513](https://github.com/fecgov/openFEC/issues/1513)
- Ping all the things [\#1510](https://github.com/fecgov/openFEC/issues/1510)
- Discussion: Null rows in sched\_b [\#1503](https://github.com/fecgov/openFEC/issues/1503)
- Server errors for certain candidates on dev [\#1470](https://github.com/fecgov/openFEC/issues/1470)
- Consolidate data process documentation [\#1461](https://github.com/fecgov/openFEC/issues/1461)
- Optimize slow queries [\#1402](https://github.com/fecgov/openFEC/issues/1402)
- Can't link to a sub-tab of a page [\#1376](https://github.com/fecgov/openFEC/issues/1376)
- Improve identifers [\#1355](https://github.com/fecgov/openFEC/issues/1355)
- Improve naming conventions [\#1354](https://github.com/fecgov/openFEC/issues/1354)
- Find records that have been recently processed [\#1353](https://github.com/fecgov/openFEC/issues/1353)
- think about adding date\_changed to committee information [\#1345](https://github.com/fecgov/openFEC/issues/1345)
- Make pg\_dumps public [\#1329](https://github.com/fecgov/openFEC/issues/1329)
- To have confidence in our data, clarify amendment-related variables [\#1319](https://github.com/fecgov/openFEC/issues/1319)
- So users can find transactions easier, allow column sorting in disbursement and receipt searches [\#1307](https://github.com/fecgov/openFEC/issues/1307)
- To have good data, Proactively identify data errors [\#1234](https://github.com/fecgov/openFEC/issues/1234)
- Change incumbent\_challenge and incumbent\_challenge\_full to use challenger [\#1231](https://github.com/fecgov/openFEC/issues/1231)
- To provide context to receipts aggregates, show total and/or percentage of total [\#1145](https://github.com/fecgov/openFEC/issues/1145)
- Write aggregate updates using SQLAlchemy [\#1077](https://github.com/fecgov/openFEC/issues/1077)
- To let users try out endpoints without knowing ids Add cand\_id suggestions in documentation? [\#1065](https://github.com/fecgov/openFEC/issues/1065)
- Include cycles from principal committee in candidate active cycles [\#956](https://github.com/fecgov/openFEC/issues/956)
- to be professional looking, we should add a favicon for the API [\#948](https://github.com/fecgov/openFEC/issues/948)
- To allow users coming from Google to begin searching immediately, implement Google Sitelinks Search Box [\#940](https://github.com/fecgov/openFEC/issues/940)
- To help more users access the API , build API clients with swagger-codegen [\#932](https://github.com/fecgov/openFEC/issues/932)
- To make search more flexible, enable searching by nicknames [\#854](https://github.com/fecgov/openFEC/issues/854)
- To begin improving performance, profile the webapp [\#798](https://github.com/fecgov/openFEC/issues/798)
- To make API docs more usable, include parenthetical examples for each field in documentation [\#382](https://github.com/fecgov/openFEC/issues/382)
- To help users find leadership PACs, link them to candidates [\#250](https://github.com/fecgov/openFEC/issues/250)
- As a frequent checker of candidate and committee filing, I'd like the ability to subscribe to updates to candidate/committees pages, so that I can stay current with the most recent changes as soon as they happen. [\#156](https://github.com/fecgov/openFEC/issues/156)

**Merged pull requests:**

- \[MERGE WITH GITFLOW\] hotfix/no-Today [\#2688](https://github.com/fecgov/openFEC/pull/2688) ([lbeaufort](https://github.com/lbeaufort))

## [deploy-tag](https://github.com/fecgov/openFEC/tree/deploy-tag) (2017-09-21)

[Full Changelog](https://github.com/fecgov/openFEC/compare/election-double-count...deploy-tag)

**Fixed bugs:**

- Schedule A/B parent tables should not have any data [\#2652](https://github.com/fecgov/openFEC/issues/2652)
- Remove old function from nightly update tasks [\#2662](https://github.com/fecgov/openFEC/pull/2662) ([ccostino](https://github.com/ccostino))

**Closed issues:**

- Need warning about sale and use of campaign information on API page [\#2657](https://github.com/fecgov/openFEC/issues/2657)
- Fix broken links in README.md setup section [\#2650](https://github.com/fecgov/openFEC/issues/2650)
- check logs 09/13/2017 [\#2641](https://github.com/fecgov/openFEC/issues/2641)
- check logs 09/06/2017 [\#2640](https://github.com/fecgov/openFEC/issues/2640)
- Test out new elasticsearch capabilities [\#2600](https://github.com/fecgov/openFEC/issues/2600)
- migrate to circle CI [\#2598](https://github.com/fecgov/openFEC/issues/2598)
- Automatically trigger the loading of MURs when new data available in Postgres [\#2445](https://github.com/fecgov/openFEC/issues/2445)

**Merged pull requests:**

- Merge recent develop fixes into the upcoming release branch [\#2669](https://github.com/fecgov/openFEC/pull/2669) ([ccostino](https://github.com/ccostino))
- Convert sched\_a\_by\_size\_merged\_mv to a plain table [\#2668](https://github.com/fecgov/openFEC/pull/2668) ([vrajmohan](https://github.com/vrajmohan))
- Remove copy-and-paste remnant [\#2666](https://github.com/fecgov/openFEC/pull/2666) ([vrajmohan](https://github.com/vrajmohan))
- Restore default search by `\_all` field [\#2665](https://github.com/fecgov/openFEC/pull/2665) ([vrajmohan](https://github.com/vrajmohan))
- Remove potentially dangerous function [\#2664](https://github.com/fecgov/openFEC/pull/2664) ([vrajmohan](https://github.com/vrajmohan))
- Feature/fix test on release [\#2659](https://github.com/fecgov/openFEC/pull/2659) ([vrajmohan](https://github.com/vrajmohan))
- Feature/add circleci support to release branch [\#2658](https://github.com/fecgov/openFEC/pull/2658) ([LindsayYoung](https://github.com/LindsayYoung))
- Save the committe\_id for use by downstream queries [\#2656](https://github.com/fecgov/openFEC/pull/2656) ([vrajmohan](https://github.com/vrajmohan))
- Fix README links \#2650 [\#2651](https://github.com/fecgov/openFEC/pull/2651) ([danielvdao](https://github.com/danielvdao))
- \[MERGE WITH GIT FLOW\] Release/public 20170913 [\#2649](https://github.com/fecgov/openFEC/pull/2649) ([LindsayYoung](https://github.com/LindsayYoung))
- Remove unused command [\#2648](https://github.com/fecgov/openFEC/pull/2648) ([vrajmohan](https://github.com/vrajmohan))
- Add support for CircleCI service integration [\#2647](https://github.com/fecgov/openFEC/pull/2647) ([ccostino](https://github.com/ccostino))
- updating code for HA redis [\#2635](https://github.com/fecgov/openFEC/pull/2635) ([LindsayYoung](https://github.com/LindsayYoung))
- fix issue \#2601 to exclude 24/48 data [\#2614](https://github.com/fecgov/openFEC/pull/2614) ([fecjjeng](https://github.com/fecjjeng))
- Feature/add delete index command [\#2612](https://github.com/fecgov/openFEC/pull/2612) ([vrajmohan](https://github.com/vrajmohan))
- Feature/eliminate queues [\#2606](https://github.com/fecgov/openFEC/pull/2606) ([vrajmohan](https://github.com/vrajmohan))
- Feature/parse boolean operators [\#2566](https://github.com/fecgov/openFEC/pull/2566) ([anthonygarvan](https://github.com/anthonygarvan))

## [election-double-count](https://github.com/fecgov/openFEC/tree/election-double-count) (2017-09-06)

[Full Changelog](https://github.com/fecgov/openFEC/compare/fix-form-6...election-double-count)

**Closed issues:**

- Exclude Form 6 from candidate aggregate view [\#2625](https://github.com/fecgov/openFEC/issues/2625)

**Merged pull requests:**

- Hotfix/election double count [\#2637](https://github.com/fecgov/openFEC/pull/2637) ([LindsayYoung](https://github.com/LindsayYoung))
- Hotfix/fix form 6 [\#2636](https://github.com/fecgov/openFEC/pull/2636) ([LindsayYoung](https://github.com/LindsayYoung))

## [fix-form-6](https://github.com/fecgov/openFEC/tree/fix-form-6) (2017-09-01)

[Full Changelog](https://github.com/fecgov/openFEC/compare/fix-sched-b...fix-form-6)

**Fixed bugs:**

- Fix and improve update\_all process [\#2610](https://github.com/fecgov/openFEC/issues/2610)
- first file date filter on committees [\#2332](https://github.com/fecgov/openFEC/issues/2332)
- Schedule E aggregates don't appear to be comprehensively updated [\#1582](https://github.com/fecgov/openFEC/issues/1582)

**Closed issues:**

- Election data fixes [\#2590](https://github.com/fecgov/openFEC/issues/2590)
- check logs 08/23/17 [\#2579](https://github.com/fecgov/openFEC/issues/2579)
- Improve RDS logging [\#2564](https://github.com/fecgov/openFEC/issues/2564)
- New relic on proxy app [\#2561](https://github.com/fecgov/openFEC/issues/2561)
- Test expanding 100k download limit [\#2342](https://github.com/fecgov/openFEC/issues/2342)
- Introduce high-level Python version pinning [\#2271](https://github.com/fecgov/openFEC/issues/2271)
- Missing Archive MUR pdfs [\#1996](https://github.com/fecgov/openFEC/issues/1996)
- Migrate NML\_FORM\_9 [\#1788](https://github.com/fecgov/openFEC/issues/1788)

## [fix-sched-b](https://github.com/fecgov/openFEC/tree/fix-sched-b) (2017-08-24)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20170811...fix-sched-b)

**Merged pull requests:**

- hotfix/ fix sched b [\#2624](https://github.com/fecgov/openFEC/pull/2624) ([LindsayYoung](https://github.com/LindsayYoung))

## [public-20170811](https://github.com/fecgov/openFEC/tree/public-20170811) (2017-08-24)

[Full Changelog](https://github.com/fecgov/openFEC/compare/remove-nightly-retry...public-20170811)

**Fixed bugs:**

- wrong candidate in search return for state/district house candidate list. [\#2618](https://github.com/fecgov/openFEC/issues/2618)
- Form 5 totals incorrectly including 24- and 48-hour reports [\#2601](https://github.com/fecgov/openFEC/issues/2601)
- Nightly refresh process failing/not working correctly in the dev environment [\#2585](https://github.com/fecgov/openFEC/issues/2585)
- Tweak Celery config to flip ack\_late setting [\#2599](https://github.com/fecgov/openFEC/pull/2599) ([ccostino](https://github.com/ccostino))
- Fix tests with references to the unittest.mock module [\#2583](https://github.com/fecgov/openFEC/pull/2583) ([ccostino](https://github.com/ccostino))
- Force using Trusty and PostgreSQL 9.6 in Travis CI [\#2570](https://github.com/fecgov/openFEC/pull/2570) ([ccostino](https://github.com/ccostino))

**Closed issues:**

- check logs 02/16/17  [\#2578](https://github.com/fecgov/openFEC/issues/2578)
- Recreate redis in stage and dev [\#2572](https://github.com/fecgov/openFEC/issues/2572)
- Database improvements for itemized schedule data [\#2423](https://github.com/fecgov/openFEC/issues/2423)

**Merged pull requests:**

- feature/office filter [\#2623](https://github.com/fecgov/openFEC/pull/2623) ([LindsayYoung](https://github.com/LindsayYoung))
- Making sure we don't have duplicates [\#2622](https://github.com/fecgov/openFEC/pull/2622) ([LindsayYoung](https://github.com/LindsayYoung))
- Add support for separate partition index management [\#2613](https://github.com/fecgov/openFEC/pull/2613) ([ccostino](https://github.com/ccostino))
- Add update\_functions to nightly refresh [\#2611](https://github.com/fecgov/openFEC/pull/2611) ([ccostino](https://github.com/ccostino))
- Election search fixes [\#2609](https://github.com/fecgov/openFEC/pull/2609) ([jontours](https://github.com/jontours))
- \[MERGE WITH GITFLOW\] Release/public 20170811 [\#2605](https://github.com/fecgov/openFEC/pull/2605) ([LindsayYoung](https://github.com/LindsayYoung))
- Feature/add cand inactive back [\#2604](https://github.com/fecgov/openFEC/pull/2604) ([jontours](https://github.com/jontours))
- API fixes for election view page [\#2602](https://github.com/fecgov/openFEC/pull/2602) ([jontours](https://github.com/jontours))
- Add support for multi-column GIN indexes [\#2594](https://github.com/fecgov/openFEC/pull/2594) ([ccostino](https://github.com/ccostino))
- Remove nightly retry processing of itemized schedule A and B data [\#2589](https://github.com/fecgov/openFEC/pull/2589) ([ccostino](https://github.com/ccostino))
- Update Celery to 4.1.0 [\#2588](https://github.com/fecgov/openFEC/pull/2588) ([ccostino](https://github.com/ccostino))
- cast last\_index to string; updated docs [\#2587](https://github.com/fecgov/openFEC/pull/2587) ([jontours](https://github.com/jontours))
- Feature/download directly to s3 [\#2584](https://github.com/fecgov/openFEC/pull/2584) ([vrajmohan](https://github.com/vrajmohan))
- Fix for missing column [\#2575](https://github.com/fecgov/openFEC/pull/2575) ([jontours](https://github.com/jontours))
- Include pg\_date in view [\#2565](https://github.com/fecgov/openFEC/pull/2565) ([vrajmohan](https://github.com/vrajmohan))
- Refresh current MURs periodically [\#2563](https://github.com/fecgov/openFEC/pull/2563) ([vrajmohan](https://github.com/vrajmohan))
- Only return a candidate once [\#2562](https://github.com/fecgov/openFEC/pull/2562) ([LindsayYoung](https://github.com/LindsayYoung))
- Adding a template for deploying headless apps. [\#2560](https://github.com/fecgov/openFEC/pull/2560) ([LindsayYoung](https://github.com/LindsayYoung))
- fixed boolean operator to make sure both legal and bulk downloads wil… [\#2552](https://github.com/fecgov/openFEC/pull/2552) ([patphongs](https://github.com/patphongs))
- Deletion exception for bulk-downloads [\#2551](https://github.com/fecgov/openFEC/pull/2551) ([patphongs](https://github.com/patphongs))
- State filters [\#2550](https://github.com/fecgov/openFEC/pull/2550) ([jontours](https://github.com/jontours))
- Fixes html\_url property in filing end points [\#2548](https://github.com/fecgov/openFEC/pull/2548) ([rjayasekera](https://github.com/rjayasekera))
- Incremented the celery-worker instance to 2 [\#2545](https://github.com/fecgov/openFEC/pull/2545) ([pkfec](https://github.com/pkfec))
- Upgrade Celery to latest 4.0.x release [\#2543](https://github.com/fecgov/openFEC/pull/2543) ([ccostino](https://github.com/ccostino))
- Move add\_itemized\_partition\_cycle feature to SQL [\#2540](https://github.com/fecgov/openFEC/pull/2540) ([vrajmohan](https://github.com/vrajmohan))
- first pass at compound indexes for sched\_a and sched\_b [\#2530](https://github.com/fecgov/openFEC/pull/2530) ([anthonygarvan](https://github.com/anthonygarvan))
- Feature/use trigger for partition updates with clean history [\#2498](https://github.com/fecgov/openFEC/pull/2498) ([vrajmohan](https://github.com/vrajmohan))
- Create elections list and view from election dates [\#2485](https://github.com/fecgov/openFEC/pull/2485) ([LindsayYoung](https://github.com/LindsayYoung))
- Feature/load testing [\#2379](https://github.com/fecgov/openFEC/pull/2379) ([vrajmohan](https://github.com/vrajmohan))

## [remove-nightly-retry](https://github.com/fecgov/openFEC/tree/remove-nightly-retry) (2017-08-11)

[Full Changelog](https://github.com/fecgov/openFEC/compare/up-pool-timeout...remove-nightly-retry)

**Fixed bugs:**

- Investigate Celery outage [\#2459](https://github.com/fecgov/openFEC/issues/2459)
- Bug: Incorrect candidates showing up running in a district [\#2428](https://github.com/fecgov/openFEC/issues/2428)
- Remove nightly refresh of schedule A and B in prod [\#2603](https://github.com/fecgov/openFEC/pull/2603) ([ccostino](https://github.com/ccostino))

**Closed issues:**

- Switch New Relic alert emails to the fec joint email [\#2597](https://github.com/fecgov/openFEC/issues/2597)
- Error messages include stray comma [\#2591](https://github.com/fecgov/openFEC/issues/2591)
- check logs 02/09/17 [\#2577](https://github.com/fecgov/openFEC/issues/2577)
- check logs 07/02/17 [\#2576](https://github.com/fecgov/openFEC/issues/2576)
- Dev nightly updates [\#2571](https://github.com/fecgov/openFEC/issues/2571)
- Revisit downloads code for improvement [\#2549](https://github.com/fecgov/openFEC/issues/2549)
- Election dates endpoint fixes [\#2544](https://github.com/fecgov/openFEC/issues/2544)
- check logs 06/26/17 [\#2510](https://github.com/fecgov/openFEC/issues/2510)
- Create onboarding checklists [\#2474](https://github.com/fecgov/openFEC/issues/2474)
- Add archived MURs to API [\#2444](https://github.com/fecgov/openFEC/issues/2444)
- Profile summary issue [\#2431](https://github.com/fecgov/openFEC/issues/2431)
- Compare and double check postgres settings  [\#2394](https://github.com/fecgov/openFEC/issues/2394)
- Request: Add state filter for filings and reports [\#2378](https://github.com/fecgov/openFEC/issues/2378)
- Technical research spike on ElasticSearch for schedule data [\#2373](https://github.com/fecgov/openFEC/issues/2373)
- Add data dictionary to download manifest [\#1416](https://github.com/fecgov/openFEC/issues/1416)

## [up-pool-timeout](https://github.com/fecgov/openFEC/tree/up-pool-timeout) (2017-07-28)

[Full Changelog](https://github.com/fecgov/openFEC/compare/disable-retry-itemized...up-pool-timeout)

**Closed issues:**

- Rework API endpoint to export candidates: Presidential, House and Senate [\#2559](https://github.com/fecgov/openFEC/issues/2559)
- API development to support election summaries [\#2557](https://github.com/fecgov/openFEC/issues/2557)
- check logs 07/12/17 [\#2508](https://github.com/fecgov/openFEC/issues/2508)
- check logs 07/05/17 [\#2507](https://github.com/fecgov/openFEC/issues/2507)
- Nest entity types within requestor, commenter and counsel fields on AOs [\#2478](https://github.com/fecgov/openFEC/issues/2478)

**Merged pull requests:**

- Hotfix/up pool timeout [\#2567](https://github.com/fecgov/openFEC/pull/2567) ([LindsayYoung](https://github.com/LindsayYoung))

## [disable-retry-itemized](https://github.com/fecgov/openFEC/tree/disable-retry-itemized) (2017-07-24)

[Full Changelog](https://github.com/fecgov/openFEC/compare/horizantal-celery...disable-retry-itemized)

**Merged pull requests:**

- Hotfix/disable retry itemized [\#2555](https://github.com/fecgov/openFEC/pull/2555) ([LindsayYoung](https://github.com/LindsayYoung))

## [horizantal-celery](https://github.com/fecgov/openFEC/tree/horizantal-celery) (2017-07-24)

[Full Changelog](https://github.com/fecgov/openFEC/compare/celery-upgrade...horizantal-celery)

**Fixed bugs:**

- Investigate Celery legal docs refresh issue [\#2553](https://github.com/fecgov/openFEC/issues/2553)

**Closed issues:**

- Set up regular refresh of audit data [\#2542](https://github.com/fecgov/openFEC/issues/2542)
- Add html\_url value for /efile/filings/ and fix missing html\_url for /filings [\#2533](https://github.com/fecgov/openFEC/issues/2533)
- Create update process for audit data in Postgres [\#2526](https://github.com/fecgov/openFEC/issues/2526)
- Export Audit system data to Postgres [\#2515](https://github.com/fecgov/openFEC/issues/2515)
- check logs 07/19/17 [\#2509](https://github.com/fecgov/openFEC/issues/2509)

**Merged pull requests:**

- Hotfix/horizantal celery [\#2554](https://github.com/fecgov/openFEC/pull/2554) ([LindsayYoung](https://github.com/LindsayYoung))

## [celery-upgrade](https://github.com/fecgov/openFEC/tree/celery-upgrade) (2017-07-18)

[Full Changelog](https://github.com/fecgov/openFEC/compare/schedule-legal-refresh-with-cron...celery-upgrade)

**Fixed bugs:**

- Upgrade Celery and related dependencies [\#2537](https://github.com/fecgov/openFEC/issues/2537)
- Bug: Alabama senate special election missing [\#2476](https://github.com/fecgov/openFEC/issues/2476)

**Closed issues:**

- Election summary data presentation back-end API development [\#2518](https://github.com/fecgov/openFEC/issues/2518)

**Merged pull requests:**

- Hotfix/celery upgrade [\#2539](https://github.com/fecgov/openFEC/pull/2539) ([LindsayYoung](https://github.com/LindsayYoung))

## [schedule-legal-refresh-with-cron](https://github.com/fecgov/openFEC/tree/schedule-legal-refresh-with-cron) (2017-07-14)

[Full Changelog](https://github.com/fecgov/openFEC/compare/loan-mapping...schedule-legal-refresh-with-cron)

**Merged pull requests:**

- \[MERGE with git flow\] Hotfix/schedule legal refresh with cron [\#2529](https://github.com/fecgov/openFEC/pull/2529) ([vrajmohan](https://github.com/vrajmohan))

## [loan-mapping](https://github.com/fecgov/openFEC/tree/loan-mapping) (2017-07-14)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20170713...loan-mapping)

**Merged pull requests:**

- Amending the f3x total loan field because it is called other loans [\#2527](https://github.com/fecgov/openFEC/pull/2527) ([LindsayYoung](https://github.com/LindsayYoung))

## [public-20170713](https://github.com/fecgov/openFEC/tree/public-20170713) (2017-07-13)

[Full Changelog](https://github.com/fecgov/openFEC/compare/fix-test-subset...public-20170713)

**Closed issues:**

- Remove QuantifiedCode badge [\#2522](https://github.com/fecgov/openFEC/issues/2522)
- Consider refactor of totals logic strategy [\#2521](https://github.com/fecgov/openFEC/issues/2521)
- Elasticsearch research \(performance\) [\#2519](https://github.com/fecgov/openFEC/issues/2519)
- Update AOs and MURs should be flagged in the Postgres DB so that we can do incremental indexing [\#2460](https://github.com/fecgov/openFEC/issues/2460)
- Bind all S3 buckets as services in GovCloud [\#2301](https://github.com/fecgov/openFEC/issues/2301)

**Merged pull requests:**

- \[MERGE WITH GIT FLOW\] Release/public 20170713 [\#2525](https://github.com/fecgov/openFEC/pull/2525) ([vrajmohan](https://github.com/vrajmohan))
- Feature/add entities with types to ao doc [\#2524](https://github.com/fecgov/openFEC/pull/2524) ([anthonygarvan](https://github.com/anthonygarvan))
- Remove QuanitifiedCode badge [\#2523](https://github.com/fecgov/openFEC/pull/2523) ([ccostino](https://github.com/ccostino))
- Feature/archived mur command line options [\#2516](https://github.com/fecgov/openFEC/pull/2516) ([vrajmohan](https://github.com/vrajmohan))
- Feature/support maxtasksperschild param [\#2506](https://github.com/fecgov/openFEC/pull/2506) ([vrajmohan](https://github.com/vrajmohan))
- Feature/better logging for archived mu rs [\#2504](https://github.com/fecgov/openFEC/pull/2504) ([vrajmohan](https://github.com/vrajmohan))
- Feature/reinstate archived mu rs [\#2503](https://github.com/fecgov/openFEC/pull/2503) ([vrajmohan](https://github.com/vrajmohan))

## [fix-test-subset](https://github.com/fecgov/openFEC/tree/fix-test-subset) (2017-07-03)

[Full Changelog](https://github.com/fecgov/openFEC/compare/fix-real-efile-se-f57...fix-test-subset)

**Fixed bugs:**

- \[MERGE WITH GIT FLOW\] Fix test subset data [\#2514](https://github.com/fecgov/openFEC/pull/2514) ([ccostino](https://github.com/ccostino))

## [fix-real-efile-se-f57](https://github.com/fecgov/openFEC/tree/fix-real-efile-se-f57) (2017-07-03)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20170629...fix-real-efile-se-f57)

**Fixed bugs:**

- \[MERGE WITH GIT FLOW\] Fix real\_efile\_se\_f57\_vw view [\#2513](https://github.com/fecgov/openFEC/pull/2513) ([ccostino](https://github.com/ccostino))

## [public-20170629](https://github.com/fecgov/openFEC/tree/public-20170629) (2017-07-03)

[Full Changelog](https://github.com/fecgov/openFEC/compare/remake-ie-for-now...public-20170629)

**Fixed bugs:**

- Doubled numbers in candidate totals endpoint [\#2505](https://github.com/fecgov/openFEC/issues/2505)
- Duplicate transactions [\#2481](https://github.com/fecgov/openFEC/issues/2481)
- Bug: Candidate total receipts inflated [\#2480](https://github.com/fecgov/openFEC/issues/2480)
- Confirm Sched E trigger is on a table [\#2473](https://github.com/fecgov/openFEC/issues/2473)
- zero downtime celery [\#2388](https://github.com/fecgov/openFEC/issues/2388)
- Fix schedule E definition [\#2501](https://github.com/fecgov/openFEC/pull/2501) ([ccostino](https://github.com/ccostino))

**Closed issues:**

- Fitem update in dev [\#2496](https://github.com/fecgov/openFEC/issues/2496)
- AWS RDS instance certificate authority set to expire soon [\#2489](https://github.com/fecgov/openFEC/issues/2489)
- Investigate negative page numbers [\#2475](https://github.com/fecgov/openFEC/issues/2475)
- check logs 06/28/17 [\#2468](https://github.com/fecgov/openFEC/issues/2468)
- check logs 06/21/17 [\#2467](https://github.com/fecgov/openFEC/issues/2467)
- Configure Postgres to parallelize queries [\#2457](https://github.com/fecgov/openFEC/issues/2457)
- Add F5 efiling data to endpoint [\#2438](https://github.com/fecgov/openFEC/issues/2438)
- FEC sso [\#2399](https://github.com/fecgov/openFEC/issues/2399)
- Filings page additional filters [\#2368](https://github.com/fecgov/openFEC/issues/2368)
- Delete EW apps [\#2264](https://github.com/fecgov/openFEC/issues/2264)
- Add line number filter for schedule A and B [\#2228](https://github.com/fecgov/openFEC/issues/2228)
- Show links to HTML reports on /reports/ and /filings/ [\#2226](https://github.com/fecgov/openFEC/issues/2226)
- API Pull-Election Year  [\#1560](https://github.com/fecgov/openFEC/issues/1560)
- Build small tables from FECP [\#1539](https://github.com/fecgov/openFEC/issues/1539)
- Create recommendation for calendar content format [\#1492](https://github.com/fecgov/openFEC/issues/1492)
- Should we collect a list for the public of projects using our code or API? Where? [\#1422](https://github.com/fecgov/openFEC/issues/1422)
- Are we clear about the role of campaigns in funding? [\#1201](https://github.com/fecgov/openFEC/issues/1201)
- So that users can find the source data, include report name and link in chart tooltip [\#679](https://github.com/fecgov/openFEC/issues/679)

**Merged pull requests:**

- Union simplification for Schedule E [\#2502](https://github.com/fecgov/openFEC/pull/2502) ([jontours](https://github.com/jontours))
- \[MERGE WITH GITFLOW\] Release/public 20170629 [\#2500](https://github.com/fecgov/openFEC/pull/2500) ([LindsayYoung](https://github.com/LindsayYoung))
- Add html links to \reports and \filings [\#2499](https://github.com/fecgov/openFEC/pull/2499) ([jontours](https://github.com/jontours))
- Feature/sched f column refactor [\#2497](https://github.com/fecgov/openFEC/pull/2497) ([jontours](https://github.com/jontours))
- Update Schedule A, B, and E setup to have proper triggers [\#2495](https://github.com/fecgov/openFEC/pull/2495) ([ccostino](https://github.com/ccostino))
- Fixes double counting issue for special election candidates [\#2494](https://github.com/fecgov/openFEC/pull/2494) ([jontours](https://github.com/jontours))
- Swap out old fec\_vsum views for new fec\_fitem views [\#2483](https://github.com/fecgov/openFEC/pull/2483) ([ccostino](https://github.com/ccostino))
- Add F5 filings to raw IE endpoint [\#2469](https://github.com/fecgov/openFEC/pull/2469) ([jontours](https://github.com/jontours))
- Zip code search enabled on contributions [\#2365](https://github.com/fecgov/openFEC/pull/2365) ([jontours](https://github.com/jontours))
- Line number filter [\#2363](https://github.com/fecgov/openFEC/pull/2363) ([jontours](https://github.com/jontours))

## [remake-ie-for-now](https://github.com/fecgov/openFEC/tree/remake-ie-for-now) (2017-06-16)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20170614...remake-ie-for-now)

**Fixed bugs:**

- Presidential Individual Contribution amount is incorrect [\#2477](https://github.com/fecgov/openFEC/issues/2477)

**Closed issues:**

- Committee profile page error [\#2487](https://github.com/fecgov/openFEC/issues/2487)
- Doubling candidate totals on this candidate [\#2482](https://github.com/fecgov/openFEC/issues/2482)

**Merged pull requests:**

- \[MERGE WITH GITFLOW\]remake schedule e nightly so that it is up to date [\#2493](https://github.com/fecgov/openFEC/pull/2493) ([LindsayYoung](https://github.com/LindsayYoung))

## [public-20170614](https://github.com/fecgov/openFEC/tree/public-20170614) (2017-06-14)

[Full Changelog](https://github.com/fecgov/openFEC/compare/calandar-update...public-20170614)

**Fixed bugs:**

- Individual Contributions not appearing [\#2442](https://github.com/fecgov/openFEC/issues/2442)
- Fix 500 Error when accessing non-existent MUR \# [\#2420](https://github.com/fecgov/openFEC/issues/2420)

**Closed issues:**

- check logs 06/14/17 [\#2466](https://github.com/fecgov/openFEC/issues/2466)
- latency issue with filings [\#2461](https://github.com/fecgov/openFEC/issues/2461)
- Net Contributions and Net Operating Expenditures are wrong in API [\#2458](https://github.com/fecgov/openFEC/issues/2458)
- 2017 Election Year for Presidential Candidates [\#2456](https://github.com/fecgov/openFEC/issues/2456)
- Add API support for sorting AO documents  [\#2415](https://github.com/fecgov/openFEC/issues/2415)
- consolidate house/senate and presidential totals scripts [\#2408](https://github.com/fecgov/openFEC/issues/2408)
- check logs 06/07/17 [\#2386](https://github.com/fecgov/openFEC/issues/2386)
- check logs 05/31/17 [\#2385](https://github.com/fecgov/openFEC/issues/2385)
- check logs 05/24/17 [\#2384](https://github.com/fecgov/openFEC/issues/2384)
- Remove default final opinion search on API [\#2341](https://github.com/fecgov/openFEC/issues/2341)
- IE processed vs raw  Filter problem [\#2318](https://github.com/fecgov/openFEC/issues/2318)

**Merged pull requests:**

- Fixes net\_contributions and net\_operating\_expenditures [\#2472](https://github.com/fecgov/openFEC/pull/2472) ([jontours](https://github.com/jontours))
- Reference correct column for loans [\#2470](https://github.com/fecgov/openFEC/pull/2470) ([jontours](https://github.com/jontours))
- Reduces chance of null coverage end dates in committee totals [\#2464](https://github.com/fecgov/openFEC/pull/2464) ([jontours](https://github.com/jontours))
- \[MERGE WITH GITFLOW\] Release/public 20170614 [\#2463](https://github.com/fecgov/openFEC/pull/2463) ([LindsayYoung](https://github.com/LindsayYoung))
- Committee Totals Refactor [\#2454](https://github.com/fecgov/openFEC/pull/2454) ([jontours](https://github.com/jontours))
- when no ao category is present, we no longer restrict on ao category [\#2451](https://github.com/fecgov/openFEC/pull/2451) ([anthonygarvan](https://github.com/anthonygarvan))
- returning 404 if no mur docs are found [\#2447](https://github.com/fecgov/openFEC/pull/2447) ([anthonygarvan](https://github.com/anthonygarvan))

## [calandar-update](https://github.com/fecgov/openFEC/tree/calandar-update) (2017-06-02)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20170601...calandar-update)

**Closed issues:**

- Automatically trigger the loading of AOs when new data available in Postgres  [\#2337](https://github.com/fecgov/openFEC/issues/2337)

**Merged pull requests:**

- Hotfix/calandar update [\#2453](https://github.com/fecgov/openFEC/pull/2453) ([LindsayYoung](https://github.com/LindsayYoung))

## [public-20170601](https://github.com/fecgov/openFEC/tree/public-20170601) (2017-06-01)

[Full Changelog](https://github.com/fecgov/openFEC/compare/sched-c-f-hotfixes...public-20170601)

**Fixed bugs:**

- Problem with contributions by size on committee profile pages [\#2430](https://github.com/fecgov/openFEC/issues/2430)
- Bug: 24-hour report amendments have incorrect report year [\#2429](https://github.com/fecgov/openFEC/issues/2429)
- Schedule C \(itemized Loans\) not working [\#2417](https://github.com/fecgov/openFEC/issues/2417)

**Closed issues:**

- Investigate ways in which we can utilize PostgreSQL's "upsert" support for itemized schedule data updates [\#2227](https://github.com/fecgov/openFEC/issues/2227)

**Merged pull requests:**

- Release/public 20170601 [\#2450](https://github.com/fecgov/openFEC/pull/2450) ([noahmanger](https://github.com/noahmanger))
- fix name [\#2449](https://github.com/fecgov/openFEC/pull/2449) ([LindsayYoung](https://github.com/LindsayYoung))
- Naming the indexes explicitly  [\#2448](https://github.com/fecgov/openFEC/pull/2448) ([LindsayYoung](https://github.com/LindsayYoung))
- Use the right field name for AO number [\#2437](https://github.com/fecgov/openFEC/pull/2437) ([vrajmohan](https://github.com/vrajmohan))
- Refresh AOs every 15m [\#2425](https://github.com/fecgov/openFEC/pull/2425) ([vrajmohan](https://github.com/vrajmohan))
- Adding a refresh command and task that runs every 15 minutes [\#2424](https://github.com/fecgov/openFEC/pull/2424) ([LindsayYoung](https://github.com/LindsayYoung))
- swaps out beta references from README [\#2421](https://github.com/fecgov/openFEC/pull/2421) ([jameshupp](https://github.com/jameshupp))
- Feature/restrict ao search fields [\#2403](https://github.com/fecgov/openFEC/pull/2403) ([vrajmohan](https://github.com/vrajmohan))

## [sched-c-f-hotfixes](https://github.com/fecgov/openFEC/tree/sched-c-f-hotfixes) (2017-05-26)

[Full Changelog](https://github.com/fecgov/openFEC/compare/fix-manifest-file...sched-c-f-hotfixes)

## [fix-manifest-file](https://github.com/fecgov/openFEC/tree/fix-manifest-file) (2017-05-26)

[Full Changelog](https://github.com/fecgov/openFEC/compare/refactor-sched-f...fix-manifest-file)

**Merged pull requests:**

- \[MERGE WITH GIT FLOW\] Fix manifest file formatting [\#2441](https://github.com/fecgov/openFEC/pull/2441) ([ccostino](https://github.com/ccostino))

## [refactor-sched-f](https://github.com/fecgov/openFEC/tree/refactor-sched-f) (2017-05-26)

[Full Changelog](https://github.com/fecgov/openFEC/compare/deploy-fix...refactor-sched-f)

**Merged pull requests:**

- \[MERGE WITH GIT FLOW\] Fix deploy run statement [\#2440](https://github.com/fecgov/openFEC/pull/2440) ([ccostino](https://github.com/ccostino))
- \[Merge w/ GIT flow\] - Move sched\_f to materialized view [\#2436](https://github.com/fecgov/openFEC/pull/2436) ([jontours](https://github.com/jontours))

## [deploy-fix](https://github.com/fecgov/openFEC/tree/deploy-fix) (2017-05-26)

[Full Changelog](https://github.com/fecgov/openFEC/compare/zero-down-deploy...deploy-fix)

**Closed issues:**

- refresh task for calendar [\#2422](https://github.com/fecgov/openFEC/issues/2422)

**Merged pull requests:**

- Hotfix/deploy fix [\#2439](https://github.com/fecgov/openFEC/pull/2439) ([LindsayYoung](https://github.com/LindsayYoung))

## [zero-down-deploy](https://github.com/fecgov/openFEC/tree/zero-down-deploy) (2017-05-26)

[Full Changelog](https://github.com/fecgov/openFEC/compare/move-schedule-c-to-mv...zero-down-deploy)

**Merged pull requests:**

- Hotfix/zero down deploy [\#2435](https://github.com/fecgov/openFEC/pull/2435) ([LindsayYoung](https://github.com/LindsayYoung))

## [move-schedule-c-to-mv](https://github.com/fecgov/openFEC/tree/move-schedule-c-to-mv) (2017-05-26)

[Full Changelog](https://github.com/fecgov/openFEC/compare/coverage-date-fix...move-schedule-c-to-mv)

**Fixed bugs:**

- Recently-filed committees not showing up in search [\#2426](https://github.com/fecgov/openFEC/issues/2426)
- Bug: Candidate and committee totals coverage dates are wrong [\#2416](https://github.com/fecgov/openFEC/issues/2416)
- \[MERGE WITH GIT FLOW\] Change Schedule C to a materialized view [\#2434](https://github.com/fecgov/openFEC/pull/2434) ([ccostino](https://github.com/ccostino))

## [coverage-date-fix](https://github.com/fecgov/openFEC/tree/coverage-date-fix) (2017-05-25)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-20170523...coverage-date-fix)

**Fixed bugs:**

- Fix triggers  [\#2405](https://github.com/fecgov/openFEC/issues/2405)

**Closed issues:**

- check logs 05/17/17 [\#2383](https://github.com/fecgov/openFEC/issues/2383)
- Figure out post-flip feedback system [\#2340](https://github.com/fecgov/openFEC/issues/2340)
- Post-mortem on ElasticSearch downtime  [\#2198](https://github.com/fecgov/openFEC/issues/2198)

**Merged pull requests:**

- Hotfix/coverage date fix [\#2418](https://github.com/fecgov/openFEC/pull/2418) ([jontours](https://github.com/jontours))

## [public-20170523](https://github.com/fecgov/openFEC/tree/public-20170523) (2017-05-23)

[Full Changelog](https://github.com/fecgov/openFEC/compare/celery-vertical...public-20170523)

**Fixed bugs:**

- Interim fix for the nightly itemized schedule updates [\#2390](https://github.com/fecgov/openFEC/issues/2390)
- Bug: Aggregates in 2017-2018 seem to be broken [\#2375](https://github.com/fecgov/openFEC/issues/2375)
- Duplicate report data  [\#2354](https://github.com/fecgov/openFEC/issues/2354)
- Senate candidate and committee number problem [\#2255](https://github.com/fecgov/openFEC/issues/2255)
- Remove RAISE statements from triggers [\#2406](https://github.com/fecgov/openFEC/pull/2406) ([ccostino](https://github.com/ccostino))

**Closed issues:**

- Take out bata language in docs [\#2404](https://github.com/fecgov/openFEC/issues/2404)
- Missing SA transactions [\#2397](https://github.com/fecgov/openFEC/issues/2397)
- Rotate tokens \(due May 18\) [\#2387](https://github.com/fecgov/openFEC/issues/2387)
- create cname [\#2370](https://github.com/fecgov/openFEC/issues/2370)
- fec.gov and www.fec.gov domain changes [\#2369](https://github.com/fecgov/openFEC/issues/2369)
- Change RAD mv source [\#2359](https://github.com/fecgov/openFEC/issues/2359)
- Develop production issue prioritization process [\#2338](https://github.com/fecgov/openFEC/issues/2338)
- More Accounts for RDSs [\#2294](https://github.com/fecgov/openFEC/issues/2294)

**Merged pull requests:**

- fixing index name [\#2414](https://github.com/fecgov/openFEC/pull/2414) ([LindsayYoung](https://github.com/LindsayYoung))
- Filters out SL form type filings [\#2413](https://github.com/fecgov/openFEC/pull/2413) ([jontours](https://github.com/jontours))
-  \[MERGE WITH GITFLOW\]  Release/public 20170523 [\#2412](https://github.com/fecgov/openFEC/pull/2412) ([vrajmohan](https://github.com/vrajmohan))
- remove beta language [\#2407](https://github.com/fecgov/openFEC/pull/2407) ([LindsayYoung](https://github.com/LindsayYoung))
- Use RAD analyst view from disclosure schema. [\#2401](https://github.com/fecgov/openFEC/pull/2401) ([vrajmohan](https://github.com/vrajmohan))
- \[MERGE WITH GIT FLOW\] Fix nightly update trigger improvements [\#2398](https://github.com/fecgov/openFEC/pull/2398) ([ccostino](https://github.com/ccostino))
- Feature/update totals [\#2366](https://github.com/fecgov/openFEC/pull/2366) ([LindsayYoung](https://github.com/LindsayYoung))
- \[WIP\] Create reports [\#2350](https://github.com/fecgov/openFEC/pull/2350) ([LindsayYoung](https://github.com/LindsayYoung))

## [celery-vertical](https://github.com/fecgov/openFEC/tree/celery-vertical) (2017-05-16)

[Full Changelog](https://github.com/fecgov/openFEC/compare/deploy-celery...celery-vertical)

**Merged pull requests:**

- \[MERGE WITH GITFLOW\] hotfix/celery-vertical [\#2396](https://github.com/fecgov/openFEC/pull/2396) ([LindsayYoung](https://github.com/LindsayYoung))

## [deploy-celery](https://github.com/fecgov/openFEC/tree/deploy-celery) (2017-05-15)

[Full Changelog](https://github.com/fecgov/openFEC/compare/more-celery...deploy-celery)

**Merged pull requests:**

- \[MERGE WITH GITFLOW\] hotfix/more celery in prod [\#2393](https://github.com/fecgov/openFEC/pull/2393) ([LindsayYoung](https://github.com/LindsayYoung))

## [more-celery](https://github.com/fecgov/openFEC/tree/more-celery) (2017-05-15)

[Full Changelog](https://github.com/fecgov/openFEC/compare/redeploy-trigger-fix...more-celery)

## [redeploy-trigger-fix](https://github.com/fecgov/openFEC/tree/redeploy-trigger-fix) (2017-05-12)

[Full Changelog](https://github.com/fecgov/openFEC/compare/fix-nightly-update...redeploy-trigger-fix)

**Fixed bugs:**

- \[MERGE WITH GIT FLOW\] Fix itemized schedule trigger errors [\#2392](https://github.com/fecgov/openFEC/pull/2392) ([ccostino](https://github.com/ccostino))

**Merged pull requests:**

- \[WIP\] Adding compound indexes on ids and cycle [\#2391](https://github.com/fecgov/openFEC/pull/2391) ([LindsayYoung](https://github.com/LindsayYoung))

## [fix-nightly-update](https://github.com/fecgov/openFEC/tree/fix-nightly-update) (2017-05-12)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-beta-20170512...fix-nightly-update)

## [public-beta-20170512](https://github.com/fecgov/openFEC/tree/public-beta-20170512) (2017-05-11)

[Full Changelog](https://github.com/fecgov/openFEC/compare/tag-name...public-beta-20170512)

**Fixed bugs:**

- Bug: Full cycle totals don't work for candidates with partial activity [\#2367](https://github.com/fecgov/openFEC/issues/2367)
- Schedule E by candidate returning null data [\#2364](https://github.com/fecgov/openFEC/issues/2364)
- Election candidate lists [\#2248](https://github.com/fecgov/openFEC/issues/2248)

**Closed issues:**

- check logs 05/10/17 [\#2382](https://github.com/fecgov/openFEC/issues/2382)
- Increase SQL pool [\#2377](https://github.com/fecgov/openFEC/issues/2377)
- pool connection error [\#2371](https://github.com/fecgov/openFEC/issues/2371)
- Mid-year and quarterly calendar filters [\#2360](https://github.com/fecgov/openFEC/issues/2360)
- Prepare for DNS flip to fec.gov [\#2346](https://github.com/fecgov/openFEC/issues/2346)
- Better default date for null dates on legal resource documents [\#2345](https://github.com/fecgov/openFEC/issues/2345)
- Restrict AO search for greater consistency [\#2339](https://github.com/fecgov/openFEC/issues/2339)
- check logs 5/3/2017 [\#2327](https://github.com/fecgov/openFEC/issues/2327)
- check logs 04/27/17 [\#2326](https://github.com/fecgov/openFEC/issues/2326)
- revisit Disbursements received from committees [\#1834](https://github.com/fecgov/openFEC/issues/1834)
- Forms and schedules [\#1551](https://github.com/fecgov/openFEC/issues/1551)
- To make summary data easier to read, improve scale on inline bar charts [\#756](https://github.com/fecgov/openFEC/issues/756)

**Merged pull requests:**

- \[MERGE WITH GIT FLOW\] Release/public beta 20170512 [\#2381](https://github.com/fecgov/openFEC/pull/2381) ([ccostino](https://github.com/ccostino))
- Feature/configure sqlalchemy [\#2380](https://github.com/fecgov/openFEC/pull/2380) ([vrajmohan](https://github.com/vrajmohan))
- Fixes missing cycles for presidential candidates [\#2372](https://github.com/fecgov/openFEC/pull/2372) ([jontours](https://github.com/jontours))
- Feature/improve logging [\#2362](https://github.com/fecgov/openFEC/pull/2362) ([vrajmohan](https://github.com/vrajmohan))

## [tag-name](https://github.com/fecgov/openFEC/tree/tag-name) (2017-04-28)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-beta-20170427...tag-name)

**Merged pull requests:**

- Update env var references [\#2355](https://github.com/fecgov/openFEC/pull/2355) ([ccostino](https://github.com/ccostino))
- Increase resources for launch [\#2353](https://github.com/fecgov/openFEC/pull/2353) ([LindsayYoung](https://github.com/LindsayYoung))
- \[MERGE WITH GITFLOW\] Release/public beta 20170427 [\#2352](https://github.com/fecgov/openFEC/pull/2352) ([LindsayYoung](https://github.com/LindsayYoung))

## [public-beta-20170427](https://github.com/fecgov/openFEC/tree/public-beta-20170427) (2017-04-28)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-beta-20170421...public-beta-20170427)

**Fixed bugs:**

- Can't find form 2 list when looking at candidate profile [\#2322](https://github.com/fecgov/openFEC/issues/2322)
- Pac and Party reports returns nothing [\#2319](https://github.com/fecgov/openFEC/issues/2319)
- Schedule c update did not un on production [\#2119](https://github.com/fecgov/openFEC/issues/2119)

**Closed issues:**

- Add read replaca to prod [\#2336](https://github.com/fecgov/openFEC/issues/2336)
- add synthetics efiling endpoints [\#2331](https://github.com/fecgov/openFEC/issues/2331)
- "Raising Data Overview" link has unexpected result [\#2321](https://github.com/fecgov/openFEC/issues/2321)
- Financial summary links [\#2320](https://github.com/fecgov/openFEC/issues/2320)
- \[ATO\]Log for admin [\#2308](https://github.com/fecgov/openFEC/issues/2308)
- All filter and sort fields need indexes [\#2300](https://github.com/fecgov/openFEC/issues/2300)
- Categorize RFQs as RFAIs [\#2292](https://github.com/fecgov/openFEC/issues/2292)
- DNS [\#2274](https://github.com/fecgov/openFEC/issues/2274)
- Return highlighted matches per document in legal resource endpoints [\#2242](https://github.com/fecgov/openFEC/issues/2242)
- Improve date accuracy on /elections/search/ [\#2225](https://github.com/fecgov/openFEC/issues/2225)
- Advanced AO search filters searches by document type of "Final Opinion", even when no document type is checked [\#2189](https://github.com/fecgov/openFEC/issues/2189)

**Merged pull requests:**

- Appends FRQ so as not to wipe out other arguments if they exist [\#2351](https://github.com/fecgov/openFEC/pull/2351) ([jontours](https://github.com/jontours))
- FRQ Feature [\#2349](https://github.com/fecgov/openFEC/pull/2349) ([jontours](https://github.com/jontours))
- Move contributor aggregate after single receipt amount [\#2348](https://github.com/fecgov/openFEC/pull/2348) ([noahmanger](https://github.com/noahmanger))
- Feature/dont concatenate highlights [\#2347](https://github.com/fecgov/openFEC/pull/2347) ([vrajmohan](https://github.com/vrajmohan))
- fix badge formatting in the README [\#2311](https://github.com/fecgov/openFEC/pull/2311) ([afeld](https://github.com/afeld))

## [public-beta-20170421](https://github.com/fecgov/openFEC/tree/public-beta-20170421) (2017-04-21)

[Full Changelog](https://github.com/fecgov/openFEC/compare/use-correct-s3-region2...public-beta-20170421)

**Fixed bugs:**

- Missing data: Committee's Q3 and 12G reports missing [\#2117](https://github.com/fecgov/openFEC/issues/2117)

**Closed issues:**

- check logs 04/19/2017 [\#2329](https://github.com/fecgov/openFEC/issues/2329)
- check logs 04/17/17 [\#2325](https://github.com/fecgov/openFEC/issues/2325)
- "Years Active" incorrect in older committees. [\#2323](https://github.com/fecgov/openFEC/issues/2323)
- Show FEC how to do on-demand legal doc refresh [\#2307](https://github.com/fecgov/openFEC/issues/2307)
- Remove unverified filers from candidate and committee endpoints [\#2243](https://github.com/fecgov/openFEC/issues/2243)
- Index representatives and commenters on AOs [\#2240](https://github.com/fecgov/openFEC/issues/2240)
- Implement improved legal resources results display [\#2126](https://github.com/fecgov/openFEC/issues/2126)
- To make sub-totals easier to understand, visually distinguish them on the Detailed Summary [\#1280](https://github.com/fecgov/openFEC/issues/1280)

**Merged pull requests:**

- Release/public beta 20170421 [\#2335](https://github.com/fecgov/openFEC/pull/2335) ([LindsayYoung](https://github.com/LindsayYoung))
- Feature/restore efile reports [\#2330](https://github.com/fecgov/openFEC/pull/2330) ([LindsayYoung](https://github.com/LindsayYoung))
- adding ao\_entity\_name [\#2328](https://github.com/fecgov/openFEC/pull/2328) ([anthonygarvan](https://github.com/anthonygarvan))
- Index commenters and representatives in AOs [\#2316](https://github.com/fecgov/openFEC/pull/2316) ([vrajmohan](https://github.com/vrajmohan))
- example change [\#2312](https://github.com/fecgov/openFEC/pull/2312) ([LindsayYoung](https://github.com/LindsayYoung))
- Improve logging and split out calls for nightly updates [\#2306](https://github.com/fecgov/openFEC/pull/2306) ([ccostino](https://github.com/ccostino))
- Update web server tooling [\#2305](https://github.com/fecgov/openFEC/pull/2305) ([ccostino](https://github.com/ccostino))
- adding request date [\#2303](https://github.com/fecgov/openFEC/pull/2303) ([anthonygarvan](https://github.com/anthonygarvan))
- Add instructions for loading legal documents [\#2299](https://github.com/fecgov/openFEC/pull/2299) ([vrajmohan](https://github.com/vrajmohan))
- Support starting MUR case number when loading MURs [\#2298](https://github.com/fecgov/openFEC/pull/2298) ([vrajmohan](https://github.com/vrajmohan))
- Election search results fix [\#2297](https://github.com/fecgov/openFEC/pull/2297) ([jontours](https://github.com/jontours))
- Support starting AO number when loading AOs [\#2296](https://github.com/fecgov/openFEC/pull/2296) ([vrajmohan](https://github.com/vrajmohan))
- Remove unverified filers from candidate and committee endpoints [\#2278](https://github.com/fecgov/openFEC/pull/2278) ([ccostino](https://github.com/ccostino))

## [use-correct-s3-region2](https://github.com/fecgov/openFEC/tree/use-correct-s3-region2) (2017-04-13)

[Full Changelog](https://github.com/fecgov/openFEC/compare/deploy-s3-fix...use-correct-s3-region2)

## [deploy-s3-fix](https://github.com/fecgov/openFEC/tree/deploy-s3-fix) (2017-04-13)

[Full Changelog](https://github.com/fecgov/openFEC/compare/restore-efile-files...deploy-s3-fix)

**Fixed bugs:**

- Missing candidate from the Candidate Search in beta.fec.gov [\#2197](https://github.com/fecgov/openFEC/issues/2197)

**Merged pull requests:**

- Use the us-gov-west-1 S3 region [\#2315](https://github.com/fecgov/openFEC/pull/2315) ([vrajmohan](https://github.com/vrajmohan))

## [restore-efile-files](https://github.com/fecgov/openFEC/tree/restore-efile-files) (2017-04-12)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-beta-20170405...restore-efile-files)

**Fixed bugs:**

- Data comparison - Presidential [\#2251](https://github.com/fecgov/openFEC/issues/2251)

**Closed issues:**

- Redeploy apps every 3 days [\#2291](https://github.com/fecgov/openFEC/issues/2291)
- GovCloud release checklist [\#2270](https://github.com/fecgov/openFEC/issues/2270)
- Implement real-time refresh of AO and MUR data [\#2269](https://github.com/fecgov/openFEC/issues/2269)
- Run update\_all in cloud.gov dev, staging and production databases [\#2267](https://github.com/fecgov/openFEC/issues/2267)
- Add bandit to the repos \[ATO\] [\#2259](https://github.com/fecgov/openFEC/issues/2259)
- distinct dev tasks [\#2246](https://github.com/fecgov/openFEC/issues/2246)
- Add request date filter to AO endpoint [\#2241](https://github.com/fecgov/openFEC/issues/2241)
- Test new AO features [\#2222](https://github.com/fecgov/openFEC/issues/2222)
- Move API to new cloud.gov [\#2032](https://github.com/fecgov/openFEC/issues/2032)

**Merged pull requests:**

- \[MERGE WITH GITFLOW\] Fix efile/filings [\#2310](https://github.com/fecgov/openFEC/pull/2310) ([LindsayYoung](https://github.com/LindsayYoung))

## [public-beta-20170405](https://github.com/fecgov/openFEC/tree/public-beta-20170405) (2017-04-07)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-beta-20170306-1...public-beta-20170405)

**Fixed bugs:**

- Fix update\_all processing [\#2286](https://github.com/fecgov/openFEC/issues/2286)
- Offsets to operating expenditures pulling the wrong data on committee page [\#2249](https://github.com/fecgov/openFEC/issues/2249)
- Redis not working on govcloud [\#2244](https://github.com/fecgov/openFEC/issues/2244)
- Fix nightly update and database refresh tasks [\#2196](https://github.com/fecgov/openFEC/issues/2196)
- Fix queue processing to account for column type mis-match [\#2293](https://github.com/fecgov/openFEC/pull/2293) ([ccostino](https://github.com/ccostino))
- Removing setuptools and wheel due to pip warning output [\#2272](https://github.com/fecgov/openFEC/pull/2272) ([ccostino](https://github.com/ccostino))
- Fixes update\_all and underlying SQL [\#2218](https://github.com/fecgov/openFEC/pull/2218) ([ccostino](https://github.com/ccostino))

**Closed issues:**

- Allow AOs to be filtered by multiple citation using AND and OR logic [\#2275](https://github.com/fecgov/openFEC/issues/2275)
- Directly insert data instead of using queue tables [\#2268](https://github.com/fecgov/openFEC/issues/2268)
- Check logs for CMS \[ATO\] [\#2253](https://github.com/fecgov/openFEC/issues/2253)
- upgrade storage for gov cloud [\#2245](https://github.com/fecgov/openFEC/issues/2245)
- Sort legal docs by appropriate fields [\#2232](https://github.com/fecgov/openFEC/issues/2232)
- deployer per space on cloud.gov [\#2230](https://github.com/fecgov/openFEC/issues/2230)
- Provide all candidate financial summary totals from the API [\#2223](https://github.com/fecgov/openFEC/issues/2223)
- FEC to Start QA on AOs [\#2221](https://github.com/fecgov/openFEC/issues/2221)
- Figure out On-Demand Legal Doc Load [\#2220](https://github.com/fecgov/openFEC/issues/2220)
- Missing values on /committee/committee\_id/totals [\#2212](https://github.com/fecgov/openFEC/issues/2212)
- Data issues - Candidate Search [\#2210](https://github.com/fecgov/openFEC/issues/2210)
- Document type name for documents of type "Final Opinion" that are not true final opinions [\#2188](https://github.com/fecgov/openFEC/issues/2188)
- Clean up AO reg and statute citation metadata and serve over API [\#2164](https://github.com/fecgov/openFEC/issues/2164)

**Merged pull requests:**

- Restore highlights [\#2290](https://github.com/fecgov/openFEC/pull/2290) ([vrajmohan](https://github.com/vrajmohan))
- Bug/fix update all redux [\#2289](https://github.com/fecgov/openFEC/pull/2289) ([LindsayYoung](https://github.com/LindsayYoung))
- Add prod creds [\#2287](https://github.com/fecgov/openFEC/pull/2287) ([LindsayYoung](https://github.com/LindsayYoung))
- \[MERGE WITH GITFLOW\] Release/public beta 20170405 [\#2283](https://github.com/fecgov/openFEC/pull/2283) ([LindsayYoung](https://github.com/LindsayYoung))
- Don't exclude candidates without valid party codes. [\#2282](https://github.com/fecgov/openFEC/pull/2282) ([LindsayYoung](https://github.com/LindsayYoung))
- Fixing offsets [\#2281](https://github.com/fecgov/openFEC/pull/2281) ([LindsayYoung](https://github.com/LindsayYoung))
- Use only case number for sorting MURs [\#2277](https://github.com/fecgov/openFEC/pull/2277) ([vrajmohan](https://github.com/vrajmohan))
- Bugfix/fix elasticsearch load [\#2273](https://github.com/fecgov/openFEC/pull/2273) ([anthonygarvan](https://github.com/anthonygarvan))
- Update some of the backend tooling for the API [\#2266](https://github.com/fecgov/openFEC/pull/2266) ([ccostino](https://github.com/ccostino))
- Candidate committee aggregates [\#2262](https://github.com/fecgov/openFEC/pull/2262) ([jontours](https://github.com/jontours))
- Feature/gov cloud [\#2260](https://github.com/fecgov/openFEC/pull/2260) ([LindsayYoung](https://github.com/LindsayYoung))
- Feature/sort legal docs [\#2258](https://github.com/fecgov/openFEC/pull/2258) ([vrajmohan](https://github.com/vrajmohan))
- Add support and instructions for cf ssh [\#2257](https://github.com/fecgov/openFEC/pull/2257) ([ccostino](https://github.com/ccostino))
- Feature/add citation search to api [\#2256](https://github.com/fecgov/openFEC/pull/2256) ([anthonygarvan](https://github.com/anthonygarvan))
- Update redis service name. [\#2254](https://github.com/fecgov/openFEC/pull/2254) ([jmcarp](https://github.com/jmcarp))
- Finalize move of API to GovCloud [\#2252](https://github.com/fecgov/openFEC/pull/2252) ([LindsayYoung](https://github.com/LindsayYoung))
- Feature/gov cloud fix search [\#2250](https://github.com/fecgov/openFEC/pull/2250) ([vrajmohan](https://github.com/vrajmohan))
- Multi-sort fully enabled for reports [\#2235](https://github.com/fecgov/openFEC/pull/2235) ([jontours](https://github.com/jontours))
- Feature/add missing columns filings [\#2215](https://github.com/fecgov/openFEC/pull/2215) ([jontours](https://github.com/jontours))
- Switch from E/W to GovCloud [\#2199](https://github.com/fecgov/openFEC/pull/2199) ([LindsayYoung](https://github.com/LindsayYoung))

## [public-beta-20170306-1](https://github.com/fecgov/openFEC/tree/public-beta-20170306-1) (2017-03-10)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-beta-20170306...public-beta-20170306-1)

## [public-beta-20170306](https://github.com/fecgov/openFEC/tree/public-beta-20170306) (2017-03-10)

[Full Changelog](https://github.com/fecgov/openFEC/compare/refresh...public-beta-20170306)

**Fixed bugs:**

- How to merge is\_notice=false with is\_notice=true with schedule\_e \(independent expenditures\) [\#2072](https://github.com/fecgov/openFEC/issues/2072)

**Closed issues:**

- Sort AOs in Reverse Chronological Order [\#2219](https://github.com/fecgov/openFEC/issues/2219)
- Add committee name to communication cost resource. [\#2216](https://github.com/fecgov/openFEC/issues/2216)
- Add test for multi sort [\#2207](https://github.com/fecgov/openFEC/issues/2207)
- Refactor schema for advisory opinions [\#2186](https://github.com/fecgov/openFEC/issues/2186)
- Inform fec of view change for schedule\_d. [\#2180](https://github.com/fecgov/openFEC/issues/2180)
- Upgrade PostgreSQL to 9.6.1 [\#2058](https://github.com/fecgov/openFEC/issues/2058)

**Merged pull requests:**

- Use a nested query only when query param present [\#2239](https://github.com/fecgov/openFEC/pull/2239) ([vrajmohan](https://github.com/vrajmohan))
- \[MERGE WITH GIT FLOW\] Release/public beta 20170306 [\#2237](https://github.com/fecgov/openFEC/pull/2237) ([ccostino](https://github.com/ccostino))
- Revert "Sort MURs by descending case number" [\#2236](https://github.com/fecgov/openFEC/pull/2236) ([vrajmohan](https://github.com/vrajmohan))
- Remove calls to defunct methods for loading AOs [\#2234](https://github.com/fecgov/openFEC/pull/2234) ([vrajmohan](https://github.com/vrajmohan))
- Fix/search aos by document category [\#2233](https://github.com/fecgov/openFEC/pull/2233) ([vrajmohan](https://github.com/vrajmohan))
- This is a fix so records do not get duplicated if the committee [\#2229](https://github.com/fecgov/openFEC/pull/2229) ([LindsayYoung](https://github.com/LindsayYoung))
- Feature/reverse chronological sort [\#2224](https://github.com/fecgov/openFEC/pull/2224) ([vrajmohan](https://github.com/vrajmohan))
- Feature/add comm name to comm costs [\#2217](https://github.com/fecgov/openFEC/pull/2217) ([jontours](https://github.com/jontours))
- Index AOs using 1 Elasticsearch doc per AO [\#2203](https://github.com/fecgov/openFEC/pull/2203) ([vrajmohan](https://github.com/vrajmohan))

## [refresh](https://github.com/fecgov/openFEC/tree/refresh) (2017-02-17)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-beta-20170216...refresh)

**Merged pull requests:**

- Empty commit to perform a redeployment [\#2214](https://github.com/fecgov/openFEC/pull/2214) ([jontours](https://github.com/jontours))

## [public-beta-20170216](https://github.com/fecgov/openFEC/tree/public-beta-20170216) (2017-02-16)

[Full Changelog](https://github.com/fecgov/openFEC/compare/refresh-commit...public-beta-20170216)

## [refresh-commit](https://github.com/fecgov/openFEC/tree/refresh-commit) (2017-02-16)

[Full Changelog](https://github.com/fecgov/openFEC/compare/analyst-title...refresh-commit)

**Fixed bugs:**

- last\_index losing precision for itemized endpoints [\#2026](https://github.com/fecgov/openFEC/issues/2026)

**Closed issues:**

- Additional parameters needed for datatables [\#2200](https://github.com/fecgov/openFEC/issues/2200)
- Explore options for multiple sort properties for filings [\#2063](https://github.com/fecgov/openFEC/issues/2063)
- merge the entity totals endpoints [\#2028](https://github.com/fecgov/openFEC/issues/2028)
- Turn on CSV URLs for filings and reports [\#2000](https://github.com/fecgov/openFEC/issues/2000)
- Filings tab default sort [\#1711](https://github.com/fecgov/openFEC/issues/1711)

**Merged pull requests:**

- Hotfix/refresh commit [\#2213](https://github.com/fecgov/openFEC/pull/2213) ([jontours](https://github.com/jontours))
- Added test for multiple sort capability for filings [\#2211](https://github.com/fecgov/openFEC/pull/2211) ([jontours](https://github.com/jontours))
- Release/public beta 20170216 [\#2209](https://github.com/fecgov/openFEC/pull/2209) ([jontours](https://github.com/jontours))
- Add fec\_file\_id [\#2208](https://github.com/fecgov/openFEC/pull/2208) ([jontours](https://github.com/jontours))
- Feature/add filters to debts [\#2205](https://github.com/fecgov/openFEC/pull/2205) ([jontours](https://github.com/jontours))
- Uncommenting csv urls [\#2204](https://github.com/fecgov/openFEC/pull/2204) ([noahmanger](https://github.com/noahmanger))
- Bugfix/support three digit ao numbers [\#2201](https://github.com/fecgov/openFEC/pull/2201) ([anthonygarvan](https://github.com/anthonygarvan))
- updates to legal doc load [\#2195](https://github.com/fecgov/openFEC/pull/2195) ([anthonygarvan](https://github.com/anthonygarvan))
- Implement multiple sort for filings [\#2193](https://github.com/fecgov/openFEC/pull/2193) ([jontours](https://github.com/jontours))
- Removing dead search\(\) method [\#2191](https://github.com/fecgov/openFEC/pull/2191) ([anthonygarvan](https://github.com/anthonygarvan))
- Implement amendment filter for reports [\#2187](https://github.com/fecgov/openFEC/pull/2187) ([jontours](https://github.com/jontours))
- Feature/more explicit schemas [\#2185](https://github.com/fecgov/openFEC/pull/2185) ([vrajmohan](https://github.com/vrajmohan))
- Use process health check [\#2184](https://github.com/fecgov/openFEC/pull/2184) ([jmcarp](https://github.com/jmcarp))
- Adds support to sort by date for entity charts [\#2181](https://github.com/fecgov/openFEC/pull/2181) ([ccostino](https://github.com/ccostino))
- Added email endpoint [\#2168](https://github.com/fecgov/openFEC/pull/2168) ([patphongs](https://github.com/patphongs))

## [analyst-title](https://github.com/fecgov/openFEC/tree/analyst-title) (2017-02-10)

[Full Changelog](https://github.com/fecgov/openFEC/compare/move-party-schema...analyst-title)

**Merged pull requests:**

- Added analyst title [\#2206](https://github.com/fecgov/openFEC/pull/2206) ([patphongs](https://github.com/patphongs))

## [move-party-schema](https://github.com/fecgov/openFEC/tree/move-party-schema) (2017-02-09)

[Full Changelog](https://github.com/fecgov/openFEC/compare/rad-analyst-email...move-party-schema)

**Closed issues:**

- Add email endpoint to rad-analyst section [\#2151](https://github.com/fecgov/openFEC/issues/2151)

**Merged pull requests:**

- Hotfix/move party schema [\#2202](https://github.com/fecgov/openFEC/pull/2202) ([LindsayYoung](https://github.com/LindsayYoung))

## [rad-analyst-email](https://github.com/fecgov/openFEC/tree/rad-analyst-email) (2017-02-06)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-beta-20170202...rad-analyst-email)

**Merged pull requests:**

- \[MERGE WITH GIT FLOW\] Hotfix/rad analyst email [\#2190](https://github.com/fecgov/openFEC/pull/2190) ([ccostino](https://github.com/ccostino))

## [public-beta-20170202](https://github.com/fecgov/openFEC/tree/public-beta-20170202) (2017-02-02)

[Full Changelog](https://github.com/fecgov/openFEC/compare/rfai-fix...public-beta-20170202)

**Fixed bugs:**

- Remove fec\_url property from RFAI responses [\#2094](https://github.com/fecgov/openFEC/issues/2094)

**Closed issues:**

- Figure out how to get plain language summaries for AOs [\#2163](https://github.com/fecgov/openFEC/issues/2163)
- Simplify Elasticsearch document schema [\#2160](https://github.com/fecgov/openFEC/issues/2160)
- Incorrect amendment status data [\#2158](https://github.com/fecgov/openFEC/issues/2158)
- Add version status and amendment chain fields to efilng endpoints [\#2147](https://github.com/fecgov/openFEC/issues/2147)
- Add AO citations to AO page [\#2124](https://github.com/fecgov/openFEC/issues/2124)
- Add date sort to charts [\#2122](https://github.com/fecgov/openFEC/issues/2122)
- look at update script [\#1573](https://github.com/fecgov/openFEC/issues/1573)

**Merged pull requests:**

- Feature/add missing columns amendments [\#2182](https://github.com/fecgov/openFEC/pull/2182) ([jontours](https://github.com/jontours))
- Release/public beta 20170202 [\#2179](https://github.com/fecgov/openFEC/pull/2179) ([vrajmohan](https://github.com/vrajmohan))
- Link amendment chain to efilings [\#2178](https://github.com/fecgov/openFEC/pull/2178) ([jontours](https://github.com/jontours))
- adding ao name to citations [\#2177](https://github.com/fecgov/openFEC/pull/2177) ([anthonygarvan](https://github.com/anthonygarvan))
- Remove fec\_url from rfai\_filings [\#2176](https://github.com/fecgov/openFEC/pull/2176) ([jontours](https://github.com/jontours))
- Feature/simplify es schema [\#2172](https://github.com/fecgov/openFEC/pull/2172) ([vrajmohan](https://github.com/vrajmohan))
- Feature/make schema explicit [\#2171](https://github.com/fecgov/openFEC/pull/2171) ([vrajmohan](https://github.com/vrajmohan))
- Revert "Merge branch 'release/public-beta-20170118' into develop" [\#2169](https://github.com/fecgov/openFEC/pull/2169) ([vrajmohan](https://github.com/vrajmohan))
- Feature/adr [\#2166](https://github.com/fecgov/openFEC/pull/2166) ([rjayasekera](https://github.com/rjayasekera))
- Amendment chain improvement [\#2165](https://github.com/fecgov/openFEC/pull/2165) ([jontours](https://github.com/jontours))

## [rfai-fix](https://github.com/fecgov/openFEC/tree/rfai-fix) (2017-01-23)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-beta-20170118...rfai-fix)

**Fixed bugs:**

- disbursement committee total off  [\#2162](https://github.com/fecgov/openFEC/issues/2162)

**Merged pull requests:**

- Filter out records marked for deletion \[MERGE W/ GITFLOW\] [\#2174](https://github.com/fecgov/openFEC/pull/2174) ([jontours](https://github.com/jontours))

## [public-beta-20170118](https://github.com/fecgov/openFEC/tree/public-beta-20170118) (2017-01-19)

[Full Changelog](https://github.com/fecgov/openFEC/compare/release0119...public-beta-20170118)

## [release0119](https://github.com/fecgov/openFEC/tree/release0119) (2017-01-19)

[Full Changelog](https://github.com/fecgov/openFEC/compare/add-new-itemized-cycle-tables...release0119)

**Fixed bugs:**

- Add missing 2017 - 2018 cycle tables for schedule A and B [\#2136](https://github.com/fecgov/openFEC/issues/2136)
- Committee endpoint issue [\#2129](https://github.com/fecgov/openFEC/issues/2129)

**Closed issues:**

- Fix efiling filter bugs [\#2157](https://github.com/fecgov/openFEC/issues/2157)
- /schedule\_e/efile/ filters and fields [\#2135](https://github.com/fecgov/openFEC/issues/2135)
- Make sure Jean still has scripts to refresh legal data from Oracle [\#2133](https://github.com/fecgov/openFEC/issues/2133)
- triple check we are off data warehouse [\#2102](https://github.com/fecgov/openFEC/issues/2102)
- Create endpoint for raw schedule B data [\#2101](https://github.com/fecgov/openFEC/issues/2101)
- Create endpoint for raw schedule A data [\#2100](https://github.com/fecgov/openFEC/issues/2100)
- Add additional API fields for MURs [\#2099](https://github.com/fecgov/openFEC/issues/2099)
- Move some tables from public schema to other schemas [\#2097](https://github.com/fecgov/openFEC/issues/2097)
- Add API support for additional AO filters [\#2057](https://github.com/fecgov/openFEC/issues/2057)
- DW migration [\#1865](https://github.com/fecgov/openFEC/issues/1865)

**Merged pull requests:**

- merge with git-flow Release/public beta 20170118 [\#2167](https://github.com/fecgov/openFEC/pull/2167) ([anthonygarvan](https://github.com/anthonygarvan))
- Argument changed back to right key [\#2159](https://github.com/fecgov/openFEC/pull/2159) ([jontours](https://github.com/jontours))
- Bugfix/remove stale doc initializer [\#2156](https://github.com/fecgov/openFEC/pull/2156) ([anthonygarvan](https://github.com/anthonygarvan))
- Feature/add ao citations [\#2152](https://github.com/fecgov/openFEC/pull/2152) ([anthonygarvan](https://github.com/anthonygarvan))
- Adding explanations to management commands [\#2149](https://github.com/fecgov/openFEC/pull/2149) ([LindsayYoung](https://github.com/LindsayYoung))
- Add more docstrings for management commands [\#2148](https://github.com/fecgov/openFEC/pull/2148) ([vrajmohan](https://github.com/vrajmohan))
- getting off data warehouse [\#2146](https://github.com/fecgov/openFEC/pull/2146) ([LindsayYoung](https://github.com/LindsayYoung))
- Feature/search final disposition [\#2145](https://github.com/fecgov/openFEC/pull/2145) ([vrajmohan](https://github.com/vrajmohan))
- Schedule b efile endpoint [\#2144](https://github.com/fecgov/openFEC/pull/2144) ([jontours](https://github.com/jontours))
- Feature/raw sked a endpoint [\#2143](https://github.com/fecgov/openFEC/pull/2143) ([jontours](https://github.com/jontours))
- Update New Relic config [\#2142](https://github.com/fecgov/openFEC/pull/2142) ([ccostino](https://github.com/ccostino))
- Feature/search respondents [\#2141](https://github.com/fecgov/openFEC/pull/2141) ([vrajmohan](https://github.com/vrajmohan))
- Feature/add additional ao fields [\#2127](https://github.com/fecgov/openFEC/pull/2127) ([anthonygarvan](https://github.com/anthonygarvan))

## [add-new-itemized-cycle-tables](https://github.com/fecgov/openFEC/tree/add-new-itemized-cycle-tables) (2017-01-11)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-beta-20170104...add-new-itemized-cycle-tables)

**Fixed bugs:**

- \[MERGE WITH GIT FLOW\] Adds support for generating new itemized child tables [\#2139](https://github.com/fecgov/openFEC/pull/2139) ([ccostino](https://github.com/ccostino))

**Closed issues:**

- Document API views and models [\#2112](https://github.com/fecgov/openFEC/issues/2112)
- Allow search for legal documents by both old and new citations \(across reclassifications\) [\#2048](https://github.com/fecgov/openFEC/issues/2048)

## [public-beta-20170104](https://github.com/fecgov/openFEC/tree/public-beta-20170104) (2017-01-04)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-beta-20161221...public-beta-20170104)

**Fixed bugs:**

- add schemas in models [\#2116](https://github.com/fecgov/openFEC/issues/2116)

**Closed issues:**

- Separate out different document types within MURs [\#2071](https://github.com/fecgov/openFEC/issues/2071)
- Create endpoint for raw schedule E data [\#2067](https://github.com/fecgov/openFEC/issues/2067)
- update view names [\#2042](https://github.com/fecgov/openFEC/issues/2042)
- pg\_restore inflating db size [\#2007](https://github.com/fecgov/openFEC/issues/2007)

**Merged pull requests:**

- added kwargs for contribution period [\#2137](https://github.com/fecgov/openFEC/pull/2137) ([jontours](https://github.com/jontours))
- \[MERGE WITH GIT FLOW\] Release/public beta 20170104 [\#2131](https://github.com/fecgov/openFEC/pull/2131) ([ccostino](https://github.com/ccostino))
- Feature/raw sked e endpoint [\#2128](https://github.com/fecgov/openFEC/pull/2128) ([jontours](https://github.com/jontours))
- Feature/separate text by document type [\#2120](https://github.com/fecgov/openFEC/pull/2120) ([vrajmohan](https://github.com/vrajmohan))
- Add docstrings for management commands [\#2118](https://github.com/fecgov/openFEC/pull/2118) ([vrajmohan](https://github.com/vrajmohan))
- Add commands to support index alias management [\#2115](https://github.com/fecgov/openFEC/pull/2115) ([vrajmohan](https://github.com/vrajmohan))
- Feature/add amended flags [\#2113](https://github.com/fecgov/openFEC/pull/2113) ([jontours](https://github.com/jontours))
- Store and index election\_cycles for MURs [\#2109](https://github.com/fecgov/openFEC/pull/2109) ([vrajmohan](https://github.com/vrajmohan))
- Protect against missing index [\#2108](https://github.com/fecgov/openFEC/pull/2108) ([vrajmohan](https://github.com/vrajmohan))
- Faker library added [\#2107](https://github.com/fecgov/openFEC/pull/2107) ([jontours](https://github.com/jontours))

## [public-beta-20161221](https://github.com/fecgov/openFEC/tree/public-beta-20161221) (2016-12-22)

[Full Changelog](https://github.com/fecgov/openFEC/compare/fix-faker...public-beta-20161221)

**Fixed bugs:**

- Committee search failing on production [\#2088](https://github.com/fecgov/openFEC/issues/2088)
- Fix party committee data on overview charts [\#2079](https://github.com/fecgov/openFEC/issues/2079)

**Closed issues:**

- Move s3 buckets to the new cloud.gov [\#2031](https://github.com/fecgov/openFEC/issues/2031)
- Generate API exception for itemized endpoints [\#1978](https://github.com/fecgov/openFEC/issues/1978)

**Merged pull requests:**

- Feature/use views staging prod [\#2111](https://github.com/fecgov/openFEC/pull/2111) ([LindsayYoung](https://github.com/LindsayYoung))
- Feature/fix indexes for amendments [\#2110](https://github.com/fecgov/openFEC/pull/2110) ([jontours](https://github.com/jontours))
- misspelling causing chart error [\#2106](https://github.com/fecgov/openFEC/pull/2106) ([LindsayYoung](https://github.com/LindsayYoung))
- \[MERGE WITH GIT FLOW\] Release/public beta 20161221 [\#2104](https://github.com/fecgov/openFEC/pull/2104) ([ccostino](https://github.com/ccostino))
- Feature/map nulls [\#2103](https://github.com/fecgov/openFEC/pull/2103) ([LindsayYoung](https://github.com/LindsayYoung))
- Feature/use index aliases [\#2098](https://github.com/fecgov/openFEC/pull/2098) ([vrajmohan](https://github.com/vrajmohan))
- Build amendment chain, and link to filings resources [\#2093](https://github.com/fecgov/openFEC/pull/2093) ([jontours](https://github.com/jontours))
- Feature/add ao advanced search api [\#2091](https://github.com/fecgov/openFEC/pull/2091) ([anthonygarvan](https://github.com/anthonygarvan))
- Enable stemming when creating index [\#2081](https://github.com/fecgov/openFEC/pull/2081) ([vrajmohan](https://github.com/vrajmohan))
- Feature/delete aos from es [\#2078](https://github.com/fecgov/openFEC/pull/2078) ([vrajmohan](https://github.com/vrajmohan))
- \[DON'T MERGE\] Feature/db rename [\#2052](https://github.com/fecgov/openFEC/pull/2052) ([LindsayYoung](https://github.com/LindsayYoung))

## [fix-faker](https://github.com/fecgov/openFEC/tree/fix-faker) (2016-12-16)

[Full Changelog](https://github.com/fecgov/openFEC/compare/remove-expire-date...fix-faker)

## [remove-expire-date](https://github.com/fecgov/openFEC/tree/remove-expire-date) (2016-12-16)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-beta-20161207...remove-expire-date)

**Fixed bugs:**

- Some penalties missing from canonical MUR page when there are multiple penalties for the same disposition [\#2092](https://github.com/fecgov/openFEC/issues/2092)

**Closed issues:**

- schedule\_e pagination missing last\_expenditure\_amount after a certain amount [\#2096](https://github.com/fecgov/openFEC/issues/2096)
- Link electronic filings to their most recent amendment; if they are amended. [\#2073](https://github.com/fecgov/openFEC/issues/2073)
- Create endpoint for raw schedule B data [\#2066](https://github.com/fecgov/openFEC/issues/2066)
- Create endpoint for raw schedule A data [\#2065](https://github.com/fecgov/openFEC/issues/2065)
- Identify which filters and sorting options to include for raw efile data [\#2064](https://github.com/fecgov/openFEC/issues/2064)
- Add API support for initial AO filters [\#2056](https://github.com/fecgov/openFEC/issues/2056)

**Merged pull requests:**

- Hotfix/remove expire date [\#2105](https://github.com/fecgov/openFEC/pull/2105) ([jontours](https://github.com/jontours))
- Casting null to date so distinct can work right \[merge w/ git flow\] [\#2089](https://github.com/fecgov/openFEC/pull/2089) ([jontours](https://github.com/jontours))

## [public-beta-20161207](https://github.com/fecgov/openFEC/tree/public-beta-20161207) (2016-12-07)

[Full Changelog](https://github.com/fecgov/openFEC/compare/cli-upgrade...public-beta-20161207)

**Fixed bugs:**

- Make robust sorting test [\#2025](https://github.com/fecgov/openFEC/issues/2025)

**Closed issues:**

- Enable 0 downtime changes to Elasticsearch indices [\#2086](https://github.com/fecgov/openFEC/issues/2086)
- New filings endpoint missing receipt\_date [\#2080](https://github.com/fecgov/openFEC/issues/2080)
- Enable stemming on searches for AOs [\#2074](https://github.com/fecgov/openFEC/issues/2074)
- Remove archived MURs from Elasticsearch so that current MURs can be released [\#2053](https://github.com/fecgov/openFEC/issues/2053)
- Migrate off dimparty [\#2051](https://github.com/fecgov/openFEC/issues/2051)
- Migrate off dimreporttype [\#2050](https://github.com/fecgov/openFEC/issues/2050)
- Migrate off dimcmteproperties [\#2049](https://github.com/fecgov/openFEC/issues/2049)

**Merged pull requests:**

- Add RFAI filings to filings resource [\#2087](https://github.com/fecgov/openFEC/pull/2087) ([jontours](https://github.com/jontours))
- Casting columns to text, and then to dates [\#2083](https://github.com/fecgov/openFEC/pull/2083) ([jontours](https://github.com/jontours))
- \[MERGE WITH GITFLOW\] Release/public beta 20161207 [\#2077](https://github.com/fecgov/openFEC/pull/2077) ([LindsayYoung](https://github.com/LindsayYoung))
- Bump cf-cli version [\#2076](https://github.com/fecgov/openFEC/pull/2076) ([vrajmohan](https://github.com/vrajmohan))
- Simplify citation text and links [\#2075](https://github.com/fecgov/openFEC/pull/2075) ([vrajmohan](https://github.com/vrajmohan))
- Feature/fix statutory citation titles [\#2062](https://github.com/fecgov/openFEC/pull/2062) ([vrajmohan](https://github.com/vrajmohan))
- Feature/rad id [\#2060](https://github.com/fecgov/openFEC/pull/2060) ([LindsayYoung](https://github.com/LindsayYoung))
- Migrating filings off data warehouse [\#2054](https://github.com/fecgov/openFEC/pull/2054) ([jontours](https://github.com/jontours))
- open control yaml  [\#2037](https://github.com/fecgov/openFEC/pull/2037) ([LindsayYoung](https://github.com/LindsayYoung))
- Adding some efiling tests [\#2034](https://github.com/fecgov/openFEC/pull/2034) ([LindsayYoung](https://github.com/LindsayYoung))
- Pagination with null sort columns [\#2029](https://github.com/fecgov/openFEC/pull/2029) ([jontours](https://github.com/jontours))

## [cli-upgrade](https://github.com/fecgov/openFEC/tree/cli-upgrade) (2016-12-01)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-beta-20161123...cli-upgrade)

**Fixed bugs:**

- Statutory citations with elided sections are loaded incorrectly [\#2069](https://github.com/fecgov/openFEC/issues/2069)

**Closed issues:**

- Statutory citations have incorrect citation titles [\#2068](https://github.com/fecgov/openFEC/issues/2068)
- Create new cloud.gov org [\#2030](https://github.com/fecgov/openFEC/issues/2030)
- make efiling filing tests [\#1880](https://github.com/fecgov/openFEC/issues/1880)

## [public-beta-20161123](https://github.com/fecgov/openFEC/tree/public-beta-20161123) (2016-11-23)

[Full Changelog](https://github.com/fecgov/openFEC/compare/remove-ethnio...public-beta-20161123)

**Closed issues:**

- Create strategy for migrating to gov cloud [\#2047](https://github.com/fecgov/openFEC/issues/2047)
- double check sched a records are up to date [\#2045](https://github.com/fecgov/openFEC/issues/2045)
- ATO renewal process [\#1993](https://github.com/fecgov/openFEC/issues/1993)

**Merged pull requests:**

- \[MERGE WITH GITFLOW\] Release/public beta 20161123 [\#2059](https://github.com/fecgov/openFEC/pull/2059) ([LindsayYoung](https://github.com/LindsayYoung))
- updating ssp [\#2043](https://github.com/fecgov/openFEC/pull/2043) ([LindsayYoung](https://github.com/LindsayYoung))
- SSP [\#2041](https://github.com/fecgov/openFEC/pull/2041) ([LindsayYoung](https://github.com/LindsayYoung))
- Feature/better citation text [\#2035](https://github.com/fecgov/openFEC/pull/2035) ([vrajmohan](https://github.com/vrajmohan))

## [remove-ethnio](https://github.com/fecgov/openFEC/tree/remove-ethnio) (2016-11-18)

[Full Changelog](https://github.com/fecgov/openFEC/compare/efile-fix...remove-ethnio)

**Closed issues:**

- Create commissioner briefing presentation [\#2021](https://github.com/fecgov/openFEC/issues/2021)
- Create agenda for PI planning [\#2020](https://github.com/fecgov/openFEC/issues/2020)
- Finalize team structure for PI planning [\#2019](https://github.com/fecgov/openFEC/issues/2019)
- Groom product feature backlog [\#2018](https://github.com/fecgov/openFEC/issues/2018)

**Merged pull requests:**

- Hotfix/remove ethnio [\#2044](https://github.com/fecgov/openFEC/pull/2044) ([LindsayYoung](https://github.com/LindsayYoung))

## [efile-fix](https://github.com/fecgov/openFEC/tree/efile-fix) (2016-11-14)

[Full Changelog](https://github.com/fecgov/openFEC/compare/fix-travis-credentials...efile-fix)

**Merged pull requests:**

- \[MERGE WITH GITFLOW\] removed FEC url form model. I think it conflicted with the mixin [\#2040](https://github.com/fecgov/openFEC/pull/2040) ([LindsayYoung](https://github.com/LindsayYoung))

## [fix-travis-credentials](https://github.com/fecgov/openFEC/tree/fix-travis-credentials) (2016-11-14)

[Full Changelog](https://github.com/fecgov/openFEC/compare/update-travis-vars...fix-travis-credentials)

**Merged pull requests:**

- \[MERGE WITH GIT FLOW\]: Fix Travis CI credentials [\#2039](https://github.com/fecgov/openFEC/pull/2039) ([ccostino](https://github.com/ccostino))

## [update-travis-vars](https://github.com/fecgov/openFEC/tree/update-travis-vars) (2016-11-10)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-beta-20161109...update-travis-vars)

**Fixed bugs:**

- Added support to sort by the total column [\#2036](https://github.com/fecgov/openFEC/pull/2036) ([ccostino](https://github.com/ccostino))

**Closed issues:**

- Indicator that a filing is paper-only, not electronic [\#1824](https://github.com/fecgov/openFEC/issues/1824)

**Merged pull requests:**

- \[MERGE WITH GITFLOW\] Release/public beta 20161109 [\#2027](https://github.com/fecgov/openFEC/pull/2027) ([LindsayYoung](https://github.com/LindsayYoung))
- Summary endpoint for individual contribution totals [\#2013](https://github.com/fecgov/openFEC/pull/2013) ([ccostino](https://github.com/ccostino))
- Relax candidate table construction [\#2012](https://github.com/fecgov/openFEC/pull/2012) ([jontours](https://github.com/jontours))
- Add means\_filed to reports and filings endpoints [\#2001](https://github.com/fecgov/openFEC/pull/2001) ([jontours](https://github.com/jontours))

## [public-beta-20161109](https://github.com/fecgov/openFEC/tree/public-beta-20161109) (2016-11-09)

[Full Changelog](https://github.com/fecgov/openFEC/compare/fix-large-chart-data...public-beta-20161109)

**Fixed bugs:**

- Incomplete info and duplicates for schedule E [\#2022](https://github.com/fecgov/openFEC/issues/2022)

**Closed issues:**

- Set X-Frame-Options Header [\#2033](https://github.com/fecgov/openFEC/issues/2033)
- Disclosure schema missing from dev database [\#2008](https://github.com/fecgov/openFEC/issues/2008)
- Verify entity totals data [\#1991](https://github.com/fecgov/openFEC/issues/1991)
- Move to Golden Gate tables [\#1957](https://github.com/fecgov/openFEC/issues/1957)
- Create base pages for fundraising and spending overviews [\#1680](https://github.com/fecgov/openFEC/issues/1680)

**Merged pull requests:**

- prevent accidents  [\#2023](https://github.com/fecgov/openFEC/pull/2023) ([LindsayYoung](https://github.com/LindsayYoung))
- adding enable\_stemming function [\#2016](https://github.com/fecgov/openFEC/pull/2016) ([anthonygarvan](https://github.com/anthonygarvan))
- Capitalizes president [\#2015](https://github.com/fecgov/openFEC/pull/2015) ([emileighoutlaw](https://github.com/emileighoutlaw))

## [fix-large-chart-data](https://github.com/fecgov/openFEC/tree/fix-large-chart-data) (2016-11-03)

[Full Changelog](https://github.com/fecgov/openFEC/compare/fix-keyset-pagination...fix-large-chart-data)

**Merged pull requests:**

- Working on making the charts better [\#2014](https://github.com/fecgov/openFEC/pull/2014) ([LindsayYoung](https://github.com/LindsayYoung))

## [fix-keyset-pagination](https://github.com/fecgov/openFEC/tree/fix-keyset-pagination) (2016-11-03)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-beta-20161026...fix-keyset-pagination)

**Fixed bugs:**

- Celery error on nightly refresh [\#2002](https://github.com/fecgov/openFEC/issues/2002)

**Merged pull requests:**

- Keyset pagination fix [\#2024](https://github.com/fecgov/openFEC/pull/2024) ([jontours](https://github.com/jontours))

## [public-beta-20161026](https://github.com/fecgov/openFEC/tree/public-beta-20161026) (2016-10-26)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-beta-20161012...public-beta-20161026)

**Fixed bugs:**

- Issues with paging through nulls [\#1960](https://github.com/fecgov/openFEC/issues/1960)
- Discrepancies in Schedule E \(missing committees and expenditures\) [\#1927](https://github.com/fecgov/openFEC/issues/1927)

**Closed issues:**

- Report endpoint fails to filter on committee\_type [\#1985](https://github.com/fecgov/openFEC/issues/1985)
- Please check: Duplicate event entry on calendar [\#1983](https://github.com/fecgov/openFEC/issues/1983)
- Add URL to CSV on filings and reports endpoints [\#1954](https://github.com/fecgov/openFEC/issues/1954)
- Create API endpoint to serve overview data  [\#1953](https://github.com/fecgov/openFEC/issues/1953)
- find additional efiling summary data [\#1924](https://github.com/fecgov/openFEC/issues/1924)
- Provide link to .fec file on filings [\#1882](https://github.com/fecgov/openFEC/issues/1882)
- Add mirrors to production [\#1415](https://github.com/fecgov/openFEC/issues/1415)

**Merged pull requests:**

- Stopping mur update for now [\#2005](https://github.com/fecgov/openFEC/pull/2005) ([LindsayYoung](https://github.com/LindsayYoung))
- Removing reference to disclosure schema [\#2003](https://github.com/fecgov/openFEC/pull/2003) ([jontours](https://github.com/jontours))
- Removes amended records [\#1995](https://github.com/fecgov/openFEC/pull/1995) ([LindsayYoung](https://github.com/LindsayYoung))
- Feature/disclosure transition [\#1994](https://github.com/fecgov/openFEC/pull/1994) ([jontours](https://github.com/jontours))
- \[MERGE WITH GIT FLOW\] Release/public beta 20161026 [\#1992](https://github.com/fecgov/openFEC/pull/1992) ([ccostino](https://github.com/ccostino))
- showing cumulative  [\#1990](https://github.com/fecgov/openFEC/pull/1990) ([LindsayYoung](https://github.com/LindsayYoung))
- Improved sorting and paging for itemized resources in the API [\#1989](https://github.com/fecgov/openFEC/pull/1989) ([ccostino](https://github.com/ccostino))
- Commenting out field from schema [\#1988](https://github.com/fecgov/openFEC/pull/1988) ([jontours](https://github.com/jontours))
- Feature/implement fec urls [\#1986](https://github.com/fecgov/openFEC/pull/1986) ([jontours](https://github.com/jontours))
- adding elastic search instructions to readme [\#1984](https://github.com/fecgov/openFEC/pull/1984) ([anthonygarvan](https://github.com/anthonygarvan))
- fixing refs, removing reg sync and adding mur sync [\#1982](https://github.com/fecgov/openFEC/pull/1982) ([anthonygarvan](https://github.com/anthonygarvan))
- Feature/search final opinion only [\#1981](https://github.com/fecgov/openFEC/pull/1981) ([anthonygarvan](https://github.com/anthonygarvan))
- Added coverage start and end date to candidate totals materialized view [\#1979](https://github.com/fecgov/openFEC/pull/1979) ([jontours](https://github.com/jontours))
- Feature/add csv links [\#1977](https://github.com/fecgov/openFEC/pull/1977) ([jontours](https://github.com/jontours))
- Chart endpoint API [\#1964](https://github.com/fecgov/openFEC/pull/1964) ([xtine](https://github.com/xtine))
- Map archived citations to current statutes [\#1961](https://github.com/fecgov/openFEC/pull/1961) ([adborden](https://github.com/adborden))

## [public-beta-20161012](https://github.com/fecgov/openFEC/tree/public-beta-20161012) (2016-10-12)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-beta-20161007...public-beta-20161012)

**Fixed bugs:**

- High priority: Schedule E data behind on production [\#1811](https://github.com/fecgov/openFEC/issues/1811)

**Closed issues:**

- OpenFEC API Misspelling [\#1974](https://github.com/fecgov/openFEC/issues/1974)
- Keyset pagination breaking pagination. [\#1958](https://github.com/fecgov/openFEC/issues/1958)
- Identify process for moving from synthesis to wiki [\#1785](https://github.com/fecgov/openFEC/issues/1785)

**Merged pull requests:**

- Add committee names to itemized aggregate exports [\#1976](https://github.com/fecgov/openFEC/pull/1976) ([ccostino](https://github.com/ccostino))
- fix pary to party [\#1975](https://github.com/fecgov/openFEC/pull/1975) ([LindsayYoung](https://github.com/LindsayYoung))
- \[MERGE WITH GITFLOW\] Release/public beta 20161012 [\#1972](https://github.com/fecgov/openFEC/pull/1972) ([anthonygarvan](https://github.com/anthonygarvan))
- Feature/add disposition to current murs [\#1971](https://github.com/fecgov/openFEC/pull/1971) ([anthonygarvan](https://github.com/anthonygarvan))
- Bug/fix load archived murs tests [\#1969](https://github.com/fecgov/openFEC/pull/1969) ([vrajmohan](https://github.com/vrajmohan))
- Feature/link reg citations to eregs [\#1965](https://github.com/fecgov/openFEC/pull/1965) ([vrajmohan](https://github.com/vrajmohan))
- feature/add-disposition-to-current-murs [\#1959](https://github.com/fecgov/openFEC/pull/1959) ([anthonygarvan](https://github.com/anthonygarvan))

## [public-beta-20161007](https://github.com/fecgov/openFEC/tree/public-beta-20161007) (2016-10-07)

[Full Changelog](https://github.com/fecgov/openFEC/compare/tests-fix...public-beta-20161007)

**Fixed bugs:**

- Investigate number of processes and connections to the DBs [\#1920](https://github.com/fecgov/openFEC/issues/1920)
- Fix Travis CI setup for pip [\#1966](https://github.com/fecgov/openFEC/pull/1966) ([ccostino](https://github.com/ccostino))

**Closed issues:**

- Formatting goes wonky when toggling between candidate and committee profile search [\#1955](https://github.com/fecgov/openFEC/issues/1955)
- Internal server error on production for sched\_c [\#1950](https://github.com/fecgov/openFEC/issues/1950)
- Enable exports/downloads for itemized schedule aggregate endpoints [\#1947](https://github.com/fecgov/openFEC/issues/1947)
- Include committee name in all schedule downloads [\#1940](https://github.com/fecgov/openFEC/issues/1940)
- Add downloads for new resources [\#1925](https://github.com/fecgov/openFEC/issues/1925)
- Add 24/48 hour IEs to itemized IEs [\#1910](https://github.com/fecgov/openFEC/issues/1910)
- Add form 5 independent expenditures to itemized IEs [\#1909](https://github.com/fecgov/openFEC/issues/1909)
- Schedule E is off data warehouse tables [\#1700](https://github.com/fecgov/openFEC/issues/1700)

**Merged pull requests:**

- \[MERGE WITH GITFLOW\] Release/public beta 20161007 [\#1970](https://github.com/fecgov/openFEC/pull/1970) ([LindsayYoung](https://github.com/LindsayYoung))
- Removed efile\_parser and all references to it. [\#1968](https://github.com/fecgov/openFEC/pull/1968) ([jontours](https://github.com/jontours))
- \[MERGE W/ GITFLOW\] Added year to test model [\#1963](https://github.com/fecgov/openFEC/pull/1963) ([jontours](https://github.com/jontours))
- Adds support for exporting more itemized schedule endpoints [\#1956](https://github.com/fecgov/openFEC/pull/1956) ([ccostino](https://github.com/ccostino))
- Feature/make efile parsing task [\#1943](https://github.com/fecgov/openFEC/pull/1943) ([jontours](https://github.com/jontours))
- Enable search for candidate\_name and loaner\_name [\#1939](https://github.com/fecgov/openFEC/pull/1939) ([jontours](https://github.com/jontours))
- Feature/sched e transition [\#1730](https://github.com/fecgov/openFEC/pull/1730) ([jontours](https://github.com/jontours))

## [tests-fix](https://github.com/fecgov/openFEC/tree/tests-fix) (2016-09-28)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-beta-20160928...tests-fix)

## [public-beta-20160928](https://github.com/fecgov/openFEC/tree/public-beta-20160928) (2016-09-28)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-beta-20160914...public-beta-20160928)

**Fixed bugs:**

- Adds committee names back into itemized schedule downloads [\#1951](https://github.com/fecgov/openFEC/pull/1951) ([ccostino](https://github.com/ccostino))

**Closed issues:**

- Add itemized debts \(schedule D\) data [\#1913](https://github.com/fecgov/openFEC/issues/1913)
- Improve instructions for usability testing rig [\#1794](https://github.com/fecgov/openFEC/issues/1794)

**Merged pull requests:**

- \[MERGE WITH GIT FLOW\] Release/public beta 20160928 [\#1952](https://github.com/fecgov/openFEC/pull/1952) ([adborden](https://github.com/adborden))
- Feature/add mur no endpoint [\#1948](https://github.com/fecgov/openFEC/pull/1948) ([anthonygarvan](https://github.com/anthonygarvan))
- Feature/enable additional downloads [\#1945](https://github.com/fecgov/openFEC/pull/1945) ([ccostino](https://github.com/ccostino))
- Feature/load current MURs [\#1944](https://github.com/fecgov/openFEC/pull/1944) ([vrajmohan](https://github.com/vrajmohan))
- Changing rate limit docs [\#1942](https://github.com/fecgov/openFEC/pull/1942) ([noahmanger](https://github.com/noahmanger))
- Fix py.test warning [\#1941](https://github.com/fecgov/openFEC/pull/1941) ([vrajmohan](https://github.com/vrajmohan))
- sched\_d endpoint \(debts\) [\#1938](https://github.com/fecgov/openFEC/pull/1938) ([jontours](https://github.com/jontours))
- Modify mirror support to redirect all read traffic to followers [\#1929](https://github.com/fecgov/openFEC/pull/1929) ([ccostino](https://github.com/ccostino))

## [public-beta-20160914](https://github.com/fecgov/openFEC/tree/public-beta-20160914) (2016-09-14)

[Full Changelog](https://github.com/fecgov/openFEC/compare/legal-no...public-beta-20160914)

**Fixed bugs:**

- Key Phrase Search - Fix Highlighting [\#1916](https://github.com/fecgov/openFEC/issues/1916)
- /candidates/ not filtering by cycle [\#1886](https://github.com/fecgov/openFEC/issues/1886)
- DB updates [\#1868](https://github.com/fecgov/openFEC/issues/1868)
- cash on hand nulls [\#1850](https://github.com/fecgov/openFEC/issues/1850)

**Closed issues:**

- Clarify incomplete-ness of data [\#1933](https://github.com/fecgov/openFEC/issues/1933)
- update limits to API documention [\#1926](https://github.com/fecgov/openFEC/issues/1926)
- Decide on approach for CSV downloads [\#1914](https://github.com/fecgov/openFEC/issues/1914)
- Add itemized party coordinated expenditures \(schedule F\) data [\#1912](https://github.com/fecgov/openFEC/issues/1912)
- Add itemized loans \(schedule C\) transactions [\#1911](https://github.com/fecgov/openFEC/issues/1911)
- August 31 Release Checklist [\#1901](https://github.com/fecgov/openFEC/issues/1901)
- Upgrade Postgres in Amazon RDS [\#1897](https://github.com/fecgov/openFEC/issues/1897)
- Scrape press releases [\#1895](https://github.com/fecgov/openFEC/issues/1895)
- `Spender` not included in csv export of disbursement data [\#1894](https://github.com/fecgov/openFEC/issues/1894)
- Real Time Electronic Filing Tables [\#1583](https://github.com/fecgov/openFEC/issues/1583)
- find things for the micro-bid code auction [\#1418](https://github.com/fecgov/openFEC/issues/1418)
- Message on browse receipts and browse disbursements page [\#1288](https://github.com/fecgov/openFEC/issues/1288)

**Merged pull requests:**

- \[MERGE WITH GITFLOW\] Release/public beta 20160914 [\#1937](https://github.com/fecgov/openFEC/pull/1937) ([LindsayYoung](https://github.com/LindsayYoung))
- Adding trailing slash to sched c and f urls [\#1935](https://github.com/fecgov/openFEC/pull/1935) ([LindsayYoung](https://github.com/LindsayYoung))
- Fixes duplicate imports [\#1932](https://github.com/fecgov/openFEC/pull/1932) ([ccostino](https://github.com/ccostino))
- Remove duplicate code [\#1931](https://github.com/fecgov/openFEC/pull/1931) ([adborden](https://github.com/adborden))
- Schedule F \(party coordinated expenditures\) [\#1928](https://github.com/fecgov/openFEC/pull/1928) ([jontours](https://github.com/jontours))
- Feature/load archived murs [\#1918](https://github.com/fecgov/openFEC/pull/1918) ([anthonygarvan](https://github.com/anthonygarvan))
- Phrase search highlight fixes [\#1917](https://github.com/fecgov/openFEC/pull/1917) ([adborden](https://github.com/adborden))
- Schedule C endpoint [\#1915](https://github.com/fecgov/openFEC/pull/1915) ([jontours](https://github.com/jontours))

## [legal-no](https://github.com/fecgov/openFEC/tree/legal-no) (2016-09-08)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-beta-20160831...legal-no)

**Merged pull requests:**

- \[merge with git flow\] Hotfix: import all subparts from regulations [\#1930](https://github.com/fecgov/openFEC/pull/1930) ([adborden](https://github.com/adborden))

## [public-beta-20160831](https://github.com/fecgov/openFEC/tree/public-beta-20160831) (2016-09-01)

[Full Changelog](https://github.com/fecgov/openFEC/compare/sorting-error...public-beta-20160831)

**Fixed bugs:**

- Pandas not installed on CF [\#1902](https://github.com/fecgov/openFEC/issues/1902)

**Closed issues:**

- Migrate filings data off data warehouse [\#1908](https://github.com/fecgov/openFEC/issues/1908)
- Migrate Filings table off data warehouse [\#1907](https://github.com/fecgov/openFEC/issues/1907)
- Remaining work for efiling summary endpoint  [\#1905](https://github.com/fecgov/openFEC/issues/1905)
- Migrate NML\_FORM\_76 [\#1789](https://github.com/fecgov/openFEC/issues/1789)

**Merged pull requests:**

- update args [\#1923](https://github.com/fecgov/openFEC/pull/1923) ([LindsayYoung](https://github.com/LindsayYoung))
- Some column name corrections for efile summaries [\#1922](https://github.com/fecgov/openFEC/pull/1922) ([jontours](https://github.com/jontours))
- Sorting enabled for 'receipt\_date', 'committee\_id', and 'file\_number'. [\#1921](https://github.com/fecgov/openFEC/pull/1921) ([jontours](https://github.com/jontours))
- Added document\_description and pdf\_url to all efile reports summaries [\#1919](https://github.com/fecgov/openFEC/pull/1919) ([jontours](https://github.com/jontours))
- \[MERGE WITH GITFLOW\] Release/public beta 20160831 [\#1906](https://github.com/fecgov/openFEC/pull/1906) ([ccostino](https://github.com/ccostino))
- Bug fix/update requirements [\#1903](https://github.com/fecgov/openFEC/pull/1903) ([LindsayYoung](https://github.com/LindsayYoung))
- Fix transaction id in schedules and sort bug fixes [\#1900](https://github.com/fecgov/openFEC/pull/1900) ([LindsayYoung](https://github.com/LindsayYoung))
- Legal phrase search [\#1898](https://github.com/fecgov/openFEC/pull/1898) ([adborden](https://github.com/adborden))
- Update and pin new package versions [\#1896](https://github.com/fecgov/openFEC/pull/1896) ([ccostino](https://github.com/ccostino))
- Feature/additional reports endpoint work [\#1892](https://github.com/fecgov/openFEC/pull/1892) ([jontours](https://github.com/jontours))
- Feature/loading statutes [\#1891](https://github.com/fecgov/openFEC/pull/1891) ([anthonygarvan](https://github.com/anthonygarvan))
- Feature/efiling summary endpoint [\#1873](https://github.com/fecgov/openFEC/pull/1873) ([jontours](https://github.com/jontours))
- Improve nightly aggregate updates [\#1870](https://github.com/fecgov/openFEC/pull/1870) ([ccostino](https://github.com/ccostino))
- Feature/individual tweaks [\#1866](https://github.com/fecgov/openFEC/pull/1866) ([LindsayYoung](https://github.com/LindsayYoung))
- Takes unitemized totals out of state break downs [\#1858](https://github.com/fecgov/openFEC/pull/1858) ([LindsayYoung](https://github.com/LindsayYoung))
- Feature/election comms table migration [\#1812](https://github.com/fecgov/openFEC/pull/1812) ([jontours](https://github.com/jontours))

## [sorting-error](https://github.com/fecgov/openFEC/tree/sorting-error) (2016-08-26)

[Full Changelog](https://github.com/fecgov/openFEC/compare/ao-kwargs...sorting-error)

**Fixed bugs:**

- Error if sorting on a field if no results are present [\#1899](https://github.com/fecgov/openFEC/issues/1899)
- Schedule A Data Does Not Include Transaction ID [\#1878](https://github.com/fecgov/openFEC/issues/1878)
- Sanders DC totals don't match totals on fec.gov presidential map [\#1561](https://github.com/fecgov/openFEC/issues/1561)

**Closed issues:**

- Design specific tag UI for date ranges and financial ranges [\#1872](https://github.com/fecgov/openFEC/issues/1872)
- Create F3X efiling endpoint [\#1862](https://github.com/fecgov/openFEC/issues/1862)
- Create F3 efiling endpoint [\#1861](https://github.com/fecgov/openFEC/issues/1861)
- Implement F3P efiling endpoint  [\#1860](https://github.com/fecgov/openFEC/issues/1860)
- API changes to support /reports/ pages [\#1804](https://github.com/fecgov/openFEC/issues/1804)
- Update filings data table page [\#1791](https://github.com/fecgov/openFEC/issues/1791)
- Create reports data table pages [\#1790](https://github.com/fecgov/openFEC/issues/1790)
- Resolve individual vs. committee filtering issues [\#1779](https://github.com/fecgov/openFEC/issues/1779)
- Advanced data table filter panel mobile usability findings  [\#1726](https://github.com/fecgov/openFEC/issues/1726)
- Consider revisiting record count and pagination on advanced data tables [\#1685](https://github.com/fecgov/openFEC/issues/1685)

**Merged pull requests:**

- \[USE GITFLOW\]Hotfix/sorting error [\#1904](https://github.com/fecgov/openFEC/pull/1904) ([LindsayYoung](https://github.com/LindsayYoung))

## [ao-kwargs](https://github.com/fecgov/openFEC/tree/ao-kwargs) (2016-08-17)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-beta-20160817...ao-kwargs)

**Closed issues:**

- Make a new test dataset with efilings [\#1856](https://github.com/fecgov/openFEC/issues/1856)

**Merged pull requests:**

- \[MERGE WITH GIT FLOW\] Accept kwargs for AdvisoryOpinion [\#1893](https://github.com/fecgov/openFEC/pull/1893) ([adborden](https://github.com/adborden))

## [public-beta-20160817](https://github.com/fecgov/openFEC/tree/public-beta-20160817) (2016-08-17)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-beta-20160803...public-beta-20160817)

**Fixed bugs:**

- Consistently update schedule A and B data [\#1820](https://github.com/fecgov/openFEC/issues/1820)
- Taking out redundant schedule e update [\#1869](https://github.com/fecgov/openFEC/pull/1869) ([LindsayYoung](https://github.com/LindsayYoung))
- Replace missing delete statements [\#1849](https://github.com/fecgov/openFEC/pull/1849) ([ccostino](https://github.com/ccostino))
- Add support for renaming indexes [\#1846](https://github.com/fecgov/openFEC/pull/1846) ([ccostino](https://github.com/ccostino))

**Closed issues:**

- Add discription and pdf\_url to e-filings [\#1887](https://github.com/fecgov/openFEC/issues/1887)
- add indexes and validation for efiling [\#1885](https://github.com/fecgov/openFEC/issues/1885)
- Implement front-end for efiling view of filings [\#1881](https://github.com/fecgov/openFEC/issues/1881)
- Update Python [\#1877](https://github.com/fecgov/openFEC/issues/1877)
- Search for multiple cities [\#1867](https://github.com/fecgov/openFEC/issues/1867)
- Figure out how to make the join with efile summary  [\#1859](https://github.com/fecgov/openFEC/issues/1859)
- Test new data landing chart [\#1853](https://github.com/fecgov/openFEC/issues/1853)
- Add error message to filter error state [\#1852](https://github.com/fecgov/openFEC/issues/1852)
- Unify text input filter patterns [\#1828](https://github.com/fecgov/openFEC/issues/1828)
- Build assets on CI and drop buildpack-multi [\#1643](https://github.com/fecgov/openFEC/issues/1643)

**Merged pull requests:**

- Receipt date time [\#1890](https://github.com/fecgov/openFEC/pull/1890) ([noahmanger](https://github.com/noahmanger))
- Feature/add efile links [\#1889](https://github.com/fecgov/openFEC/pull/1889) ([LindsayYoung](https://github.com/LindsayYoung))
- returning all docs in ao [\#1888](https://github.com/fecgov/openFEC/pull/1888) ([anthonygarvan](https://github.com/anthonygarvan))
- Feature/efile files [\#1884](https://github.com/fecgov/openFEC/pull/1884) ([LindsayYoung](https://github.com/LindsayYoung))
- Address issue with celerybeat-schedule [\#1883](https://github.com/fecgov/openFEC/pull/1883) ([ccostino](https://github.com/ccostino))
- \[MERGE WITH GITFLOW\] Release/public beta 20160817 [\#1879](https://github.com/fecgov/openFEC/pull/1879) ([ccostino](https://github.com/ccostino))
- Bump python version for cloud foundry [\#1876](https://github.com/fecgov/openFEC/pull/1876) ([adborden](https://github.com/adborden))
- disabling prioritizing final opinion [\#1875](https://github.com/fecgov/openFEC/pull/1875) ([anthonygarvan](https://github.com/anthonygarvan))
- adding api for advisory opinion canonical page [\#1874](https://github.com/fecgov/openFEC/pull/1874) ([anthonygarvan](https://github.com/anthonygarvan))
- Reports endpoint modification \[WIP\] [\#1864](https://github.com/fecgov/openFEC/pull/1864) ([jontours](https://github.com/jontours))
- Feature/docs tips [\#1842](https://github.com/fecgov/openFEC/pull/1842) ([LindsayYoung](https://github.com/LindsayYoung))

## [public-beta-20160803](https://github.com/fecgov/openFEC/tree/public-beta-20160803) (2016-08-03)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-beta-20160720...public-beta-20160803)

**Fixed bugs:**

- Fix prod updates [\#1863](https://github.com/fecgov/openFEC/issues/1863)
- rename indexes [\#1840](https://github.com/fecgov/openFEC/issues/1840)
- fix schedule E check [\#1821](https://github.com/fecgov/openFEC/issues/1821)

**Closed issues:**

- switch table [\#1855](https://github.com/fecgov/openFEC/issues/1855)
- what tables aren't we using [\#1854](https://github.com/fecgov/openFEC/issues/1854)
- Release checklist: Sprint 18 [\#1818](https://github.com/fecgov/openFEC/issues/1818)
- Test expectations around overview interactions with static prototypes [\#1792](https://github.com/fecgov/openFEC/issues/1792)
- Refine mobile styles on data landing page [\#1743](https://github.com/fecgov/openFEC/issues/1743)
- FEC Reviews and verifies new data on dev [\#1701](https://github.com/fecgov/openFEC/issues/1701)

**Merged pull requests:**

- \[MERGE WITH GITFLOW\] Release/public beta 20160803 [\#1857](https://github.com/fecgov/openFEC/pull/1857) ([LindsayYoung](https://github.com/LindsayYoung))
- logging tweak [\#1848](https://github.com/fecgov/openFEC/pull/1848) ([anthonygarvan](https://github.com/anthonygarvan))
- Feature/load pdfs into s3 [\#1847](https://github.com/fecgov/openFEC/pull/1847) ([anthonygarvan](https://github.com/anthonygarvan))
- Feature/load legal docs in celery [\#1845](https://github.com/fecgov/openFEC/pull/1845) ([anthonygarvan](https://github.com/anthonygarvan))
- New tests for sorting [\#1836](https://github.com/fecgov/openFEC/pull/1836) ([jontours](https://github.com/jontours))
- Added candidate/totals to swagger docs [\#1830](https://github.com/fecgov/openFEC/pull/1830) ([jontours](https://github.com/jontours))
- Removed flask.ext imports [\#1829](https://github.com/fecgov/openFEC/pull/1829) ([jontours](https://github.com/jontours))
- Reorder updates [\#1827](https://github.com/fecgov/openFEC/pull/1827) ([LindsayYoung](https://github.com/LindsayYoung))
- prioritizing final opinion document category [\#1810](https://github.com/fecgov/openFEC/pull/1810) ([anthonygarvan](https://github.com/anthonygarvan))

## [public-beta-20160720](https://github.com/fecgov/openFEC/tree/public-beta-20160720) (2016-07-28)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-beta-20160707...public-beta-20160720)

**Fixed bugs:**

- Sort broken on /elections [\#1819](https://github.com/fecgov/openFEC/issues/1819)
- make aggragate tables as \_tmp [\#1775](https://github.com/fecgov/openFEC/issues/1775)
- The get schedule\_e doesn't appear to not be returning records for a payee\_name [\#1682](https://github.com/fecgov/openFEC/issues/1682)
- Getting rid of daily updates on feature  [\#1814](https://github.com/fecgov/openFEC/pull/1814) ([LindsayYoung](https://github.com/LindsayYoung))
- Primary Key fix for partitioned tables [\#1813](https://github.com/fecgov/openFEC/pull/1813) ([jontours](https://github.com/jontours))

**Closed issues:**

- Invoke update is causing problems, as invoke changed it's api. [\#1843](https://github.com/fecgov/openFEC/issues/1843)
- Big discrepancy between money raised by state from schedule\_a [\#1839](https://github.com/fecgov/openFEC/issues/1839)
- is\_individual [\#1832](https://github.com/fecgov/openFEC/issues/1832)
- Update flask sqlalchemy [\#1826](https://github.com/fecgov/openFEC/issues/1826)
- Add tests to detect when hide\_sort\_null flag is broken. [\#1823](https://github.com/fecgov/openFEC/issues/1823)
- Look into fixing the data subsetter [\#1796](https://github.com/fecgov/openFEC/issues/1796)
- outstanding work for CMS  [\#1795](https://github.com/fecgov/openFEC/issues/1795)
- Onboard @xtine [\#1793](https://github.com/fecgov/openFEC/issues/1793)
- Assess technical feasibility of getting e-filing feed from FEC [\#1787](https://github.com/fecgov/openFEC/issues/1787)
- Reach out to e-filings users who do dev on this data [\#1786](https://github.com/fecgov/openFEC/issues/1786)
- switch off multi-buildpack [\#1770](https://github.com/fecgov/openFEC/issues/1770)
- Address design feedback on data landing page [\#1761](https://github.com/fecgov/openFEC/issues/1761)
- Content feedback for raising and spending overviews [\#1746](https://github.com/fecgov/openFEC/issues/1746)
- Content for overview pages [\#1733](https://github.com/fecgov/openFEC/issues/1733)
- Review and add redundancy to data feed [\#1716](https://github.com/fecgov/openFEC/issues/1716)
- Move schedule B off of data warehouse tables [\#1699](https://github.com/fecgov/openFEC/issues/1699)
- Strange inconsistencies between API returns and FEC website returns [\#1668](https://github.com/fecgov/openFEC/issues/1668)
- Schedule A & B Partitioning:  Make identifiers filterable [\#1639](https://github.com/fecgov/openFEC/issues/1639)
- Schedule A & B Partitioning:  Use unique persistent identifiers instead of idx [\#1638](https://github.com/fecgov/openFEC/issues/1638)
- Campaign Finance Data Presentation -Various and Sundry issues  [\#1633](https://github.com/fecgov/openFEC/issues/1633)
- Turn off nightly updates on feature branch [\#1626](https://github.com/fecgov/openFEC/issues/1626)
- Epic: Migrate from data warehouse tables [\#1622](https://github.com/fecgov/openFEC/issues/1622)
- Re-order columns for downloads [\#1581](https://github.com/fecgov/openFEC/issues/1581)
- Figure out column for true amendment indicator [\#1546](https://github.com/fecgov/openFEC/issues/1546)
- Send 18F table of schedule A line numbers with a text explanation [\#1545](https://github.com/fecgov/openFEC/issues/1545)
- Query params on committees API do not appear to apply to result set [\#1381](https://github.com/fecgov/openFEC/issues/1381)
- To make sure the API is usable, make sure it's up to standards [\#252](https://github.com/fecgov/openFEC/issues/252)

**Merged pull requests:**

- Fix individual calculations [\#1837](https://github.com/fecgov/openFEC/pull/1837) ([LindsayYoung](https://github.com/LindsayYoung))
- Fix for election sorting [\#1825](https://github.com/fecgov/openFEC/pull/1825) ([jontours](https://github.com/jontours))
- \[MERGE WITH GITFLOW\] Release/public beta 20160720 [\#1817](https://github.com/fecgov/openFEC/pull/1817) ([LindsayYoung](https://github.com/LindsayYoung))
- Feature/add subid filter to sched a b [\#1816](https://github.com/fecgov/openFEC/pull/1816) ([jontours](https://github.com/jontours))
- Add information to weekly refresh task email notifications [\#1815](https://github.com/fecgov/openFEC/pull/1815) ([ccostino](https://github.com/ccostino))
- Feature/reorder-columns [\#1808](https://github.com/fecgov/openFEC/pull/1808) ([noahmanger](https://github.com/noahmanger))
- Adjust aggregate table processing to make use of temporary tables [\#1807](https://github.com/fecgov/openFEC/pull/1807) ([ccostino](https://github.com/ccostino))
- Feature/build swagger on ci [\#1805](https://github.com/fecgov/openFEC/pull/1805) ([adborden](https://github.com/adborden))
- Add flags to JSON returned by candidate/totals endpoint. [\#1797](https://github.com/fecgov/openFEC/pull/1797) ([jontours](https://github.com/jontours))
- Schedule A and B migration [\#1780](https://github.com/fecgov/openFEC/pull/1780) ([jontours](https://github.com/jontours))
- Feature/data load fallback [\#1773](https://github.com/fecgov/openFEC/pull/1773) ([LindsayYoung](https://github.com/LindsayYoung))
- Upgrade to latest invoke. [\#1771](https://github.com/fecgov/openFEC/pull/1771) ([jmcarp](https://github.com/jmcarp))

## [public-beta-20160707](https://github.com/fecgov/openFEC/tree/public-beta-20160707) (2016-07-07)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-beta-20160622...public-beta-20160707)

**Fixed bugs:**

- Fix candidate totals sorting bug [\#1798](https://github.com/fecgov/openFEC/issues/1798)
- image numbers [\#1782](https://github.com/fecgov/openFEC/issues/1782)
- Schema update [\#1781](https://github.com/fecgov/openFEC/issues/1781)
- add dependency [\#1776](https://github.com/fecgov/openFEC/issues/1776)
- build npm assets on Travis for API [\#1764](https://github.com/fecgov/openFEC/issues/1764)
- State columns poorly sized on candidate office pages [\#1759](https://github.com/fecgov/openFEC/issues/1759)
- transaction lock error  [\#1739](https://github.com/fecgov/openFEC/issues/1739)
- Disbursements: Payee search not returning results for certain terms [\#1679](https://github.com/fecgov/openFEC/issues/1679)
- Missing Candidate [\#1632](https://github.com/fecgov/openFEC/issues/1632)
- Duplicate sched e record on staging [\#1625](https://github.com/fecgov/openFEC/issues/1625)
- Search discrepancy [\#1601](https://github.com/fecgov/openFEC/issues/1601)
- State by state breakdowns don't seem to be updating [\#1436](https://github.com/fecgov/openFEC/issues/1436)

**Closed issues:**

- Refine instructions for usability testing rig and share with \#fec-partners [\#1784](https://github.com/fecgov/openFEC/issues/1784)
- Add missing filters and fields to committees totals endpoint [\#1742](https://github.com/fecgov/openFEC/issues/1742)
- Treejack usability findings \(6/16/16\) [\#1734](https://github.com/fecgov/openFEC/issues/1734)
- Committee pages: use the same scale for bar charts across all tabs so that users can get an idea of how a value on tab 3 compares to the highest value on tab 1 [\#1704](https://github.com/fecgov/openFEC/issues/1704)
- Visual design of spending overview page [\#1703](https://github.com/fecgov/openFEC/issues/1703)
- Notice links for the calendar [\#1697](https://github.com/fecgov/openFEC/issues/1697)
- create more shareable directional research  [\#1673](https://github.com/fecgov/openFEC/issues/1673)
- Refine usability testing note-taking tool [\#1670](https://github.com/fecgov/openFEC/issues/1670)
- Visual design of raising overview page [\#1656](https://github.com/fecgov/openFEC/issues/1656)
- Onboard @jontours [\#1655](https://github.com/fecgov/openFEC/issues/1655)
- "total received" on disbursement screen [\#1312](https://github.com/fecgov/openFEC/issues/1312)

**Merged pull requests:**

- Fix for candidate totals bug [\#1803](https://github.com/fecgov/openFEC/pull/1803) ([jontours](https://github.com/jontours))
- Fixing args so that the datatype for image numbers are strings [\#1802](https://github.com/fecgov/openFEC/pull/1802) ([LindsayYoung](https://github.com/LindsayYoung))
- Adding general reporting page link for reporting periods [\#1799](https://github.com/fecgov/openFEC/pull/1799) ([LindsayYoung](https://github.com/LindsayYoung))
- \[DON'T MERGE\] Release/public beta 20160707 [\#1783](https://github.com/fecgov/openFEC/pull/1783) ([LindsayYoung](https://github.com/LindsayYoung))
- Adding links to the main reporting page for the year. [\#1778](https://github.com/fecgov/openFEC/pull/1778) ([LindsayYoung](https://github.com/LindsayYoung))
- Modify pac/party committee for filtering, sorting \[WIP\] [\#1772](https://github.com/fecgov/openFEC/pull/1772) ([jontours](https://github.com/jontours))
- Revert "Adding the build step for the documentation " [\#1768](https://github.com/fecgov/openFEC/pull/1768) ([LindsayYoung](https://github.com/LindsayYoung))
- Adding the build step for the documentation  [\#1767](https://github.com/fecgov/openFEC/pull/1767) ([LindsayYoung](https://github.com/LindsayYoung))
- Target cloud.gov api for deploy [\#1754](https://github.com/fecgov/openFEC/pull/1754) ([ccostino](https://github.com/ccostino))
- Feature/rad [\#1751](https://github.com/fecgov/openFEC/pull/1751) ([LindsayYoung](https://github.com/LindsayYoung))
- Account for CF target in deploy task [\#1747](https://github.com/fecgov/openFEC/pull/1747) ([ccostino](https://github.com/ccostino))
- Updated Test subset data [\#1705](https://github.com/fecgov/openFEC/pull/1705) ([ccostino](https://github.com/ccostino))
- Feature/house, senate, presidental, pac and party table switch [\#1628](https://github.com/fecgov/openFEC/pull/1628) ([LindsayYoung](https://github.com/LindsayYoung))

## [public-beta-20160622](https://github.com/fecgov/openFEC/tree/public-beta-20160622) (2016-06-28)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-beta-20160608...public-beta-20160622)

**Fixed bugs:**

- Restart redis on staging [\#1745](https://github.com/fecgov/openFEC/issues/1745)
- Difference in contributor count between beta data table and classic map [\#1719](https://github.com/fecgov/openFEC/issues/1719)
- Flask .11 compatibility [\#1695](https://github.com/fecgov/openFEC/issues/1695)

**Closed issues:**

- Schedule A and B updates are failing [\#1760](https://github.com/fecgov/openFEC/issues/1760)
- Add committee ID to schedule A and B recipient name tsvector  [\#1756](https://github.com/fecgov/openFEC/issues/1756)
- Rename receipt\_date field on schedule A and B [\#1750](https://github.com/fecgov/openFEC/issues/1750)
- Pre-release download fixes [\#1748](https://github.com/fecgov/openFEC/issues/1748)
- Make remaining changes to downloads [\#1741](https://github.com/fecgov/openFEC/issues/1741)
- RAD analyst endpoint [\#1740](https://github.com/fecgov/openFEC/issues/1740)
- target correct space automatically on deploy [\#1738](https://github.com/fecgov/openFEC/issues/1738)
- Rename transaction\_year field [\#1735](https://github.com/fecgov/openFEC/issues/1735)
- Bug: Receipts for a committee aren't showing up [\#1720](https://github.com/fecgov/openFEC/issues/1720)
- Update deploy task to account for cloud.gov SSO [\#1714](https://github.com/fecgov/openFEC/issues/1714)
- Test Plan, June 6-10 [\#1710](https://github.com/fecgov/openFEC/issues/1710)
- Communicate the partition changes to the data listserv [\#1702](https://github.com/fecgov/openFEC/issues/1702)
- Receipts data: Unique filter behaving weird [\#1678](https://github.com/fecgov/openFEC/issues/1678)
- Update beta.fec.gov landing page with new content coming soon [\#1677](https://github.com/fecgov/openFEC/issues/1677)
- Make front-end change to restrict schedule tables to two-year period [\#1674](https://github.com/fecgov/openFEC/issues/1674)
- Usability finding: typeahead for committees on receipts data page [\#1652](https://github.com/fecgov/openFEC/issues/1652)
- Make partitioned schedule A and B tables work for downloads [\#1636](https://github.com/fecgov/openFEC/issues/1636)
- Transform legal search response for UI [\#1624](https://github.com/fecgov/openFEC/issues/1624)
- Update system diagram for the openFEC system [\#1591](https://github.com/fecgov/openFEC/issues/1591)
- 508 Issues [\#1554](https://github.com/fecgov/openFEC/issues/1554)
- Migrate fact tables from Data Warehouse to views  [\#1537](https://github.com/fecgov/openFEC/issues/1537)
- Implement the partitioned transaction tables [\#1472](https://github.com/fecgov/openFEC/issues/1472)
- In order to improve query performance, evaluate partitioning on large tables. [\#1228](https://github.com/fecgov/openFEC/issues/1228)
- So users can find the election search, redesign search to be more prominent [\#1184](https://github.com/fecgov/openFEC/issues/1184)
- Inconsistent dates in `vw\_filing\_history` [\#1147](https://github.com/fecgov/openFEC/issues/1147)
- Bootstrap script doesn't export all necessary env vars [\#894](https://github.com/fecgov/openFEC/issues/894)
- Contributor notes on setting up repo for first time. [\#482](https://github.com/fecgov/openFEC/issues/482)
- Template data should be namespaced [\#386](https://github.com/fecgov/openFEC/issues/386)

**Merged pull requests:**

- Expose memo code [\#1774](https://github.com/fecgov/openFEC/pull/1774) ([LindsayYoung](https://github.com/LindsayYoung))
- Reverting \#1645 this puts us back on the old multi buildpack  [\#1769](https://github.com/fecgov/openFEC/pull/1769) ([LindsayYoung](https://github.com/LindsayYoung))
- Fix Schedule A and B updates [\#1763](https://github.com/fecgov/openFEC/pull/1763) ([ccostino](https://github.com/ccostino))
- Adding back the committee id into the tsvector for recipient name [\#1762](https://github.com/fecgov/openFEC/pull/1762) ([LindsayYoung](https://github.com/LindsayYoung))
- Target cloud.gov api for deploy [\#1753](https://github.com/fecgov/openFEC/pull/1753) ([ccostino](https://github.com/ccostino))
- Address itemized downloads feedback [\#1752](https://github.com/fecgov/openFEC/pull/1752) ([ccostino](https://github.com/ccostino))
- Account for CF target in deploy task [\#1749](https://github.com/fecgov/openFEC/pull/1749) ([ccostino](https://github.com/ccostino))
- Rename transaction\_year field [\#1744](https://github.com/fecgov/openFEC/pull/1744) ([ccostino](https://github.com/ccostino))
- \[DON'T MERGE\] Release/public beta 20160622 [\#1737](https://github.com/fecgov/openFEC/pull/1737) ([LindsayYoung](https://github.com/LindsayYoung))
- 2nd try at new travis and local log in [\#1731](https://github.com/fecgov/openFEC/pull/1731) ([LindsayYoung](https://github.com/LindsayYoung))
- Update CloudFoundry login setup [\#1728](https://github.com/fecgov/openFEC/pull/1728) ([ccostino](https://github.com/ccostino))
- Fix for flask import warning statements [\#1724](https://github.com/fecgov/openFEC/pull/1724) ([jontours](https://github.com/jontours))
- small definition tweak [\#1723](https://github.com/fecgov/openFEC/pull/1723) ([LindsayYoung](https://github.com/LindsayYoung))
- Adding link to updated system diagram [\#1718](https://github.com/fecgov/openFEC/pull/1718) ([LindsayYoung](https://github.com/LindsayYoung))
- Flask Versioning fix [\#1717](https://github.com/fecgov/openFEC/pull/1717) ([jontours](https://github.com/jontours))
- Add missing dependency for schema updates [\#1715](https://github.com/fecgov/openFEC/pull/1715) ([LindsayYoung](https://github.com/LindsayYoung))
- \[WIP\] Enable support to retrieve itemized data limited by cycle [\#1713](https://github.com/fecgov/openFEC/pull/1713) ([ccostino](https://github.com/ccostino))
- change "and" to "or" to get correct aggregates and unique filtering  [\#1712](https://github.com/fecgov/openFEC/pull/1712) ([LindsayYoung](https://github.com/LindsayYoung))
- Remove reference to changelog [\#1709](https://github.com/fecgov/openFEC/pull/1709) ([LindsayYoung](https://github.com/LindsayYoung))
- Small fix to npm install instructions in README [\#1706](https://github.com/fecgov/openFEC/pull/1706) ([ccostino](https://github.com/ccostino))
- Build assets on CI. [\#1645](https://github.com/fecgov/openFEC/pull/1645) ([jmcarp](https://github.com/jmcarp))
- Partition large itemized tables. [\#1429](https://github.com/fecgov/openFEC/pull/1429) ([jmcarp](https://github.com/jmcarp))

## [public-beta-20160608](https://github.com/fecgov/openFEC/tree/public-beta-20160608) (2016-06-08)

[Full Changelog](https://github.com/fecgov/openFEC/compare/travis-redeploy...public-beta-20160608)

**Closed issues:**

- Update frontend of calendar filters to account for states now filtering periods [\#1675](https://github.com/fecgov/openFEC/issues/1675)

**Merged pull requests:**

- Turning off slack notifications till intergration service is back [\#1707](https://github.com/fecgov/openFEC/pull/1707) ([LindsayYoung](https://github.com/LindsayYoung))
- fix report year definition [\#1693](https://github.com/fecgov/openFEC/pull/1693) ([LindsayYoung](https://github.com/LindsayYoung))
- Feature/totals flag extension [\#1692](https://github.com/fecgov/openFEC/pull/1692) ([jontours](https://github.com/jontours))
- Fixed database string, changes dashes to underscores [\#1683](https://github.com/fecgov/openFEC/pull/1683) ([jontours](https://github.com/jontours))
- Feature/reporting periods states [\#1664](https://github.com/fecgov/openFEC/pull/1664) ([LindsayYoung](https://github.com/LindsayYoung))

## [travis-redeploy](https://github.com/fecgov/openFEC/tree/travis-redeploy) (2016-06-05)

[Full Changelog](https://github.com/fecgov/openFEC/compare/turn-off-slack...travis-redeploy)

## [turn-off-slack](https://github.com/fecgov/openFEC/tree/turn-off-slack) (2016-06-03)

[Full Changelog](https://github.com/fecgov/openFEC/compare/avoid-flask-11-error...turn-off-slack)

**Closed issues:**

- $5,000 to spent money flag [\#1688](https://github.com/fecgov/openFEC/issues/1688)
- state filtering for reporting periods [\#1661](https://github.com/fecgov/openFEC/issues/1661)
- Schedule A & B Partitioning:  Add all of the data [\#1637](https://github.com/fecgov/openFEC/issues/1637)
- fix nplusone issues [\#1629](https://github.com/fecgov/openFEC/issues/1629)
- Make schedules from FECP instead of warehouse [\#1538](https://github.com/fecgov/openFEC/issues/1538)

**Merged pull requests:**

- \[MERGE WITH GETFLOW\] turn off slack for now [\#1708](https://github.com/fecgov/openFEC/pull/1708) ([LindsayYoung](https://github.com/LindsayYoung))

## [avoid-flask-11-error](https://github.com/fecgov/openFEC/tree/avoid-flask-11-error) (2016-06-03)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-beta-20160525...avoid-flask-11-error)

**Closed issues:**

- Presidential 12P reporting dates for 2016 \(and presumably after that\) [\#1690](https://github.com/fecgov/openFEC/issues/1690)
- Update "contributor name or ID" field autosuggest  [\#1684](https://github.com/fecgov/openFEC/issues/1684)
- Visual design of advanced data page  [\#1681](https://github.com/fecgov/openFEC/issues/1681)
- Implement remaining UI changes on calendar [\#1676](https://github.com/fecgov/openFEC/issues/1676)
- Implement mobile version of new site menu [\#1666](https://github.com/fecgov/openFEC/issues/1666)
- Implement new smaller header designs [\#1663](https://github.com/fecgov/openFEC/issues/1663)
- Add federal\_funds\_flag to /totals/ endpoint [\#1662](https://github.com/fecgov/openFEC/issues/1662)
- Readme python tests running error [\#1658](https://github.com/fecgov/openFEC/issues/1658)
- Usability Finding: calendar state filtering confusing user [\#1650](https://github.com/fecgov/openFEC/issues/1650)
- Usability Finding: Calendar Grid View "hard to read" [\#1648](https://github.com/fecgov/openFEC/issues/1648)

**Merged pull requests:**

- The api is currently incompatible with Flask .11 [\#1696](https://github.com/fecgov/openFEC/pull/1696) ([LindsayYoung](https://github.com/LindsayYoung))

## [public-beta-20160525](https://github.com/fecgov/openFEC/tree/public-beta-20160525) (2016-05-25)

[Full Changelog](https://github.com/fecgov/openFEC/compare/20160428...public-beta-20160525)

**Closed issues:**

- Last Name sort order [\#1687](https://github.com/fecgov/openFEC/issues/1687)
- Relabel "Federal funds" filter [\#1654](https://github.com/fecgov/openFEC/issues/1654)
- Intermediate table [\#1651](https://github.com/fecgov/openFEC/issues/1651)
- Calendar microcopy [\#1649](https://github.com/fecgov/openFEC/issues/1649)
- Do content workshop with FEC  [\#1642](https://github.com/fecgov/openFEC/issues/1642)
- On-board Jon to project [\#1641](https://github.com/fecgov/openFEC/issues/1641)
- Get Jon access to everything  [\#1640](https://github.com/fecgov/openFEC/issues/1640)
- Benchmark partitioning performance [\#1635](https://github.com/fecgov/openFEC/issues/1635)
- Ensure that full team understands trade-offs of table partitioning [\#1634](https://github.com/fecgov/openFEC/issues/1634)
- NEXT DEPLOY [\#1627](https://github.com/fecgov/openFEC/issues/1627)
- Detailed information and interaction design of fundraising overview [\#1620](https://github.com/fecgov/openFEC/issues/1620)
- Respond to calendar feedback and questions [\#1619](https://github.com/fecgov/openFEC/issues/1619)
- Set links to candidate data table page to include $5,000 flag [\#1616](https://github.com/fecgov/openFEC/issues/1616)
- Detailed information design of the new data landing page [\#1596](https://github.com/fecgov/openFEC/issues/1596)
- Test typeahead filter in usability testing [\#1594](https://github.com/fecgov/openFEC/issues/1594)
- Review new tables [\#1580](https://github.com/fecgov/openFEC/issues/1580)
- Evaluate and decide on partitioning method [\#1566](https://github.com/fecgov/openFEC/issues/1566)
- Explicitly track dependencies between data views [\#1515](https://github.com/fecgov/openFEC/issues/1515)
- Implement details panels for the office pages [\#1496](https://github.com/fecgov/openFEC/issues/1496)

**Merged pull requests:**

- adding elasticsearch service to stage and prod [\#1691](https://github.com/fecgov/openFEC/pull/1691) ([anthonygarvan](https://github.com/anthonygarvan))
- Changing the 5k flag to has\_raised\_funds [\#1689](https://github.com/fecgov/openFEC/pull/1689) ([LindsayYoung](https://github.com/LindsayYoung))
- Add title case to party [\#1686](https://github.com/fecgov/openFEC/pull/1686) ([LindsayYoung](https://github.com/LindsayYoung))
- Use better party discription on calendar [\#1671](https://github.com/fecgov/openFEC/pull/1671) ([LindsayYoung](https://github.com/LindsayYoung))
- \[DON'T MERGE\] Release/public beta 20160525 [\#1667](https://github.com/fecgov/openFEC/pull/1667) ([noahmanger](https://github.com/noahmanger))
- bug fix in case there is no highlights [\#1665](https://github.com/fecgov/openFEC/pull/1665) ([anthonygarvan](https://github.com/anthonygarvan))
- Feature/calendar microcopy  [\#1659](https://github.com/fecgov/openFEC/pull/1659) ([LindsayYoung](https://github.com/LindsayYoung))
- Feature/add regulations [\#1657](https://github.com/fecgov/openFEC/pull/1657) ([anthonygarvan](https://github.com/anthonygarvan))
- Updated test data subset instructions [\#1647](https://github.com/fecgov/openFEC/pull/1647) ([ccostino](https://github.com/ccostino))
- Eager-load flags on candidate views and restore nplusone. [\#1631](https://github.com/fecgov/openFEC/pull/1631) ([jmcarp](https://github.com/jmcarp))
- Feature/money flags [\#1548](https://github.com/fecgov/openFEC/pull/1548) ([LindsayYoung](https://github.com/LindsayYoung))

## [20160428](https://github.com/fecgov/openFEC/tree/20160428) (2016-04-29)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-beta-20160413...20160428)

**Closed issues:**

- Get Carlo set up with Amazon alerts [\#1617](https://github.com/fecgov/openFEC/issues/1617)
- NEXT DEPLOY  [\#1600](https://github.com/fecgov/openFEC/issues/1600)
- Filings Endpoint Pagination Issue [\#1598](https://github.com/fecgov/openFEC/issues/1598)
- Inconsistencies between FEC web search form and API when searching by contributor name [\#1597](https://github.com/fecgov/openFEC/issues/1597)
- Get Carlo an Amazon account [\#1579](https://github.com/fecgov/openFEC/issues/1579)
- Documentation improvements for new users in the API repo [\#1559](https://github.com/fecgov/openFEC/issues/1559)
- Add filter for "Candidates that accept federal funds" [\#1476](https://github.com/fecgov/openFEC/issues/1476)
- API make a unified has raised $5,000 [\#1469](https://github.com/fecgov/openFEC/issues/1469)

**Merged pull requests:**

- \[DONT MERGE\] release/20160428 [\#1630](https://github.com/fecgov/openFEC/pull/1630) ([LindsayYoung](https://github.com/LindsayYoung))
- Feature/search enhancements [\#1623](https://github.com/fecgov/openFEC/pull/1623) ([anthonygarvan](https://github.com/anthonygarvan))
- Feature/load legal docs [\#1615](https://github.com/fecgov/openFEC/pull/1615) ([anthonygarvan](https://github.com/anthonygarvan))
- Updates to our contributing guidelines [\#1613](https://github.com/fecgov/openFEC/pull/1613) ([ccostino](https://github.com/ccostino))
- adding feature space manifest [\#1611](https://github.com/fecgov/openFEC/pull/1611) ([anthonygarvan](https://github.com/anthonygarvan))
- Run database tasks in dependency order. [\#1610](https://github.com/fecgov/openFEC/pull/1610) ([jmcarp](https://github.com/jmcarp))
- Makes updates to README content [\#1577](https://github.com/fecgov/openFEC/pull/1577) ([emileighoutlaw](https://github.com/emileighoutlaw))

## [public-beta-20160413](https://github.com/fecgov/openFEC/tree/public-beta-20160413) (2016-04-14)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-beta-20160316...public-beta-20160413)

**Closed issues:**

- New demo epic [\#1604](https://github.com/fecgov/openFEC/issues/1604)
- Style breadcrumbs [\#1595](https://github.com/fecgov/openFEC/issues/1595)
- Issue with "name" field on FEC API candidate endpoint [\#1593](https://github.com/fecgov/openFEC/issues/1593)
- Broken link to candidate from committee page [\#1536](https://github.com/fecgov/openFEC/issues/1536)

**Merged pull requests:**

- Release/public beta 20160413 [\#1609](https://github.com/fecgov/openFEC/pull/1609) ([noahmanger](https://github.com/noahmanger))
- Parse ES url from VCAP\_SERVICES [\#1606](https://github.com/fecgov/openFEC/pull/1606) ([adborden](https://github.com/adborden))
- Update deployer creds [\#1605](https://github.com/fecgov/openFEC/pull/1605) ([adborden](https://github.com/adborden))
- Hotfix/name back [\#1603](https://github.com/fecgov/openFEC/pull/1603) ([LindsayYoung](https://github.com/LindsayYoung))
- adding simple search for legal documents [\#1592](https://github.com/fecgov/openFEC/pull/1592) ([anthonygarvan](https://github.com/anthonygarvan))
- Adding change log and change log instructions to README [\#1590](https://github.com/fecgov/openFEC/pull/1590) ([LindsayYoung](https://github.com/LindsayYoung))
- Trying to be extra explicit [\#1578](https://github.com/fecgov/openFEC/pull/1578) ([LindsayYoung](https://github.com/LindsayYoung))
- Feature/merge 0316 release [\#1576](https://github.com/fecgov/openFEC/pull/1576) ([LindsayYoung](https://github.com/LindsayYoung))
- Adding 1G of memory [\#1571](https://github.com/fecgov/openFEC/pull/1571) ([LindsayYoung](https://github.com/LindsayYoung))
- Fixes docs.py typos [\#1570](https://github.com/fecgov/openFEC/pull/1570) ([nbedi](https://github.com/nbedi))
- Feature/add disbursement puropse description [\#1563](https://github.com/fecgov/openFEC/pull/1563) ([LindsayYoung](https://github.com/LindsayYoung))

## [public-beta-20160316](https://github.com/fecgov/openFEC/tree/public-beta-20160316) (2016-03-31)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-beta-20160218...public-beta-20160316)

**Fixed bugs:**

- debug import errors on dev and staging [\#1575](https://github.com/fecgov/openFEC/issues/1575)
- Bug: Calendar timezone problem [\#1549](https://github.com/fecgov/openFEC/issues/1549)

**Closed issues:**

- Respond to OCG comments on party committee content [\#1568](https://github.com/fecgov/openFEC/issues/1568)
- Review data needed for individual contributions + operating expenditures tables [\#1567](https://github.com/fecgov/openFEC/issues/1567)
- drivers of openFEC features [\#1556](https://github.com/fecgov/openFEC/issues/1556)
- QA new typeahead [\#1547](https://github.com/fecgov/openFEC/issues/1547)
- Coming soon link for calendar should be removed [\#1540](https://github.com/fecgov/openFEC/issues/1540)
- add some calendar docs [\#1533](https://github.com/fecgov/openFEC/issues/1533)
- Add missing districts to calendar events [\#1529](https://github.com/fecgov/openFEC/issues/1529)
- some candidate information not populating for F2 [\#1527](https://github.com/fecgov/openFEC/issues/1527)
- Communicate API change [\#1525](https://github.com/fecgov/openFEC/issues/1525)
- Manage S3 buckets using Cloud Foundry service [\#1522](https://github.com/fecgov/openFEC/issues/1522)
- Discussion: revisit branching and continuous delivery workflow [\#1517](https://github.com/fecgov/openFEC/issues/1517)
- Use autopilot for zero-downtime deploys [\#1511](https://github.com/fecgov/openFEC/issues/1511)
- Discussion: Use tables instead of materialized views [\#1509](https://github.com/fecgov/openFEC/issues/1509)
- Discussion: Missing report types in sched\_e [\#1499](https://github.com/fecgov/openFEC/issues/1499)
- Create schedule for DC in-person sessons [\#1498](https://github.com/fecgov/openFEC/issues/1498)
- Make filter accordions [\#1495](https://github.com/fecgov/openFEC/issues/1495)
- Test new Typeahead [\#1491](https://github.com/fecgov/openFEC/issues/1491)
- Research performance improvements for data downloads [\#1489](https://github.com/fecgov/openFEC/issues/1489)
- Bug: Certain filing fields missing on dev [\#1480](https://github.com/fecgov/openFEC/issues/1480)
- Review the totals over time endpoint [\#1467](https://github.com/fecgov/openFEC/issues/1467)
- API Endpoint for totals over time [\#1466](https://github.com/fecgov/openFEC/issues/1466)
- release planning: Dino, sprint 6 [\#1460](https://github.com/fecgov/openFEC/issues/1460)
- Onboard @ccostino [\#1453](https://github.com/fecgov/openFEC/issues/1453)
- update reporting codes [\#1437](https://github.com/fecgov/openFEC/issues/1437)
- Add data to API [\#1434](https://github.com/fecgov/openFEC/issues/1434)
- Figure out better way of organizing our environments [\#1420](https://github.com/fecgov/openFEC/issues/1420)
- Load financial reports from FECP [\#1337](https://github.com/fecgov/openFEC/issues/1337)
- To improve data quality, migrate away from data warehouse tables [\#1327](https://github.com/fecgov/openFEC/issues/1327)

**Merged pull requests:**

- Adding 1G of memory [\#1572](https://github.com/fecgov/openFEC/pull/1572) ([LindsayYoung](https://github.com/LindsayYoung))
- Use external library for COPY TO. [\#1564](https://github.com/fecgov/openFEC/pull/1564) ([jmcarp](https://github.com/jmcarp))
- Fix two typos in 'Quick\(ish\) start' section [\#1557](https://github.com/fecgov/openFEC/pull/1557) ([fureigh](https://github.com/fureigh))
- Feature/all day events [\#1555](https://github.com/fecgov/openFEC/pull/1555) ([jmcarp](https://github.com/jmcarp))
- Add timezones to ics exports. [\#1550](https://github.com/fecgov/openFEC/pull/1550) ([jmcarp](https://github.com/jmcarp))
- Feature/filter candidate election year [\#1544](https://github.com/fecgov/openFEC/pull/1544) ([jmcarp](https://github.com/jmcarp))
- Adding some more inline docs closes \#1533 [\#1543](https://github.com/fecgov/openFEC/pull/1543) ([LindsayYoung](https://github.com/LindsayYoung))
- Use pre-computed election ranges to round up to next election. [\#1542](https://github.com/fecgov/openFEC/pull/1542) ([jmcarp](https://github.com/jmcarp))
- Feature/candidate total filters [\#1541](https://github.com/fecgov/openFEC/pull/1541) ([jmcarp](https://github.com/jmcarp))
- Use S3 service in Cloud Foundry. [\#1523](https://github.com/fecgov/openFEC/pull/1523) ([jmcarp](https://github.com/jmcarp))
- adding requirements-dev and npm i to readme [\#1520](https://github.com/fecgov/openFEC/pull/1520) ([cmajel](https://github.com/cmajel))
- Use autopilot for zero-downtime deploys. [\#1516](https://github.com/fecgov/openFEC/pull/1516) ([jmcarp](https://github.com/jmcarp))
- Revert null position option. [\#1512](https://github.com/fecgov/openFEC/pull/1512) ([jmcarp](https://github.com/jmcarp))
- Copy to csv proof of concept. [\#1502](https://github.com/fecgov/openFEC/pull/1502) ([jmcarp](https://github.com/jmcarp))
- \[WIP\] Add candidate fundraising history endpoint. [\#1473](https://github.com/fecgov/openFEC/pull/1473) ([jmcarp](https://github.com/jmcarp))
- Allow multiple queries on full-text columns. [\#1462](https://github.com/fecgov/openFEC/pull/1462) ([jmcarp](https://github.com/jmcarp))

## [public-beta-20160218](https://github.com/fecgov/openFEC/tree/public-beta-20160218) (2016-02-18)

[Full Changelog](https://github.com/fecgov/openFEC/compare/use-numeric-types...public-beta-20160218)

**Closed issues:**

- Properly decode Caucus elections from Convention elections [\#1526](https://github.com/fecgov/openFEC/issues/1526)
- Add "Transaction type" to Communication Costs [\#1524](https://github.com/fecgov/openFEC/issues/1524)
- Update README.md for dev + npm tasks [\#1519](https://github.com/fecgov/openFEC/issues/1519)
- Format report due date decriptions [\#1508](https://github.com/fecgov/openFEC/issues/1508)
- Missing districts in election events [\#1507](https://github.com/fecgov/openFEC/issues/1507)
- Document sources used for each datatable page [\#1501](https://github.com/fecgov/openFEC/issues/1501)
- Missing coverage start date on some reports [\#1488](https://github.com/fecgov/openFEC/issues/1488)
- Add PDF\_URL to EC and CC endpoints [\#1486](https://github.com/fecgov/openFEC/issues/1486)
- Discussion: Mis-formatted dates in communication costs [\#1479](https://github.com/fecgov/openFEC/issues/1479)
- Caucuses and primary conventions should be filterable as "primaries" [\#1455](https://github.com/fecgov/openFEC/issues/1455)
- Add filter for disbursement category codes [\#1454](https://github.com/fecgov/openFEC/issues/1454)
- release: Parasaurolophus [\#1447](https://github.com/fecgov/openFEC/issues/1447)
- To have confidence in our data, verify logic for contributor aggregates [\#1303](https://github.com/fecgov/openFEC/issues/1303)
- Add itemized communication costs. [\#1098](https://github.com/fecgov/openFEC/issues/1098)

**Merged pull requests:**

- Update exclusion rule. [\#1531](https://github.com/fecgov/openFEC/pull/1531) ([jmcarp](https://github.com/jmcarp))
- Feature/hide prez fix caucus [\#1530](https://github.com/fecgov/openFEC/pull/1530) ([LindsayYoung](https://github.com/LindsayYoung))
- Adding additional decoding for caucuses and conventions [\#1528](https://github.com/fecgov/openFEC/pull/1528) ([LindsayYoung](https://github.com/LindsayYoung))
- Feature/update electioneering schema [\#1518](https://github.com/fecgov/openFEC/pull/1518) ([jmcarp](https://github.com/jmcarp))
- reformats report code [\#1514](https://github.com/fecgov/openFEC/pull/1514) ([LindsayYoung](https://github.com/LindsayYoung))
- Whitelist cost views for export. [\#1506](https://github.com/fecgov/openFEC/pull/1506) ([jmcarp](https://github.com/jmcarp))
- Drop contribution aggregate by contributor. [\#1504](https://github.com/fecgov/openFEC/pull/1504) ([jmcarp](https://github.com/jmcarp))
- Feature/costs sort pdf [\#1497](https://github.com/fecgov/openFEC/pull/1497) ([jmcarp](https://github.com/jmcarp))
- Feature/dates 2 tweaks [\#1464](https://github.com/fecgov/openFEC/pull/1464) ([LindsayYoung](https://github.com/LindsayYoung))
- Fix type and aggregate. [\#1463](https://github.com/fecgov/openFEC/pull/1463) ([jmcarp](https://github.com/jmcarp))
- Extending about.yml services [\#1459](https://github.com/fecgov/openFEC/pull/1459) ([DavidEBest](https://github.com/DavidEBest))
- Feature/document fields [\#1449](https://github.com/fecgov/openFEC/pull/1449) ([LindsayYoung](https://github.com/LindsayYoung))
- Abort deploy on invalid configuration. [\#1446](https://github.com/fecgov/openFEC/pull/1446) ([jmcarp](https://github.com/jmcarp))

## [use-numeric-types](https://github.com/fecgov/openFEC/tree/use-numeric-types) (2016-02-09)

[Full Changelog](https://github.com/fecgov/openFEC/compare/ie-form-filter...use-numeric-types)

**Closed issues:**

- Bug: Candidate name search on browse page doesn't work if name is "FN LN" only "LN, FN" [\#1494](https://github.com/fecgov/openFEC/issues/1494)
- Hide titles on calendar events [\#1493](https://github.com/fecgov/openFEC/issues/1493)
- Combine reporting deadline dates for multiple states [\#1474](https://github.com/fecgov/openFEC/issues/1474)
- Decide if we want to use data entry for calendar [\#1471](https://github.com/fecgov/openFEC/issues/1471)

**Merged pull requests:**

- Use numeric types as needed in financial models. [\#1490](https://github.com/fecgov/openFEC/pull/1490) ([jmcarp](https://github.com/jmcarp))

## [ie-form-filter](https://github.com/fecgov/openFEC/tree/ie-form-filter) (2016-02-08)

[Full Changelog](https://github.com/fecgov/openFEC/compare/download-itemized...ie-form-filter)

**Merged pull requests:**

- Filter itemized IEs on filing form. [\#1500](https://github.com/fecgov/openFEC/pull/1500) ([jmcarp](https://github.com/jmcarp))

## [download-itemized](https://github.com/fecgov/openFEC/tree/download-itemized) (2016-02-06)

[Full Changelog](https://github.com/fecgov/openFEC/compare/fix-refresh-path...download-itemized)

**Closed issues:**

- Make electioneering and communication-costs endpoints sortable by disbursement\_date [\#1485](https://github.com/fecgov/openFEC/issues/1485)
- Discussion: Null candidate IDs in Schedule E [\#1478](https://github.com/fecgov/openFEC/issues/1478)
- Audit calendar microcopy [\#1475](https://github.com/fecgov/openFEC/issues/1475)

**Merged pull requests:**

- Handle related fields in data export. [\#1487](https://github.com/fecgov/openFEC/pull/1487) ([jmcarp](https://github.com/jmcarp))

## [fix-refresh-path](https://github.com/fecgov/openFEC/tree/fix-refresh-path) (2016-02-05)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-beta-20160203...fix-refresh-path)

**Merged pull requests:**

- Fix path to refresh task in scheduler. [\#1484](https://github.com/fecgov/openFEC/pull/1484) ([jmcarp](https://github.com/jmcarp))

## [public-beta-20160203](https://github.com/fecgov/openFEC/tree/public-beta-20160203) (2016-02-04)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-beta-20160106...public-beta-20160203)

**Closed issues:**

- Make API filter for candidates who ever raised $5000 [\#1468](https://github.com/fecgov/openFEC/issues/1468)
- Move back 18F updates to reduce lag. [\#1448](https://github.com/fecgov/openFEC/issues/1448)
- Discussion: Calendar filter logic [\#1442](https://github.com/fecgov/openFEC/issues/1442)
- Messy calendar data [\#1441](https://github.com/fecgov/openFEC/issues/1441)
- Release data exports [\#1438](https://github.com/fecgov/openFEC/issues/1438)
- Update individual function [\#1435](https://github.com/fecgov/openFEC/issues/1435)
- Handle itemized receipts from individuals with committee contributor IDs [\#1426](https://github.com/fecgov/openFEC/issues/1426)
- Williams totals really high [\#1424](https://github.com/fecgov/openFEC/issues/1424)
- Make necessary backend improvements for receipts and disbursement data exports [\#1414](https://github.com/fecgov/openFEC/issues/1414)
- Figure out Act Blue data [\#1410](https://github.com/fecgov/openFEC/issues/1410)
- Create endpoint for itemized communications costs [\#1404](https://github.com/fecgov/openFEC/issues/1404)
- Create end point for itemized electioneering communications [\#1403](https://github.com/fecgov/openFEC/issues/1403)
- Ensure stable sort for all views [\#1361](https://github.com/fecgov/openFEC/issues/1361)
- Why is actblue in this receipt search return set? [\#1308](https://github.com/fecgov/openFEC/issues/1308)
- Snowe records confusing [\#1248](https://github.com/fecgov/openFEC/issues/1248)

**Merged pull requests:**

- Release/public beta 20160203 [\#1483](https://github.com/fecgov/openFEC/pull/1483) ([jmcarp](https://github.com/jmcarp))
- Move to correct category [\#1482](https://github.com/fecgov/openFEC/pull/1482) ([LindsayYoung](https://github.com/LindsayYoung))
- Use ProxyFix middleware. [\#1481](https://github.com/fecgov/openFEC/pull/1481) ([jmcarp](https://github.com/jmcarp))
- Handle invalid dates in communication costs. [\#1477](https://github.com/fecgov/openFEC/pull/1477) ([jmcarp](https://github.com/jmcarp))
- Revert nginx proxy. [\#1465](https://github.com/fecgov/openFEC/pull/1465) ([jmcarp](https://github.com/jmcarp))
- Looking to update data 4 am eastern, 9 GMT to get fresher data [\#1458](https://github.com/fecgov/openFEC/pull/1458) ([LindsayYoung](https://github.com/LindsayYoung))
- Feature/indivual [\#1457](https://github.com/fecgov/openFEC/pull/1457) ([LindsayYoung](https://github.com/LindsayYoung))
- Filter on disbursement purpose category. [\#1456](https://github.com/fecgov/openFEC/pull/1456) ([jmcarp](https://github.com/jmcarp))
- Nullify index column on candidate aggregates. [\#1452](https://github.com/fecgov/openFEC/pull/1452) ([jmcarp](https://github.com/jmcarp))
- Whitelist independent expenditure downloads. [\#1451](https://github.com/fecgov/openFEC/pull/1451) ([jmcarp](https://github.com/jmcarp))
- Use election full flag in candidate history view. [\#1450](https://github.com/fecgov/openFEC/pull/1450) ([jmcarp](https://github.com/jmcarp))
- Feature/update start up docs [\#1445](https://github.com/fecgov/openFEC/pull/1445) ([LindsayYoung](https://github.com/LindsayYoung))
- \[WIP\] Feature/electioneering new table [\#1444](https://github.com/fecgov/openFEC/pull/1444) ([LindsayYoung](https://github.com/LindsayYoung))
- Ensure stable sort on aggregate tables. [\#1443](https://github.com/fecgov/openFEC/pull/1443) ([jmcarp](https://github.com/jmcarp))
- Add high-level tests for calendar exports. [\#1440](https://github.com/fecgov/openFEC/pull/1440) ([jmcarp](https://github.com/jmcarp))
- Add icalendar exports. [\#1421](https://github.com/fecgov/openFEC/pull/1421) ([jmcarp](https://github.com/jmcarp))
- Condense reporting deadline categories. [\#1419](https://github.com/fecgov/openFEC/pull/1419) ([jmcarp](https://github.com/jmcarp))
- Miscellaneous date cleanup. [\#1413](https://github.com/fecgov/openFEC/pull/1413) ([jmcarp](https://github.com/jmcarp))
- Feature/dates 2 \[WIP\] [\#1412](https://github.com/fecgov/openFEC/pull/1412) ([LindsayYoung](https://github.com/LindsayYoung))

## [public-beta-20160106](https://github.com/fecgov/openFEC/tree/public-beta-20160106) (2016-01-08)

[Full Changelog](https://github.com/fecgov/openFEC/compare/handle-mismatched-linkages...public-beta-20160106)

**Closed issues:**

- download counts:  display, manifest and csv [\#1430](https://github.com/fecgov/openFEC/issues/1430)
- Update committee filing dates [\#1428](https://github.com/fecgov/openFEC/issues/1428)
- Candidate H6TX25179 missing from election 2016 TX House 25 [\#1408](https://github.com/fecgov/openFEC/issues/1408)
- 404 for C00441014 [\#1407](https://github.com/fecgov/openFEC/issues/1407)
- Add remaining filters to schedule\_e endpoint [\#1405](https://github.com/fecgov/openFEC/issues/1405)
- Some schedule E data on dev doesn't show up on production [\#1392](https://github.com/fecgov/openFEC/issues/1392)
- Define filter output in download manifest [\#1391](https://github.com/fecgov/openFEC/issues/1391)
- Add remaining date data to the API [\#1385](https://github.com/fecgov/openFEC/issues/1385)
- Implement data download bundle [\#1383](https://github.com/fecgov/openFEC/issues/1383)
- Estimate times for data downloads [\#1380](https://github.com/fecgov/openFEC/issues/1380)
- Double-check that we have all election activity periods data in API [\#1357](https://github.com/fecgov/openFEC/issues/1357)
- In order to understand past/current behaviors, analyze existing FEC analytics on the legal system portion of fec.gov [\#1343](https://github.com/fecgov/openFEC/issues/1343)
- Create research plan for identifying needs around legal systems [\#1342](https://github.com/fecgov/openFEC/issues/1342)
- Candidate with FEC ID "P60014255" has `cand\_id` of "NULL" [\#1339](https://github.com/fecgov/openFEC/issues/1339)
- To help users find the most relevant results, develop a better method of weighting search and typeahead results [\#943](https://github.com/fecgov/openFEC/issues/943)

**Merged pull requests:**

- Update committee filing dates. [\#1431](https://github.com/fecgov/openFEC/pull/1431) ([jmcarp](https://github.com/jmcarp))
- Add support/oppose filter on itemized IEs. [\#1425](https://github.com/fecgov/openFEC/pull/1425) ([jmcarp](https://github.com/jmcarp))
- Expose full-text filter on committee treasurer name. [\#1417](https://github.com/fecgov/openFEC/pull/1417) ([jmcarp](https://github.com/jmcarp))
- Add full election flag to committee history view. [\#1411](https://github.com/fecgov/openFEC/pull/1411) ([jmcarp](https://github.com/jmcarp))
- Allow sorting candidates and committees by receipts. [\#1398](https://github.com/fecgov/openFEC/pull/1398) ([jmcarp](https://github.com/jmcarp))
- Ensure itemized queues are unique on corresponding primary key. [\#1393](https://github.com/fecgov/openFEC/pull/1393) ([jmcarp](https://github.com/jmcarp))
- \[WIP\] Feature/download utils [\#1363](https://github.com/fecgov/openFEC/pull/1363) ([jmcarp](https://github.com/jmcarp))

## [handle-mismatched-linkages](https://github.com/fecgov/openFEC/tree/handle-mismatched-linkages) (2015-12-23)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-beta-20151217...handle-mismatched-linkages)

**Closed issues:**

- Restrict candidate-committee linkages by committee type [\#1406](https://github.com/fecgov/openFEC/issues/1406)
- Weight candidate and committee search results page by relevance [\#1396](https://github.com/fecgov/openFEC/issues/1396)
- Add "Treasurer" filter to /committees [\#1389](https://github.com/fecgov/openFEC/issues/1389)
- In order to simplify contribution, change the bootstrap script to set up a local Cloud Foundry instance [\#1369](https://github.com/fecgov/openFEC/issues/1369)
- To help users find relevant committees, provide more emphasis on links to the candidate-committees on the candidate page [\#1168](https://github.com/fecgov/openFEC/issues/1168)

**Merged pull requests:**

- Ignore linkages with mismatched committee types. [\#1409](https://github.com/fecgov/openFEC/pull/1409) ([jmcarp](https://github.com/jmcarp))

## [public-beta-20151217](https://github.com/fecgov/openFEC/tree/public-beta-20151217) (2015-12-17)

[Full Changelog](https://github.com/fecgov/openFEC/compare/house-election-search...public-beta-20151217)

**Closed issues:**

- Round up to next election in candidate summaries [\#1400](https://github.com/fecgov/openFEC/issues/1400)
- Restrict data download resources [\#1395](https://github.com/fecgov/openFEC/issues/1395)
- Restrict election aggregates to election year [\#1382](https://github.com/fecgov/openFEC/issues/1382)
- Discussion: Capping data downloads [\#1378](https://github.com/fecgov/openFEC/issues/1378)
- Discussion: Expiring cached data downloads [\#1377](https://github.com/fecgov/openFEC/issues/1377)
- Add notifications for CF deployments [\#1375](https://github.com/fecgov/openFEC/issues/1375)
- Discussion: Redirect on incompatible cycle and election aggregate [\#1372](https://github.com/fecgov/openFEC/issues/1372)
- Discussion: Election aggregate interface [\#1371](https://github.com/fecgov/openFEC/issues/1371)
- Download queries as CSV [\#1356](https://github.com/fecgov/openFEC/issues/1356)
- Newt Gingrich not showing up as presidential candidate in 2012 [\#1051](https://github.com/fecgov/openFEC/issues/1051)

**Merged pull requests:**

- Release/public beta 20151217 [\#1401](https://github.com/fecgov/openFEC/pull/1401) ([jmcarp](https://github.com/jmcarp))
- Ensure unique candidate election years. [\#1399](https://github.com/fecgov/openFEC/pull/1399) ([jmcarp](https://github.com/jmcarp))
- Create temporary itemized tables to avoid downtime. [\#1397](https://github.com/fecgov/openFEC/pull/1397) ([jmcarp](https://github.com/jmcarp))
- Weight typeahead search by committee receipts. [\#1390](https://github.com/fecgov/openFEC/pull/1390) ([jmcarp](https://github.com/jmcarp))
- Fix election date args [\#1388](https://github.com/fecgov/openFEC/pull/1388) ([jmcarp](https://github.com/jmcarp))
- Feature/date upgrades [\#1387](https://github.com/fecgov/openFEC/pull/1387) ([jmcarp](https://github.com/jmcarp))
- Feature/update candidate data [\#1386](https://github.com/fecgov/openFEC/pull/1386) ([jmcarp](https://github.com/jmcarp))
- Feature/date upgrades [\#1384](https://github.com/fecgov/openFEC/pull/1384) ([LindsayYoung](https://github.com/LindsayYoung))
- Feature/notify deploy [\#1379](https://github.com/fecgov/openFEC/pull/1379) ([jmcarp](https://github.com/jmcarp))
- Feature/candidate nicknames [\#1374](https://github.com/fecgov/openFEC/pull/1374) ([jmcarp](https://github.com/jmcarp))
- Ignore test files on code climate. [\#1373](https://github.com/fecgov/openFEC/pull/1373) ([jmcarp](https://github.com/jmcarp))
- Log errors using Sentry. [\#1367](https://github.com/fecgov/openFEC/pull/1367) ([jmcarp](https://github.com/jmcarp))
- Feature/celery app [\#1366](https://github.com/fecgov/openFEC/pull/1366) ([jmcarp](https://github.com/jmcarp))
- adding schedule e aggregate information. [\#1365](https://github.com/fecgov/openFEC/pull/1365) ([LindsayYoung](https://github.com/LindsayYoung))
- openFEC about.yml updates [\#1362](https://github.com/fecgov/openFEC/pull/1362) ([gboone](https://github.com/gboone))
- Content edits [\#1360](https://github.com/fecgov/openFEC/pull/1360) ([emileighoutlaw](https://github.com/emileighoutlaw))
- Feature/nplusone [\#1359](https://github.com/fecgov/openFEC/pull/1359) ([jmcarp](https://github.com/jmcarp))
- adding data updated nightly to API docs [\#1351](https://github.com/fecgov/openFEC/pull/1351) ([LindsayYoung](https://github.com/LindsayYoung))
- Eliminates weather [\#1350](https://github.com/fecgov/openFEC/pull/1350) ([emileighoutlaw](https://github.com/emileighoutlaw))
- Remove all uses of dimlinkages from materialized views. [\#1349](https://github.com/fecgov/openFEC/pull/1349) ([jmcarp](https://github.com/jmcarp))
- Feature/capture email logs [\#1348](https://github.com/fecgov/openFEC/pull/1348) ([jmcarp](https://github.com/jmcarp))
- Pin node and buildpack versions. [\#1347](https://github.com/fecgov/openFEC/pull/1347) ([jmcarp](https://github.com/jmcarp))
- Censor duplicate committee IDs in itemized tables. [\#1340](https://github.com/fecgov/openFEC/pull/1340) ([jmcarp](https://github.com/jmcarp))
- Add manually entered districts to data import. [\#1336](https://github.com/fecgov/openFEC/pull/1336) ([jmcarp](https://github.com/jmcarp))
- Cache compiled dependencies for faster builds. [\#1334](https://github.com/fecgov/openFEC/pull/1334) ([jmcarp](https://github.com/jmcarp))
- Filter on derived `is\_individual` column. [\#1333](https://github.com/fecgov/openFEC/pull/1333) ([jmcarp](https://github.com/jmcarp))
- Feature/update individual receipt types [\#1332](https://github.com/fecgov/openFEC/pull/1332) ([jmcarp](https://github.com/jmcarp))
- Feature/deprecate dimlinkages [\#1331](https://github.com/fecgov/openFEC/pull/1331) ([jmcarp](https://github.com/jmcarp))
- Upgrade to latest version of flask-apispec. [\#1326](https://github.com/fecgov/openFEC/pull/1326) ([jmcarp](https://github.com/jmcarp))
- Feature/update committee data [\#1325](https://github.com/fecgov/openFEC/pull/1325) ([jmcarp](https://github.com/jmcarp))
- Delete unused files. [\#1322](https://github.com/fecgov/openFEC/pull/1322) ([jmcarp](https://github.com/jmcarp))
- Send email on nightly refresh. [\#1320](https://github.com/fecgov/openFEC/pull/1320) ([jmcarp](https://github.com/jmcarp))
- fixing milestones problem [\#1316](https://github.com/fecgov/openFEC/pull/1316) ([leahbannon](https://github.com/leahbannon))
- Standardizes readme language [\#1315](https://github.com/fecgov/openFEC/pull/1315) ([emileighoutlaw](https://github.com/emileighoutlaw))
- Wip dashboard updates [\#1313](https://github.com/fecgov/openFEC/pull/1313) ([leahbannon](https://github.com/leahbannon))
- Made fec\_bootstrap.sh exit if a command fails. [\#1311](https://github.com/fecgov/openFEC/pull/1311) ([evankroske](https://github.com/evankroske))
- Use committee designation on linkage table. [\#1301](https://github.com/fecgov/openFEC/pull/1301) ([jmcarp](https://github.com/jmcarp))

## [house-election-search](https://github.com/fecgov/openFEC/tree/house-election-search) (2015-11-26)

[Full Changelog](https://github.com/fecgov/openFEC/compare/clean-fulltext-query...house-election-search)

**Fixed bugs:**

- Bug: "Palouse Says Enough" listed as a principal committee for Bernie Sanders [\#1328](https://github.com/fecgov/openFEC/issues/1328)
- Some committee's schedule As and Bs not returned [\#1310](https://github.com/fecgov/openFEC/issues/1310)
- Recipient Name in disbursement browse [\#1306](https://github.com/fecgov/openFEC/issues/1306)
- Bug: Error when specifying cycle for committee C00315622 [\#1187](https://github.com/fecgov/openFEC/issues/1187)
- Bug: In order to have accurate committee addresses, separate PO boxes from street addressses [\#815](https://github.com/fecgov/openFEC/issues/815)
- Time traveling candidates [\#787](https://github.com/fecgov/openFEC/issues/787)

**Closed issues:**

- Which Schedule E itemizations are included in the aggregated candidate endpoint? [\#1364](https://github.com/fecgov/openFEC/issues/1364)
- Add links to storymap in READMEs [\#1358](https://github.com/fecgov/openFEC/issues/1358)
- Understand schema of existing legal database [\#1344](https://github.com/fecgov/openFEC/issues/1344)
- Bug: Cycle Select info disclaimer blocks use of cycle select [\#1341](https://github.com/fecgov/openFEC/issues/1341)
- Understanding Data Availability [\#1338](https://github.com/fecgov/openFEC/issues/1338)
- Where Does One Find a List of Candidate ID's? [\#1335](https://github.com/fecgov/openFEC/issues/1335)
- Revisit rules for individual contributions [\#1330](https://github.com/fecgov/openFEC/issues/1330)
- FEC Form 3, Post-election detailed summary page [\#1324](https://github.com/fecgov/openFEC/issues/1324)
- "false" is displaying on screen [\#1302](https://github.com/fecgov/openFEC/issues/1302)
- So that users understand our code, update READMEs on all repos [\#1297](https://github.com/fecgov/openFEC/issues/1297)
- Handle committees that file F3s before F1s [\#1287](https://github.com/fecgov/openFEC/issues/1287)
- contribution receipt date is 15 years in the future for schedule\_a endpoint [\#1286](https://github.com/fecgov/openFEC/issues/1286)
- data: cand status codes [\#1283](https://github.com/fecgov/openFEC/issues/1283)
- A list of the pre-launch tech miscellany [\#1279](https://github.com/fecgov/openFEC/issues/1279)
- coordinate on possible scripts to check for bad data [\#1249](https://github.com/fecgov/openFEC/issues/1249)
- primary/unique key in models such as filings & reports [\#1247](https://github.com/fecgov/openFEC/issues/1247)
- In order to make it easier to use fec\_bootstrap.sh, don't ignores command failures [\#1246](https://github.com/fecgov/openFEC/issues/1246)
- So users don't lose their place on the page, we won't jump to the top when closing glossary pane [\#1223](https://github.com/fecgov/openFEC/issues/1223)
- In order to accept large data sets during election season spike, we need to meet w/ FEC [\#1215](https://github.com/fecgov/openFEC/issues/1215)
- Need to write SLA w/ FEC [\#1214](https://github.com/fecgov/openFEC/issues/1214)
- In order to prevent users from seeing stale data, email results of nightly import / refresh to dev team on complete / fail. [\#1200](https://github.com/fecgov/openFEC/issues/1200)
- In order to show users the filing information most helpful to them, decide which columns to show and sort in the filings tab. [\#1198](https://github.com/fecgov/openFEC/issues/1198)
- In order to help users learn the size of the data set through the relative scale of the in-line bars, consider basing the scale on the whole data set, not just the page visible. [\#1197](https://github.com/fecgov/openFEC/issues/1197)
- incumbent challenger wording [\#1176](https://github.com/fecgov/openFEC/issues/1176)
- /schedules/shedule\* endpoints not returning event date [\#1132](https://github.com/fecgov/openFEC/issues/1132)
- load testing [\#1130](https://github.com/fecgov/openFEC/issues/1130)
- rate limiting [\#1075](https://github.com/fecgov/openFEC/issues/1075)
- Implement filing date solutions [\#1014](https://github.com/fecgov/openFEC/issues/1014)
- Hillary Clinton is showing up as running for election in 2000 and 2004 [\#964](https://github.com/fecgov/openFEC/issues/964)
- Coordinate launch with FEC press office [\#945](https://github.com/fecgov/openFEC/issues/945)
- Add ballot candidates back [\#849](https://github.com/fecgov/openFEC/issues/849)
- Fix API key and rate limiting for typeahead search [\#667](https://github.com/fecgov/openFEC/issues/667)
- Most recent .fec ID number for regular and senate filings [\#521](https://github.com/fecgov/openFEC/issues/521)
- Clarify timeliness of data [\#381](https://github.com/fecgov/openFEC/issues/381)
- As a reporter, I want a spreadsheet to to download analyze data. Add ability to export search results as a .csv [\#231](https://github.com/fecgov/openFEC/issues/231)
- Document eRegs API and Core server setup [\#205](https://github.com/fecgov/openFEC/issues/205)
- Note about expenditures [\#204](https://github.com/fecgov/openFEC/issues/204)
- API endpoints to populate filter form options [\#201](https://github.com/fecgov/openFEC/issues/201)
- Improve Electronic Filing RSS Feed [\#158](https://github.com/fecgov/openFEC/issues/158)

**Merged pull requests:**

- Show Senate and Presidential elections on district election search. [\#1368](https://github.com/fecgov/openFEC/pull/1368) ([jmcarp](https://github.com/jmcarp))

## [clean-fulltext-query](https://github.com/fecgov/openFEC/tree/clean-fulltext-query) (2015-11-05)

[Full Changelog](https://github.com/fecgov/openFEC/compare/ie-expire-date...clean-fulltext-query)

**Fixed bugs:**

- Bug: details panels don't always open on first click [\#1309](https://github.com/fecgov/openFEC/issues/1309)

## [ie-expire-date](https://github.com/fecgov/openFEC/tree/ie-expire-date) (2015-10-28)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-beta-20151026...ie-expire-date)

**Fixed bugs:**

- Missing a candidate [\#1299](https://github.com/fecgov/openFEC/issues/1299)
- problem retrieving schedule a contributions for senate candidate committees [\#1267](https://github.com/fecgov/openFEC/issues/1267)
- API returns no candidate records for some 2016 presidential form 2 filers  [\#1144](https://github.com/fecgov/openFEC/issues/1144)

**Merged pull requests:**

- Expose expiration date on IE reports. [\#1314](https://github.com/fecgov/openFEC/pull/1314) ([jmcarp](https://github.com/jmcarp))

## [public-beta-20151026](https://github.com/fecgov/openFEC/tree/public-beta-20151026) (2015-10-26)

[Full Changelog](https://github.com/fecgov/openFEC/compare/upgrade-flask-apispec...public-beta-20151026)

**Fixed bugs:**

- candidate search "Sanders, Bernard" returns an OOPS! [\#1304](https://github.com/fecgov/openFEC/issues/1304)
- Some Committee to Committee transactions not showing up [\#1294](https://github.com/fecgov/openFEC/issues/1294)

**Closed issues:**

- Cash on hand issue [\#1298](https://github.com/fecgov/openFEC/issues/1298)

**Merged pull requests:**

- Rebuild CHANGELOG. [\#1305](https://github.com/fecgov/openFEC/pull/1305) ([jmcarp](https://github.com/jmcarp))
- Use `greatest` instead of `coalesce` for missing values. [\#1300](https://github.com/fecgov/openFEC/pull/1300) ([jmcarp](https://github.com/jmcarp))
- Check for null entity type on filter. [\#1296](https://github.com/fecgov/openFEC/pull/1296) ([jmcarp](https://github.com/jmcarp))
- Temporarily fetch committee type from detail table. [\#1295](https://github.com/fecgov/openFEC/pull/1295) ([jmcarp](https://github.com/jmcarp))
- updating docs to match the new amended filtering \#1289 [\#1293](https://github.com/fecgov/openFEC/pull/1293) ([LindsayYoung](https://github.com/LindsayYoung))
- Handle multiple representations of null districts. [\#1292](https://github.com/fecgov/openFEC/pull/1292) ([jmcarp](https://github.com/jmcarp))
- Update LindsayYoung's case [\#1291](https://github.com/fecgov/openFEC/pull/1291) ([mbland](https://github.com/mbland))
- Serialize sub\_id values as strings. [\#1290](https://github.com/fecgov/openFEC/pull/1290) ([jmcarp](https://github.com/jmcarp))
- Included amended F3\* records. [\#1289](https://github.com/fecgov/openFEC/pull/1289) ([jmcarp](https://github.com/jmcarp))
- Exclude expired linkage rows from views. [\#1285](https://github.com/fecgov/openFEC/pull/1285) ([jmcarp](https://github.com/jmcarp))
- Get candidate office from `cand\_valid\_fec\_yr`. [\#1278](https://github.com/fecgov/openFEC/pull/1278) ([jmcarp](https://github.com/jmcarp))
- Hide district 99 from election search. [\#1277](https://github.com/fecgov/openFEC/pull/1277) ([jmcarp](https://github.com/jmcarp))
- Remove candidate status check in full text view. [\#1276](https://github.com/fecgov/openFEC/pull/1276) ([jmcarp](https://github.com/jmcarp))
- Remove election search filter on candidate status. [\#1273](https://github.com/fecgov/openFEC/pull/1273) ([jmcarp](https://github.com/jmcarp))
- Sort election results by district. [\#1272](https://github.com/fecgov/openFEC/pull/1272) ([jmcarp](https://github.com/jmcarp))
- Import election dates and Senate classes. [\#1259](https://github.com/fecgov/openFEC/pull/1259) ([jmcarp](https://github.com/jmcarp))
- Document for authority to operate beta release [\#1242](https://github.com/fecgov/openFEC/pull/1242) ([NoahKunin](https://github.com/NoahKunin))

## [upgrade-flask-apispec](https://github.com/fecgov/openFEC/tree/upgrade-flask-apispec) (2015-10-20)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-beta-20151014...upgrade-flask-apispec)

**Fixed bugs:**

- bug: candidate missing from search \(Larry Lessig\) [\#1275](https://github.com/fecgov/openFEC/issues/1275)
- bug: Incorrect office districts for various candidates [\#1271](https://github.com/fecgov/openFEC/issues/1271)

**Closed issues:**

- Contact URL in rate limit error is invalid. [\#1281](https://github.com/fecgov/openFEC/issues/1281)
- How soon after deadline are FEC Quarterly filings updated to the API? [\#1274](https://github.com/fecgov/openFEC/issues/1274)
- Add banner to dev and staging denoting them as such [\#1216](https://github.com/fecgov/openFEC/issues/1216)
- Add a filter for memo code on schedule A [\#1064](https://github.com/fecgov/openFEC/issues/1064)
- Some F1 filings in FEC Viewer but not Golden Gate [\#961](https://github.com/fecgov/openFEC/issues/961)
- Adding accordion sub-menu [\#898](https://github.com/fecgov/openFEC/issues/898)
- Chart tooltip appears behind bars [\#828](https://github.com/fecgov/openFEC/issues/828)
- Harmonize filters and column titles [\#772](https://github.com/fecgov/openFEC/issues/772)
- implement since for filing dates and load dates [\#266](https://github.com/fecgov/openFEC/issues/266)

**Merged pull requests:**

- \[hotfix\] Rename flask-smore to flask-apispec. [\#1282](https://github.com/fecgov/openFEC/pull/1282) ([jmcarp](https://github.com/jmcarp))

## [public-beta-20151014](https://github.com/fecgov/openFEC/tree/public-beta-20151014) (2015-10-14)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-beta-20150829...public-beta-20151014)

**Fixed bugs:**

- Bug Reporter display bug on smaller screen size  [\#1269](https://github.com/fecgov/openFEC/issues/1269)
- one last\_index value not returning results for Hillary for America [\#1263](https://github.com/fecgov/openFEC/issues/1263)
- Presidential data error [\#1251](https://github.com/fecgov/openFEC/issues/1251)
- candidate status issue [\#1244](https://github.com/fecgov/openFEC/issues/1244)
- Missing data on C00326801 [\#1232](https://github.com/fecgov/openFEC/issues/1232)
- Some totals variables are too high [\#1212](https://github.com/fecgov/openFEC/issues/1212)
- First file date for form 5 only filers [\#1209](https://github.com/fecgov/openFEC/issues/1209)
- Contributor\_occupation in sched A broken [\#1208](https://github.com/fecgov/openFEC/issues/1208)
- API, candidate/committees: Results does not reflect count value [\#1112](https://github.com/fecgov/openFEC/issues/1112)
- Version number on dev api wrong [\#1103](https://github.com/fecgov/openFEC/issues/1103)

**Closed issues:**

- User feedback on http://localhost:3000 [\#1266](https://github.com/fecgov/openFEC/issues/1266)
- User feedback on http://localhost:3000 [\#1265](https://github.com/fecgov/openFEC/issues/1265)
- Create aggregates for pre-2011 receipts and disbursements [\#1250](https://github.com/fecgov/openFEC/issues/1250)
- Form F11 filings have report\_year set to 0 [\#1235](https://github.com/fecgov/openFEC/issues/1235)
- Identify amended Schedule E transactions [\#1226](https://github.com/fecgov/openFEC/issues/1226)
- possible gov shutdown language [\#1225](https://github.com/fecgov/openFEC/issues/1225)
- committees button too small, cutting off word [\#1222](https://github.com/fecgov/openFEC/issues/1222)
- Social media metadata needed for CMS sites [\#1217](https://github.com/fecgov/openFEC/issues/1217)
- Double check coverage dates [\#1205](https://github.com/fecgov/openFEC/issues/1205)
- Improve performance on receipts and disbursements queries [\#1204](https://github.com/fecgov/openFEC/issues/1204)
- Receipt aggregates by contributor type are overestimated [\#1203](https://github.com/fecgov/openFEC/issues/1203)
- disclaimer: election pages vs. actual candidates really running [\#1193](https://github.com/fecgov/openFEC/issues/1193)
- Poor Documentation [\#1191](https://github.com/fecgov/openFEC/issues/1191)
- clean data [\#1189](https://github.com/fecgov/openFEC/issues/1189)
- Super PACs check box on browse committees is often obscured by the PACs dropdown [\#1185](https://github.com/fecgov/openFEC/issues/1185)
- Usability Testers were not able to find Super PACs support/oppose information [\#1183](https://github.com/fecgov/openFEC/issues/1183)
- 404 page needs minor improvements [\#1180](https://github.com/fecgov/openFEC/issues/1180)
- Prepare for presentation [\#1178](https://github.com/fecgov/openFEC/issues/1178)
- Content review of api docs before launch [\#1177](https://github.com/fecgov/openFEC/issues/1177)
- Browse Page Filter w/o autocomplete needs an "apply" target [\#1170](https://github.com/fecgov/openFEC/issues/1170)
- Differentiate registration actions from registration learning links [\#1169](https://github.com/fecgov/openFEC/issues/1169)
- Differentiate Glossary links from normal links [\#1167](https://github.com/fecgov/openFEC/issues/1167)
- Inconsistent data in cand\_valid\_fec\_yr [\#1166](https://github.com/fecgov/openFEC/issues/1166)
- Committee Filings Tab duplicating operating expenditures [\#1158](https://github.com/fecgov/openFEC/issues/1158)
- Amendment Indicator should only have New or Amended on Candidate filings tab \(issue \#1\) [\#1154](https://github.com/fecgov/openFEC/issues/1154)
- Questionable link on candidate pages [\#1153](https://github.com/fecgov/openFEC/issues/1153)
- Record web analytics? [\#1146](https://github.com/fecgov/openFEC/issues/1146)
- Handle receipts duplicates [\#1141](https://github.com/fecgov/openFEC/issues/1141)
- by\_size aggregate endpoints missing data [\#1138](https://github.com/fecgov/openFEC/issues/1138)
- Add party and challenge / incumbent status to candidate comparison table [\#1106](https://github.com/fecgov/openFEC/issues/1106)
- Add line number filtering to schedule A [\#1102](https://github.com/fecgov/openFEC/issues/1102)
- Add itemized electioneering [\#1099](https://github.com/fecgov/openFEC/issues/1099)
- Filings browse view [\#1028](https://github.com/fecgov/openFEC/issues/1028)
- Disambiguate typeahead results for Scott Brown [\#955](https://github.com/fecgov/openFEC/issues/955)
- review blog post draft [\#953](https://github.com/fecgov/openFEC/issues/953)
- switch out state and committee start date [\#886](https://github.com/fecgov/openFEC/issues/886)
- Update Joint Fundraiser page to show that related candidate list not exhaustive [\#848](https://github.com/fecgov/openFEC/issues/848)
- possible alpha header warning tweaks [\#786](https://github.com/fecgov/openFEC/issues/786)
- Multiple principal campaign committees [\#776](https://github.com/fecgov/openFEC/issues/776)
- Link to API from webapp frontpage [\#737](https://github.com/fecgov/openFEC/issues/737)
- Throw appropriate error on empty results [\#724](https://github.com/fecgov/openFEC/issues/724)
- Shorten candidate status values [\#697](https://github.com/fecgov/openFEC/issues/697)
- Hide header search bar on home page [\#668](https://github.com/fecgov/openFEC/issues/668)
- open thread: feedback from \#hack4congress [\#664](https://github.com/fecgov/openFEC/issues/664)
- Display "No data" if committees have no financial reports filed [\#622](https://github.com/fecgov/openFEC/issues/622)
- Create a System Diagram [\#591](https://github.com/fecgov/openFEC/issues/591)
- DAP integration [\#573](https://github.com/fecgov/openFEC/issues/573)
- Procure secondary FEC URL for API [\#546](https://github.com/fecgov/openFEC/issues/546)
- Fill out committee summary page templates [\#513](https://github.com/fecgov/openFEC/issues/513)
- Fill out candidate page charts with quarters data [\#510](https://github.com/fecgov/openFEC/issues/510)
- Financials for principal committees not showing up on many single candidate pages [\#495](https://github.com/fecgov/openFEC/issues/495)
- Check all API endpoints for actually-unique keys [\#450](https://github.com/fecgov/openFEC/issues/450)
- Update readme with more accurate setup instructions [\#338](https://github.com/fecgov/openFEC/issues/338)
- FEC-centric eRegs usefulness testing [\#303](https://github.com/fecgov/openFEC/issues/303)
- Fix eRegs links [\#241](https://github.com/fecgov/openFEC/issues/241)
- Send user to single entity page if only 1 result [\#217](https://github.com/fecgov/openFEC/issues/217)
- Get eRegs to parse 11 CFR 110 without error [\#184](https://github.com/fecgov/openFEC/issues/184)
- Make sure Upload data and Received date are both searchable and sortable from the API [\#159](https://github.com/fecgov/openFEC/issues/159)

**Merged pull requests:**

- Release/public beta 20151014 [\#1270](https://github.com/fecgov/openFEC/pull/1270) ([jmcarp](https://github.com/jmcarp))
- Feature/change log [\#1268](https://github.com/fecgov/openFEC/pull/1268) ([LindsayYoung](https://github.com/LindsayYoung))
- Revert temporary fix for dependency conflicts. [\#1261](https://github.com/fecgov/openFEC/pull/1261) ([jmcarp](https://github.com/jmcarp))
- Further simplify report year logic. [\#1260](https://github.com/fecgov/openFEC/pull/1260) ([jmcarp](https://github.com/jmcarp))
- Aggregate itemized reports back to 2007. [\#1258](https://github.com/fecgov/openFEC/pull/1258) ([jmcarp](https://github.com/jmcarp))
- defined electioneering  [\#1257](https://github.com/fecgov/openFEC/pull/1257) ([LindsayYoung](https://github.com/LindsayYoung))
- Update travis secrets. [\#1256](https://github.com/fecgov/openFEC/pull/1256) ([jmcarp](https://github.com/jmcarp))
- Remove temporary workarounds around filings report years. [\#1255](https://github.com/fecgov/openFEC/pull/1255) ([jmcarp](https://github.com/jmcarp))
- Parse args from querystring. [\#1254](https://github.com/fecgov/openFEC/pull/1254) ([jmcarp](https://github.com/jmcarp))
- Feature/upgrade deps [\#1253](https://github.com/fecgov/openFEC/pull/1253) ([jmcarp](https://github.com/jmcarp))
- limiting typeahead [\#1252](https://github.com/fecgov/openFEC/pull/1252) ([LindsayYoung](https://github.com/LindsayYoung))
- Improve the cycle selection for candidates [\#1245](https://github.com/fecgov/openFEC/pull/1245) ([LindsayYoung](https://github.com/LindsayYoung))
- Feature/doc clean [\#1243](https://github.com/fecgov/openFEC/pull/1243) ([LindsayYoung](https://github.com/LindsayYoung))
- Revert "Restrict active elections and cycles to F2 filings." [\#1241](https://github.com/fecgov/openFEC/pull/1241) ([LindsayYoung](https://github.com/LindsayYoung))
- Restore API key to docs in production. [\#1240](https://github.com/fecgov/openFEC/pull/1240) ([jmcarp](https://github.com/jmcarp))
- Restrict active elections and cycles to F2 filings. [\#1239](https://github.com/fecgov/openFEC/pull/1239) ([jmcarp](https://github.com/jmcarp))
- Being up front about changes [\#1238](https://github.com/fecgov/openFEC/pull/1238) ([LindsayYoung](https://github.com/LindsayYoung))
- Exclude filings with missing report years from cycle aggregation. [\#1236](https://github.com/fecgov/openFEC/pull/1236) ([jmcarp](https://github.com/jmcarp))
- edits to simplify the docs a bit [\#1233](https://github.com/fecgov/openFEC/pull/1233) ([leahbannon](https://github.com/leahbannon))
- Combine transactions from `sched\_e` and `form\_57` tables. [\#1230](https://github.com/fecgov/openFEC/pull/1230) ([jmcarp](https://github.com/jmcarp))
- Restrict Schedule E aggregates to form F3X. [\#1227](https://github.com/fecgov/openFEC/pull/1227) ([jmcarp](https://github.com/jmcarp))
- Fix image number representations. [\#1224](https://github.com/fecgov/openFEC/pull/1224) ([jmcarp](https://github.com/jmcarp))
- Add cycle filter on Schedule E resource. [\#1221](https://github.com/fecgov/openFEC/pull/1221) ([jmcarp](https://github.com/jmcarp))
- Added contact info back [\#1220](https://github.com/fecgov/openFEC/pull/1220) ([LindsayYoung](https://github.com/LindsayYoung))
- Use distinct queries for candidate and committee resources. [\#1219](https://github.com/fecgov/openFEC/pull/1219) ([jmcarp](https://github.com/jmcarp))
- Separate import and read itemized tables. [\#1218](https://github.com/fecgov/openFEC/pull/1218) ([jmcarp](https://github.com/jmcarp))
- Feature/fix cumulative totals [\#1213](https://github.com/fecgov/openFEC/pull/1213) ([jmcarp](https://github.com/jmcarp))
- Remove contributor type aggregate. [\#1211](https://github.com/fecgov/openFEC/pull/1211) ([jmcarp](https://github.com/jmcarp))
- Made committee first file date with the filings table.  [\#1210](https://github.com/fecgov/openFEC/pull/1210) ([LindsayYoung](https://github.com/LindsayYoung))
- Use more restrictive join between candidates and committees. [\#1207](https://github.com/fecgov/openFEC/pull/1207) ([jmcarp](https://github.com/jmcarp))
- Add sorting on related columns. [\#1206](https://github.com/fecgov/openFEC/pull/1206) ([jmcarp](https://github.com/jmcarp))
- Use all filings to get active committee years. [\#1202](https://github.com/fecgov/openFEC/pull/1202) ([jmcarp](https://github.com/jmcarp))
- Add web analytics to Swagger-UI. [\#1199](https://github.com/fecgov/openFEC/pull/1199) ([jmcarp](https://github.com/jmcarp))
- Exclude inactive candidates from election views. [\#1196](https://github.com/fecgov/openFEC/pull/1196) ([jmcarp](https://github.com/jmcarp))
- Fix concurrent refresh; add regression test. [\#1194](https://github.com/fecgov/openFEC/pull/1194) ([jmcarp](https://github.com/jmcarp))
- Move generic helpers and Swagger tools to flask-smore. [\#1192](https://github.com/fecgov/openFEC/pull/1192) ([jmcarp](https://github.com/jmcarp))
- Generalize and document itemized committee queries. [\#1190](https://github.com/fecgov/openFEC/pull/1190) ([jmcarp](https://github.com/jmcarp))
- Add election summary endpoint. [\#1188](https://github.com/fecgov/openFEC/pull/1188) ([jmcarp](https://github.com/jmcarp))
- Feature/more zips [\#1186](https://github.com/fecgov/openFEC/pull/1186) ([LindsayYoung](https://github.com/LindsayYoung))
- Adding the rate limit information, page limit and link to bulk data. [\#1182](https://github.com/fecgov/openFEC/pull/1182) ([LindsayYoung](https://github.com/LindsayYoung))
- Feature/organize models [\#1181](https://github.com/fecgov/openFEC/pull/1181) ([jmcarp](https://github.com/jmcarp))
- Include list of election districts in candidate summaries. [\#1179](https://github.com/fecgov/openFEC/pull/1179) ([jmcarp](https://github.com/jmcarp))
- Use consistent names for individual contributions. [\#1175](https://github.com/fecgov/openFEC/pull/1175) ([jmcarp](https://github.com/jmcarp))
- Fix last cash on hand. [\#1174](https://github.com/fecgov/openFEC/pull/1174) ([jmcarp](https://github.com/jmcarp))
- Use base resource class to avoid duplicated code. [\#1173](https://github.com/fecgov/openFEC/pull/1173) ([jmcarp](https://github.com/jmcarp))
- Feature/document enhancement [\#1172](https://github.com/fecgov/openFEC/pull/1172) ([LindsayYoung](https://github.com/LindsayYoung))
- Build receipts aggregate by contributor committee. [\#1171](https://github.com/fecgov/openFEC/pull/1171) ([jmcarp](https://github.com/jmcarp))
- Feature/election search incumbent [\#1165](https://github.com/fecgov/openFEC/pull/1165) ([jmcarp](https://github.com/jmcarp))
- Move swagger logic to smore. [\#1164](https://github.com/fecgov/openFEC/pull/1164) ([jmcarp](https://github.com/jmcarp))
- Unify base resource classes. [\#1151](https://github.com/fecgov/openFEC/pull/1151) ([jmcarp](https://github.com/jmcarp))
- Feature/external pagination [\#1150](https://github.com/fecgov/openFEC/pull/1150) ([jmcarp](https://github.com/jmcarp))

## [public-beta-20150829](https://github.com/fecgov/openFEC/tree/public-beta-20150829) (2015-09-03)

[Full Changelog](https://github.com/fecgov/openFEC/compare/page-cap-redux...public-beta-20150829)

**Fixed bugs:**

- API throws 502 error with a per\_page value of 10000 [\#716](https://github.com/fecgov/openFEC/issues/716)

**Closed issues:**

- I created an example python implementation to fetch data from the api [\#1161](https://github.com/fecgov/openFEC/issues/1161)
- Filings search report type order [\#1160](https://github.com/fecgov/openFEC/issues/1160)
- Filings search form 1 [\#1159](https://github.com/fecgov/openFEC/issues/1159)
- Candidate Filings list not showing Form 2 on candidate filings tab \(issue \#4\) [\#1157](https://github.com/fecgov/openFEC/issues/1157)
- Report Type should be Removed from Candidate Filings Tab \(tab issue \#3\) [\#1156](https://github.com/fecgov/openFEC/issues/1156)
- Election Type should be removed from Candidate Filings Tab \(issue \#2\) [\#1155](https://github.com/fecgov/openFEC/issues/1155)
- Candidate page summary amounts and rounding [\#1152](https://github.com/fecgov/openFEC/issues/1152)
- by\_state and by\_zip aggregate endpoints 500'ing [\#1137](https://github.com/fecgov/openFEC/issues/1137)
- Verify totals on first candidate comparison table on elections page are correct [\#1110](https://github.com/fecgov/openFEC/issues/1110)
- email and url fields? [\#1070](https://github.com/fecgov/openFEC/issues/1070)
- Add api key sign-up on docs page [\#1060](https://github.com/fecgov/openFEC/issues/1060)
- Sample CMS [\#1029](https://github.com/fecgov/openFEC/issues/1029)
- make sure we are dealing with different year-to-date on front end [\#1026](https://github.com/fecgov/openFEC/issues/1026)
- spin up example CMSes [\#1015](https://github.com/fecgov/openFEC/issues/1015)
- Implement filing tables on committee pages [\#1001](https://github.com/fecgov/openFEC/issues/1001)
- "View Charts" button doesn't do anything if an Authorized Committee has no financial data [\#969](https://github.com/fecgov/openFEC/issues/969)
- Add label to Glossary link at top of page [\#910](https://github.com/fecgov/openFEC/issues/910)
- Right end of office text cut off in typeahead [\#909](https://github.com/fecgov/openFEC/issues/909)
- Split assets [\#908](https://github.com/fecgov/openFEC/issues/908)
- Allow users to toggle between list and table views [\#903](https://github.com/fecgov/openFEC/issues/903)
- Add better responses at root API URLs [\#860](https://github.com/fecgov/openFEC/issues/860)
- Tests for totals [\#827](https://github.com/fecgov/openFEC/issues/827)
- Use districts from dimcandproperties [\#794](https://github.com/fecgov/openFEC/issues/794)
- Create open graph tags [\#725](https://github.com/fecgov/openFEC/issues/725)
- Respect caching headers [\#721](https://github.com/fecgov/openFEC/issues/721)
- Create z-index variables  [\#709](https://github.com/fecgov/openFEC/issues/709)
- Prepare for API release [\#660](https://github.com/fecgov/openFEC/issues/660)
- Make sure candidate committee linkages are not misrepresented  [\#517](https://github.com/fecgov/openFEC/issues/517)
- Run Card Sorting Exercise [\#508](https://github.com/fecgov/openFEC/issues/508)
- Generate cumulative report totals by quarter [\#496](https://github.com/fecgov/openFEC/issues/496)
- Clean up API code [\#443](https://github.com/fecgov/openFEC/issues/443)
- Evaluate and rewrite or remove skipped tests [\#442](https://github.com/fecgov/openFEC/issues/442)
- Have code references in the API itself [\#373](https://github.com/fecgov/openFEC/issues/373)
- Make sure all tables are importing [\#357](https://github.com/fecgov/openFEC/issues/357)
- Consider showing /totals data in candidate & committee results tables [\#346](https://github.com/fecgov/openFEC/issues/346)
- Create official location for API documentation [\#297](https://github.com/fecgov/openFEC/issues/297)
- Broaden search capabilites [\#291](https://github.com/fecgov/openFEC/issues/291)
- Implement hiding extra related entities in code [\#263](https://github.com/fecgov/openFEC/issues/263)
- Begin looking at documents endpoint [\#242](https://github.com/fecgov/openFEC/issues/242)
-  Informative message needed when REST server gets bad arg [\#198](https://github.com/fecgov/openFEC/issues/198)
- Receipts endpoint [\#179](https://github.com/fecgov/openFEC/issues/179)
- filings endpoint [\#178](https://github.com/fecgov/openFEC/issues/178)
- Allow users to use abbreviations in State filter [\#130](https://github.com/fecgov/openFEC/issues/130)
- Research compliance professional's search workflow [\#16](https://github.com/fecgov/openFEC/issues/16)

**Merged pull requests:**

- Release/public beta 20150829 [\#1163](https://github.com/fecgov/openFEC/pull/1163) ([jmcarp](https://github.com/jmcarp))
- Use detailed query statistics. [\#1162](https://github.com/fecgov/openFEC/pull/1162) ([jmcarp](https://github.com/jmcarp))
- Allow filtering receipts on multiple committees. [\#1149](https://github.com/fecgov/openFEC/pull/1149) ([jmcarp](https://github.com/jmcarp))
- Include F1 filings in filings endpoint. [\#1148](https://github.com/fecgov/openFEC/pull/1148) ([jmcarp](https://github.com/jmcarp))
- Feature/handle duplicate receipts [\#1143](https://github.com/fecgov/openFEC/pull/1143) ([jmcarp](https://github.com/jmcarp))
- Add electioneering costs by candidate. [\#1142](https://github.com/fecgov/openFEC/pull/1142) ([jmcarp](https://github.com/jmcarp))
- Feature/com cost [\#1140](https://github.com/fecgov/openFEC/pull/1140) ([jmcarp](https://github.com/jmcarp))
- Use `tuple\_` expression for row value filters. [\#1139](https://github.com/fecgov/openFEC/pull/1139) ([jmcarp](https://github.com/jmcarp))
- Fix filtering on filings view. [\#1136](https://github.com/fecgov/openFEC/pull/1136) ([jmcarp](https://github.com/jmcarp))
- Aggregate independent expenditures. [\#1135](https://github.com/fecgov/openFEC/pull/1135) ([jmcarp](https://github.com/jmcarp))
- Fix sort by date on seek pagination. [\#1134](https://github.com/fecgov/openFEC/pull/1134) ([jmcarp](https://github.com/jmcarp))
- Feature/contibutor variables [\#1133](https://github.com/fecgov/openFEC/pull/1133) ([LindsayYoung](https://github.com/LindsayYoung))
- Feature/communicaiton cost [\#1131](https://github.com/fecgov/openFEC/pull/1131) ([LindsayYoung](https://github.com/LindsayYoung))
- Index `office\_full`. [\#1129](https://github.com/fecgov/openFEC/pull/1129) ([jmcarp](https://github.com/jmcarp))
- Add candidate filings endpoint. [\#1128](https://github.com/fecgov/openFEC/pull/1128) ([jmcarp](https://github.com/jmcarp))
- Fix failing tests. [\#1127](https://github.com/fecgov/openFEC/pull/1127) ([jmcarp](https://github.com/jmcarp))
- Hide extraneous races from election lookup. [\#1126](https://github.com/fecgov/openFEC/pull/1126) ([jmcarp](https://github.com/jmcarp))
- Update test subset. [\#1125](https://github.com/fecgov/openFEC/pull/1125) ([jmcarp](https://github.com/jmcarp))
- Handle numeric congressional districts. [\#1124](https://github.com/fecgov/openFEC/pull/1124) ([jmcarp](https://github.com/jmcarp))
- Add script to output district count per state. [\#1123](https://github.com/fecgov/openFEC/pull/1123) ([jmcarp](https://github.com/jmcarp))
- Revert temporary workaround for missing receipt dates. [\#1122](https://github.com/fecgov/openFEC/pull/1122) ([jmcarp](https://github.com/jmcarp))
- Use Flask-CORS for more robust CORS configuration. [\#1121](https://github.com/fecgov/openFEC/pull/1121) ([jmcarp](https://github.com/jmcarp))
- Fix error on empty elections. [\#1120](https://github.com/fecgov/openFEC/pull/1120) ([jmcarp](https://github.com/jmcarp))
- Feature/fix filings pdfs [\#1119](https://github.com/fecgov/openFEC/pull/1119) ([jmcarp](https://github.com/jmcarp))
- Expose control over null order. [\#1118](https://github.com/fecgov/openFEC/pull/1118) ([jmcarp](https://github.com/jmcarp))
- Include committee IDs in election view endpoint. [\#1116](https://github.com/fecgov/openFEC/pull/1116) ([jmcarp](https://github.com/jmcarp))
- Feature/fix data types [\#1115](https://github.com/fecgov/openFEC/pull/1115) ([jmcarp](https://github.com/jmcarp))
- Feature/documention page updates [\#1114](https://github.com/fecgov/openFEC/pull/1114) ([LindsayYoung](https://github.com/LindsayYoung))
- Add .about.yml. [\#1111](https://github.com/fecgov/openFEC/pull/1111) ([jmcarp](https://github.com/jmcarp))
- Add election search view. [\#1109](https://github.com/fecgov/openFEC/pull/1109) ([jmcarp](https://github.com/jmcarp))
- Improve election views. [\#1108](https://github.com/fecgov/openFEC/pull/1108) ([jmcarp](https://github.com/jmcarp))
- Join designation by form ID. [\#1107](https://github.com/fecgov/openFEC/pull/1107) ([jmcarp](https://github.com/jmcarp))
- Filter receipts on contributor occupation. [\#1105](https://github.com/fecgov/openFEC/pull/1105) ([jmcarp](https://github.com/jmcarp))
- Miscellaneous updates for election pages. [\#1104](https://github.com/fecgov/openFEC/pull/1104) ([jmcarp](https://github.com/jmcarp))
- Feature/schedule e [\#1101](https://github.com/fecgov/openFEC/pull/1101) ([jmcarp](https://github.com/jmcarp))
- Rebuild test subset from staging. [\#1096](https://github.com/fecgov/openFEC/pull/1096) ([jmcarp](https://github.com/jmcarp))
- Separate aggregate tasks into rebuild and update. [\#1095](https://github.com/fecgov/openFEC/pull/1095) ([jmcarp](https://github.com/jmcarp))
- Restrict most aggregates to individual contributions. [\#1094](https://github.com/fecgov/openFEC/pull/1094) ([jmcarp](https://github.com/jmcarp))
- Restrict election filter to running candidates. [\#1093](https://github.com/fecgov/openFEC/pull/1093) ([jmcarp](https://github.com/jmcarp))
- Feature/documentation tweaks [\#1091](https://github.com/fecgov/openFEC/pull/1091) ([LindsayYoung](https://github.com/LindsayYoung))
- Use case-insensitive arguments where appropriate. [\#1088](https://github.com/fecgov/openFEC/pull/1088) ([jmcarp](https://github.com/jmcarp))
- Feature/aggregate contributor type [\#1087](https://github.com/fecgov/openFEC/pull/1087) ([jmcarp](https://github.com/jmcarp))
- Feature/aggregates by candidate [\#1086](https://github.com/fecgov/openFEC/pull/1086) ([jmcarp](https://github.com/jmcarp))
- WIP Feature/reporting dates [\#1085](https://github.com/fecgov/openFEC/pull/1085) ([LindsayYoung](https://github.com/LindsayYoung))
- Feature/sum election filings [\#1083](https://github.com/fecgov/openFEC/pull/1083) ([jmcarp](https://github.com/jmcarp))
- Small doc improvements for this awesome endpoint! [\#1082](https://github.com/fecgov/openFEC/pull/1082) ([LindsayYoung](https://github.com/LindsayYoung))
- Feature/election data [\#1080](https://github.com/fecgov/openFEC/pull/1080) ([jmcarp](https://github.com/jmcarp))
- \[dontmerge\] release/public-beta-20150722 [\#1079](https://github.com/fecgov/openFEC/pull/1079) ([jmcarp](https://github.com/jmcarp))
- Feature/pretty report names [\#1078](https://github.com/fecgov/openFEC/pull/1078) ([LindsayYoung](https://github.com/LindsayYoung))
- Add full-text search on disbursement purpose. [\#1076](https://github.com/fecgov/openFEC/pull/1076) ([jmcarp](https://github.com/jmcarp))
- Feature/recipient aggregate [\#1074](https://github.com/fecgov/openFEC/pull/1074) ([jmcarp](https://github.com/jmcarp))
- adding demo key by default to make it easier to try out. [\#1073](https://github.com/fecgov/openFEC/pull/1073) ([LindsayYoung](https://github.com/LindsayYoung))
- adding candidate\_filering to filings [\#1072](https://github.com/fecgov/openFEC/pull/1072) ([LindsayYoung](https://github.com/LindsayYoung))
- Add state labels to zip code aggregate. [\#1069](https://github.com/fecgov/openFEC/pull/1069) ([jmcarp](https://github.com/jmcarp))
- Leah docs edits [\#1068](https://github.com/fecgov/openFEC/pull/1068) ([leahbannon](https://github.com/leahbannon))
- Feature/add purpose [\#1067](https://github.com/fecgov/openFEC/pull/1067) ([jmcarp](https://github.com/jmcarp))
- Feature/add aggregates [\#1061](https://github.com/fecgov/openFEC/pull/1061) ([jmcarp](https://github.com/jmcarp))
- Filter contributor aggregates by contributor type. [\#1054](https://github.com/fecgov/openFEC/pull/1054) ([jmcarp](https://github.com/jmcarp))

## [page-cap-redux](https://github.com/fecgov/openFEC/tree/page-cap-redux) (2015-08-14)

[Full Changelog](https://github.com/fecgov/openFEC/compare/18f.gov...page-cap-redux)

**Fixed bugs:**

- API server randomly returns empty results [\#1113](https://github.com/fecgov/openFEC/issues/1113)

**Closed issues:**

- Add individulal transfers [\#1100](https://github.com/fecgov/openFEC/issues/1100)
- Add Schedule E [\#1097](https://github.com/fecgov/openFEC/issues/1097)
- Whitelist change [\#1092](https://github.com/fecgov/openFEC/issues/1092)
- Expose aggregates by candidate [\#1084](https://github.com/fecgov/openFEC/issues/1084)
- look at staging data [\#1016](https://github.com/fecgov/openFEC/issues/1016)
- Aggregate Schedule A receipts [\#1006](https://github.com/fecgov/openFEC/issues/1006)
- Implement Schedule A filters [\#1000](https://github.com/fecgov/openFEC/issues/1000)
- candidate count low [\#988](https://github.com/fecgov/openFEC/issues/988)
- /candidates and /candidates/search redundant? [\#981](https://github.com/fecgov/openFEC/issues/981)
- Ethnio [\#946](https://github.com/fecgov/openFEC/issues/946)

## [18f.gov](https://github.com/fecgov/openFEC/tree/18f.gov) (2015-07-30)

[Full Changelog](https://github.com/fecgov/openFEC/compare/cap-per-page...18f.gov)

**Closed issues:**

- Recruit users for next round of usability testing [\#1027](https://github.com/fecgov/openFEC/issues/1027)
- Show summaries for IE only spenders [\#939](https://github.com/fecgov/openFEC/issues/939)

**Merged pull requests:**

- \[dontmerge\] Hotfix/18f.gov [\#1089](https://github.com/fecgov/openFEC/pull/1089) ([jmcarp](https://github.com/jmcarp))

## [cap-per-page](https://github.com/fecgov/openFEC/tree/cap-per-page) (2015-07-23)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-beta-20150713...cap-per-page)

**Closed issues:**

- Add demo key [\#1066](https://github.com/fecgov/openFEC/issues/1066)
- Find records by contributor name [\#1049](https://github.com/fecgov/openFEC/issues/1049)
- Build election pages front end [\#1030](https://github.com/fecgov/openFEC/issues/1030)
- Default to closed filters on mobile and tablet [\#967](https://github.com/fecgov/openFEC/issues/967)
- Blog post [\#944](https://github.com/fecgov/openFEC/issues/944)
- API documentation language review [\#775](https://github.com/fecgov/openFEC/issues/775)

**Merged pull requests:**

- Hotfix/cap per page [\#1081](https://github.com/fecgov/openFEC/pull/1081) ([jmcarp](https://github.com/jmcarp))
- Add Ethnio link. [\#1071](https://github.com/fecgov/openFEC/pull/1071) ([jmcarp](https://github.com/jmcarp))
- added our variable name and we use a boolean [\#1063](https://github.com/fecgov/openFEC/pull/1063) ([LindsayYoung](https://github.com/LindsayYoung))
- Link to data restrictions in API docs. [\#1044](https://github.com/fecgov/openFEC/pull/1044) ([jmcarp](https://github.com/jmcarp))
- Hotfix/redirect to developers [\#1042](https://github.com/fecgov/openFEC/pull/1042) ([jmcarp](https://github.com/jmcarp))

## [public-beta-20150713](https://github.com/fecgov/openFEC/tree/public-beta-20150713) (2015-07-15)

[Full Changelog](https://github.com/fecgov/openFEC/compare/public-beta...public-beta-20150713)

**Fixed bugs:**

- Missing results in `candidate/id/committees` [\#986](https://github.com/fecgov/openFEC/issues/986)

**Closed issues:**

- Route staging traffic through API Umbrella [\#1053](https://github.com/fecgov/openFEC/issues/1053)
- consider a redirect from api.open.fec.gov [\#1048](https://github.com/fecgov/openFEC/issues/1048)
- set up redirect from /developer [\#1045](https://github.com/fecgov/openFEC/issues/1045)
- Figure out what information will be included in dates and dealines endpoint [\#1025](https://github.com/fecgov/openFEC/issues/1025)
- Pin requirement versions [\#1019](https://github.com/fecgov/openFEC/issues/1019)
- Figure out needs and make a plan for dates [\#1013](https://github.com/fecgov/openFEC/issues/1013)
- Schedule B endpoint [\#1004](https://github.com/fecgov/openFEC/issues/1004)
- Style API Docs [\#1002](https://github.com/fecgov/openFEC/issues/1002)
- Show Schedule A + B data summaries on committee pages [\#999](https://github.com/fecgov/openFEC/issues/999)
- Support paging by seek method [\#994](https://github.com/fecgov/openFEC/issues/994)
- Add integration tests for Swagger markup [\#993](https://github.com/fecgov/openFEC/issues/993)
- Allow resources to restrict sort columns [\#992](https://github.com/fecgov/openFEC/issues/992)
- Document caching behavior [\#978](https://github.com/fecgov/openFEC/issues/978)
- Redesign search box when small [\#976](https://github.com/fecgov/openFEC/issues/976)
- Replace multi-select [\#965](https://github.com/fecgov/openFEC/issues/965)
- Create summary endpoint for ie only spenders [\#938](https://github.com/fecgov/openFEC/issues/938)
- empty stats display [\#906](https://github.com/fecgov/openFEC/issues/906)
- Explain unknown values [\#885](https://github.com/fecgov/openFEC/issues/885)
- Design way to show sub-totals on committee page [\#847](https://github.com/fecgov/openFEC/issues/847)
- Clean Code [\#841](https://github.com/fecgov/openFEC/issues/841)
- Import other summary data from view [\#838](https://github.com/fecgov/openFEC/issues/838)
- Filings endpoint [\#837](https://github.com/fecgov/openFEC/issues/837)
- Schedule A Donations endpoint [\#836](https://github.com/fecgov/openFEC/issues/836)
- Weird results in dimoffice [\#785](https://github.com/fecgov/openFEC/issues/785)
- Redesign and reimplement filters [\#645](https://github.com/fecgov/openFEC/issues/645)
- Double check charts after demo [\#636](https://github.com/fecgov/openFEC/issues/636)
- Thoughts on type/designation/org merging [\#519](https://github.com/fecgov/openFEC/issues/519)
- Implement new search [\#432](https://github.com/fecgov/openFEC/issues/432)
- cap per page [\#299](https://github.com/fecgov/openFEC/issues/299)
- document what forms feed into what endpoint. [\#283](https://github.com/fecgov/openFEC/issues/283)
- Format data types [\#265](https://github.com/fecgov/openFEC/issues/265)

**Merged pull requests:**

- Feature/docs release2 [\#1062](https://github.com/fecgov/openFEC/pull/1062) ([LindsayYoung](https://github.com/LindsayYoung))
- Use \<= 200 for first contribution size bucket. [\#1059](https://github.com/fecgov/openFEC/pull/1059) ([jmcarp](https://github.com/jmcarp))
- Add indexes on filings columns. [\#1058](https://github.com/fecgov/openFEC/pull/1058) ([jmcarp](https://github.com/jmcarp))
- Parse currency strings from query. [\#1057](https://github.com/fecgov/openFEC/pull/1057) ([jmcarp](https://github.com/jmcarp))
- Feature/exclude memo [\#1056](https://github.com/fecgov/openFEC/pull/1056) ([jmcarp](https://github.com/jmcarp))
- Feature/update readme [\#1055](https://github.com/fecgov/openFEC/pull/1055) ([jmcarp](https://github.com/jmcarp))
- Release/public beta 20150713 [\#1052](https://github.com/fecgov/openFEC/pull/1052) ([jmcarp](https://github.com/jmcarp))
- Feature/aggregate contributors [\#1050](https://github.com/fecgov/openFEC/pull/1050) ([jmcarp](https://github.com/jmcarp))
- Add 301 redirect from `/developer` to canonical `/developers`. [\#1047](https://github.com/fecgov/openFEC/pull/1047) ([jmcarp](https://github.com/jmcarp))
- Allow hiding null values on sorted columns. [\#1046](https://github.com/fecgov/openFEC/pull/1046) ([jmcarp](https://github.com/jmcarp))
- Feature/combined receipts by size [\#1043](https://github.com/fecgov/openFEC/pull/1043) ([jmcarp](https://github.com/jmcarp))
- adding data warning to README [\#1041](https://github.com/fecgov/openFEC/pull/1041) ([leahbannon](https://github.com/leahbannon))
- taking out extra drop [\#1040](https://github.com/fecgov/openFEC/pull/1040) ([LindsayYoung](https://github.com/LindsayYoung))
- adding info & link about FEC data use restrictions [\#1039](https://github.com/fecgov/openFEC/pull/1039) ([leahbannon](https://github.com/leahbannon))
- Improve error messages on invalid date args. [\#1038](https://github.com/fecgov/openFEC/pull/1038) ([jmcarp](https://github.com/jmcarp))
- Fix image number range. [\#1037](https://github.com/fecgov/openFEC/pull/1037) ([jmcarp](https://github.com/jmcarp))
- Document keyset pagination. [\#1035](https://github.com/fecgov/openFEC/pull/1035) ([jmcarp](https://github.com/jmcarp))
- Redirect from empty URLs to developer documentation. [\#1034](https://github.com/fecgov/openFEC/pull/1034) ([jmcarp](https://github.com/jmcarp))
- Remove unused code. [\#1033](https://github.com/fecgov/openFEC/pull/1033) ([jmcarp](https://github.com/jmcarp))
- Performance updates [\#1032](https://github.com/fecgov/openFEC/pull/1032) ([jmcarp](https://github.com/jmcarp))
- Separate filings from schedules. [\#1031](https://github.com/fecgov/openFEC/pull/1031) ([LindsayYoung](https://github.com/LindsayYoung))
- Feature/filings [\#1024](https://github.com/fecgov/openFEC/pull/1024) ([jmcarp](https://github.com/jmcarp))
- Add filters on committee filing dates. [\#1023](https://github.com/fecgov/openFEC/pull/1023) ([jmcarp](https://github.com/jmcarp))
- Small edits for clarity and typos [\#1022](https://github.com/fecgov/openFEC/pull/1022) ([leahbannon](https://github.com/leahbannon))
- Feature/update subset [\#1021](https://github.com/fecgov/openFEC/pull/1021) ([jmcarp](https://github.com/jmcarp))
- Pin requirement versions. [\#1020](https://github.com/fecgov/openFEC/pull/1020) ([jmcarp](https://github.com/jmcarp))
- Expect correct error code on invalid page queries. [\#1018](https://github.com/fecgov/openFEC/pull/1018) ([jmcarp](https://github.com/jmcarp))
- Update README.md [\#1017](https://github.com/fecgov/openFEC/pull/1017) ([LindsayYoung](https://github.com/LindsayYoung))
- Update language [\#1012](https://github.com/fecgov/openFEC/pull/1012) ([LindsayYoung](https://github.com/LindsayYoung))
- updating label [\#1011](https://github.com/fecgov/openFEC/pull/1011) ([LindsayYoung](https://github.com/LindsayYoung))
- Upgrade to current CF stack. [\#1010](https://github.com/fecgov/openFEC/pull/1010) ([jmcarp](https://github.com/jmcarp))
- Update args.py [\#1009](https://github.com/fecgov/openFEC/pull/1009) ([emileighoutlaw](https://github.com/emileighoutlaw))
- Feature/incremental aggregates [\#1008](https://github.com/fecgov/openFEC/pull/1008) ([jmcarp](https://github.com/jmcarp))
- Feature/filings [\#1007](https://github.com/fecgov/openFEC/pull/1007) ([LindsayYoung](https://github.com/LindsayYoung))
- Feature/schedule b [\#1005](https://github.com/fecgov/openFEC/pull/1005) ([jmcarp](https://github.com/jmcarp))
- Update docs.py [\#1003](https://github.com/fecgov/openFEC/pull/1003) ([emileighoutlaw](https://github.com/emileighoutlaw))
- Use containerized builds. [\#998](https://github.com/fecgov/openFEC/pull/998) ([jmcarp](https://github.com/jmcarp))
- Feature/ie totals [\#997](https://github.com/fecgov/openFEC/pull/997) ([LindsayYoung](https://github.com/LindsayYoung))
- Feature/schedule a [\#996](https://github.com/fecgov/openFEC/pull/996) ([jmcarp](https://github.com/jmcarp))
- Feature/test swagger [\#995](https://github.com/fecgov/openFEC/pull/995) ([jmcarp](https://github.com/jmcarp))
- Feature/ie reports [\#991](https://github.com/fecgov/openFEC/pull/991) ([LindsayYoung](https://github.com/LindsayYoung))
- Update deploy script. [\#919](https://github.com/fecgov/openFEC/pull/919) ([jmcarp](https://github.com/jmcarp))

## [public-beta](https://github.com/fecgov/openFEC/tree/public-beta) (2015-06-17)

[Full Changelog](https://github.com/fecgov/openFEC/compare/v.1.1...public-beta)

**Fixed bugs:**

- incorrect candidate metadata? [\#987](https://github.com/fecgov/openFEC/issues/987)
- Misleading Error Message for No Results [\#979](https://github.com/fecgov/openFEC/issues/979)
- Text in search box references candidates on Committee page [\#973](https://github.com/fecgov/openFEC/issues/973)
- display total individual contributions to pac-party  [\#972](https://github.com/fecgov/openFEC/issues/972)
- prompt should match search [\#970](https://github.com/fecgov/openFEC/issues/970)
- Beta banner doesn't collapse  [\#963](https://github.com/fecgov/openFEC/issues/963)
- don't show date options we don't have info on in the dropdown [\#960](https://github.com/fecgov/openFEC/issues/960)
- Give correct API instructions [\#958](https://github.com/fecgov/openFEC/issues/958)

**Closed issues:**

- API docs Beta warning [\#983](https://github.com/fecgov/openFEC/issues/983)
- entering multiple arguments for array types yields zero results [\#980](https://github.com/fecgov/openFEC/issues/980)
- Fix or replace gunicorn [\#977](https://github.com/fecgov/openFEC/issues/977)
- Default to closed filters on mobile and tablet [\#968](https://github.com/fecgov/openFEC/issues/968)
- Move modal close button for mobile nav [\#966](https://github.com/fecgov/openFEC/issues/966)
- Update URL on filter change [\#957](https://github.com/fecgov/openFEC/issues/957)
- Create a new snapshot for dev and staging [\#935](https://github.com/fecgov/openFEC/issues/935)
- Can't reopen modal nav after closing [\#934](https://github.com/fecgov/openFEC/issues/934)
- Social media tags [\#931](https://github.com/fecgov/openFEC/issues/931)
- Add warning if javascript is disabled [\#911](https://github.com/fecgov/openFEC/issues/911)
- better PDF filtering  [\#901](https://github.com/fecgov/openFEC/issues/901)
- Load testing [\#889](https://github.com/fecgov/openFEC/issues/889)
- Hamburger nav: ESC key should close the menu [\#872](https://github.com/fecgov/openFEC/issues/872)
- add link to API from website  [\#864](https://github.com/fecgov/openFEC/issues/864)
- Document / automate database snapshots [\#835](https://github.com/fecgov/openFEC/issues/835)

**Merged pull requests:**

- order candidate records to get the most recent [\#989](https://github.com/fecgov/openFEC/pull/989) ([LindsayYoung](https://github.com/LindsayYoung))
- Feature/api disclaimer [\#985](https://github.com/fecgov/openFEC/pull/985) ([LindsayYoung](https://github.com/LindsayYoung))
- Deploy using nginx. [\#984](https://github.com/fecgov/openFEC/pull/984) ([jmcarp](https://github.com/jmcarp))
- Direct swagger-ui to combine query arguments correctly. [\#982](https://github.com/fecgov/openFEC/pull/982) ([jmcarp](https://github.com/jmcarp))
- Standardized the name of ttl\_indv\_contb [\#975](https://github.com/fecgov/openFEC/pull/975) ([LindsayYoung](https://github.com/LindsayYoung))
- Handle spaces that should be mapped to multiple routes. [\#974](https://github.com/fecgov/openFEC/pull/974) ([jmcarp](https://github.com/jmcarp))
- Add simple load testing. [\#971](https://github.com/fecgov/openFEC/pull/971) ([jmcarp](https://github.com/jmcarp))
- Add caching headers from environment. [\#962](https://github.com/fecgov/openFEC/pull/962) ([jmcarp](https://github.com/jmcarp))
- Document database snapshots. [\#959](https://github.com/fecgov/openFEC/pull/959) ([jmcarp](https://github.com/jmcarp))
- Feature/pdf link fix\#901 [\#928](https://github.com/fecgov/openFEC/pull/928) ([LindsayYoung](https://github.com/LindsayYoung))

## [v.1.1](https://github.com/fecgov/openFEC/tree/v.1.1) (2015-06-10)

[Full Changelog](https://github.com/fecgov/openFEC/compare/94e8cf14d4e102e75b2004562c22fdfda9088c46...v.1.1)

**Fixed bugs:**

- Principal committee link not showing [\#917](https://github.com/fecgov/openFEC/issues/917)
- Summary charts are not handling "None" [\#896](https://github.com/fecgov/openFEC/issues/896)
- Summary charts are not dealing with negatives [\#895](https://github.com/fecgov/openFEC/issues/895)
- Add subtotals in the summary and reports view [\#884](https://github.com/fecgov/openFEC/issues/884)
- Candidates and Committees triggering "Oops We Messed Up" errors [\#879](https://github.com/fecgov/openFEC/issues/879)
- Display browser warning [\#875](https://github.com/fecgov/openFEC/issues/875)
- Filter out old links on web app [\#870](https://github.com/fecgov/openFEC/issues/870)
- Glossary needs response when someone searches for something we don't have [\#869](https://github.com/fecgov/openFEC/issues/869)
- add an api key input for the try it out feature [\#863](https://github.com/fecgov/openFEC/issues/863)
- Generate incumbent challenger status  [\#852](https://github.com/fecgov/openFEC/issues/852)
- Don't transform committee names to lowercase in site title [\#851](https://github.com/fecgov/openFEC/issues/851)
- odd results on the filter [\#850](https://github.com/fecgov/openFEC/issues/850)
- Add address to committee history endpoint [\#846](https://github.com/fecgov/openFEC/issues/846)
- HTTP site still has basic auth activated [\#831](https://github.com/fecgov/openFEC/issues/831)
- Graph \(Receipts and Disbursements\) reports apprear to have overlapping coverage dates [\#821](https://github.com/fecgov/openFEC/issues/821)
- Most recent report - disbursements - "Contributions to Other Committees" is incorrect [\#820](https://github.com/fecgov/openFEC/issues/820)
- Detailed Summary 2015 - 2016 Total Disbursements is incorrect [\#819](https://github.com/fecgov/openFEC/issues/819)
- Detailed Summary 2015 - 2016 Total Receipts is incorrect [\#818](https://github.com/fecgov/openFEC/issues/818)
- Detailed Summary 2015 - 2016 Total Disbursements -  all line items are incorrect [\#817](https://github.com/fecgov/openFEC/issues/817)
- Detailed Summary 2015 - 2016 Total Receipts -  all line items are incorrect [\#816](https://github.com/fecgov/openFEC/issues/816)
- Net Operating Expenditures\(most recent filing\) incorrect [\#814](https://github.com/fecgov/openFEC/issues/814)
- Net Contributions\(most recent filing\) incorrect [\#813](https://github.com/fecgov/openFEC/issues/813)
- Total Disbursements \(most recent filing\) incorrect [\#812](https://github.com/fecgov/openFEC/issues/812)
- Total Receipts \(most recent filing\) incorrect [\#811](https://github.com/fecgov/openFEC/issues/811)
- Political Party Affiliation missing [\#810](https://github.com/fecgov/openFEC/issues/810)
- Political Party Affiliation \(committees with party affiliations\) [\#809](https://github.com/fecgov/openFEC/issues/809)
- senate and house receipts and disbursements [\#808](https://github.com/fecgov/openFEC/issues/808)
- Cash on hand [\#799](https://github.com/fecgov/openFEC/issues/799)
- Filter out ballot candidates [\#793](https://github.com/fecgov/openFEC/issues/793)
- Invalid link if authorized committee totals do not have a source [\#789](https://github.com/fecgov/openFEC/issues/789)
- "You do not have permission" error when viewing Committee PDF [\#788](https://github.com/fecgov/openFEC/issues/788)
- Scott Brown's summary is not showing up [\#780](https://github.com/fecgov/openFEC/issues/780)
- Some party descriptions incorrect in the Candidate list [\#762](https://github.com/fecgov/openFEC/issues/762)
- Party descriptions contain extra/invalid text [\#755](https://github.com/fecgov/openFEC/issues/755)
- Committee search results including extra results when filtering by Organization Type [\#754](https://github.com/fecgov/openFEC/issues/754)
- Candidate search returning result that appears unrelated [\#753](https://github.com/fecgov/openFEC/issues/753)
- Candidate results include values from years not included in filter [\#749](https://github.com/fecgov/openFEC/issues/749)
- Candidate Page dev fixes [\#744](https://github.com/fecgov/openFEC/issues/744)
- Search results do not include committee results [\#743](https://github.com/fecgov/openFEC/issues/743)
- Committee addresses no longer showing their ZIP codes [\#742](https://github.com/fecgov/openFEC/issues/742)
- Search box is mixing data in Candidate and Committee groupings [\#741](https://github.com/fecgov/openFEC/issues/741)
- Wording update needed in home page Candidates box [\#740](https://github.com/fecgov/openFEC/issues/740)
- Extra word and missing glossary definition in "No financial data" error message [\#732](https://github.com/fecgov/openFEC/issues/732)
- Field label misspelled on Committee page [\#731](https://github.com/fecgov/openFEC/issues/731)
- Glossary \(?\) links on Candidate page don't link to definitions [\#730](https://github.com/fecgov/openFEC/issues/730)
- Show "remove button" on cycle select upon page load [\#726](https://github.com/fecgov/openFEC/issues/726)
- Committee name filter empty when applied [\#717](https://github.com/fecgov/openFEC/issues/717)
- Typo in Learn More banner [\#707](https://github.com/fecgov/openFEC/issues/707)
- Date labeling audit [\#704](https://github.com/fecgov/openFEC/issues/704)
- Date Limit all views to recent data [\#698](https://github.com/fecgov/openFEC/issues/698)
- Certain fields in committee summary are not bound to real data [\#695](https://github.com/fecgov/openFEC/issues/695)
- Typeahead search showing different committees than committee page [\#676](https://github.com/fecgov/openFEC/issues/676)
- Unable to expand/scroll to see long glossary definitions [\#661](https://github.com/fecgov/openFEC/issues/661)
- Missing data in web app that is in the api [\#657](https://github.com/fecgov/openFEC/issues/657)
- Year filtering on /committees is broken [\#649](https://github.com/fecgov/openFEC/issues/649)
- Add max-width to chart bars [\#646](https://github.com/fecgov/openFEC/issues/646)
- correct number of results for charts [\#641](https://github.com/fecgov/openFEC/issues/641)
- Chart order [\#640](https://github.com/fecgov/openFEC/issues/640)
- Fix cash on hand and debt  [\#637](https://github.com/fecgov/openFEC/issues/637)
- In consistent behavior on the ? for glossary [\#634](https://github.com/fecgov/openFEC/issues/634)
- Totals need to be most recent to oldest [\#631](https://github.com/fecgov/openFEC/issues/631)
- Sorting not really supported [\#625](https://github.com/fecgov/openFEC/issues/625)
- Committee start date issue [\#624](https://github.com/fecgov/openFEC/issues/624)
- Dropdowns for candidate profiles are not working [\#623](https://github.com/fecgov/openFEC/issues/623)
- disbursements and receipts not showing on the front end. [\#621](https://github.com/fecgov/openFEC/issues/621)
- Cash and Debt dates [\#620](https://github.com/fecgov/openFEC/issues/620)
- Missing data [\#618](https://github.com/fecgov/openFEC/issues/618)
- Committee addresses missing their state [\#615](https://github.com/fecgov/openFEC/issues/615)
- Report pagination error [\#612](https://github.com/fecgov/openFEC/issues/612)
- On the API, the totals route is failing with an error [\#605](https://github.com/fecgov/openFEC/issues/605)
- New Relic Config Tweaks [\#602](https://github.com/fecgov/openFEC/issues/602)
- Pagination Seems to Fail [\#593](https://github.com/fecgov/openFEC/issues/593)
- No year filter on single resources [\#567](https://github.com/fecgov/openFEC/issues/567)
- Empty committee result set that should be filled [\#565](https://github.com/fecgov/openFEC/issues/565)
- Messages other than 500 when committee reports are not found [\#563](https://github.com/fecgov/openFEC/issues/563)
- duplicate committee tests [\#535](https://github.com/fecgov/openFEC/issues/535)
- CF needs migrations  [\#528](https://github.com/fecgov/openFEC/issues/528)
- Add committee id and candidate id to full text search [\#524](https://github.com/fecgov/openFEC/issues/524)
- Consistent incumbent status reporting [\#499](https://github.com/fecgov/openFEC/issues/499)
- Pelosi Bug [\#484](https://github.com/fecgov/openFEC/issues/484)
- Some pages crashing webapp [\#480](https://github.com/fecgov/openFEC/issues/480)
- Reid Bug [\#477](https://github.com/fecgov/openFEC/issues/477)
- Too many candidates in committee page [\#460](https://github.com/fecgov/openFEC/issues/460)
- Ensure totals data is actually present on candidate / committee pages [\#448](https://github.com/fecgov/openFEC/issues/448)
- Need better handling of columns on filter pages [\#446](https://github.com/fecgov/openFEC/issues/446)
- Full text search searches all fields [\#429](https://github.com/fecgov/openFEC/issues/429)
- Candidates showing no results [\#425](https://github.com/fecgov/openFEC/issues/425)
- Figure out null fields in totals [\#423](https://github.com/fecgov/openFEC/issues/423)
- some committees are not displaying in the new /committee branch [\#418](https://github.com/fecgov/openFEC/issues/418)
- Clean escaped quotes from data [\#412](https://github.com/fecgov/openFEC/issues/412)
- Fix Indexing Error  [\#393](https://github.com/fecgov/openFEC/issues/393)
- Fix link to "fec.gov" on web app [\#390](https://github.com/fecgov/openFEC/issues/390)
- President label [\#388](https://github.com/fecgov/openFEC/issues/388)
- Typeahead doesn't respect API location in local\_config [\#368](https://github.com/fecgov/openFEC/issues/368)
- Reimplement fulltext search for /candidate [\#361](https://github.com/fecgov/openFEC/issues/361)
- API throws error when no q param is given to /name endpoint [\#341](https://github.com/fecgov/openFEC/issues/341)
- Clean up incumbent\_challenge\_full field [\#332](https://github.com/fecgov/openFEC/issues/332)
- Implement committee party filtering for web app [\#286](https://github.com/fecgov/openFEC/issues/286)
- name only showing for not all fields [\#258](https://github.com/fecgov/openFEC/issues/258)
- Fix 11 CFR 110 Table of Contents [\#202](https://github.com/fecgov/openFEC/issues/202)
- Bug: On an error, filters stay disabled [\#197](https://github.com/fecgov/openFEC/issues/197)
- Fix container rendering bug [\#181](https://github.com/fecgov/openFEC/issues/181)
- Make Search Results Clickable [\#174](https://github.com/fecgov/openFEC/issues/174)
- calling API with bad filter parameters should raise error [\#160](https://github.com/fecgov/openFEC/issues/160)
- Organization type filter for committees does not function [\#133](https://github.com/fecgov/openFEC/issues/133)
- Move most recent election cycle to the top of filter selection list [\#132](https://github.com/fecgov/openFEC/issues/132)
- Committee filters still do not work [\#129](https://github.com/fecgov/openFEC/issues/129)
- Search bar does not work on the candidate/committee filters [\#128](https://github.com/fecgov/openFEC/issues/128)
- Use of the district filter should also filter other results [\#125](https://github.com/fecgov/openFEC/issues/125)
- make sure single resource is working and add test [\#123](https://github.com/fecgov/openFEC/issues/123)
- Refine candidate state [\#122](https://github.com/fecgov/openFEC/issues/122)
- Make sure party filtering is working [\#121](https://github.com/fecgov/openFEC/issues/121)
- Only showing data about elections for the year requested [\#120](https://github.com/fecgov/openFEC/issues/120)
- Remove election cycles that have yet to happen [\#118](https://github.com/fecgov/openFEC/issues/118)
- Committee Type Bug [\#117](https://github.com/fecgov/openFEC/issues/117)
- Request including type=H not including just House type committees [\#112](https://github.com/fecgov/openFEC/issues/112)

**Closed issues:**

- read only access to PostGreSQL DB for FEC? [\#952](https://github.com/fecgov/openFEC/issues/952)
- "Office Sought" dropdown on Candidate search page should say "President", not "Presidential" [\#951](https://github.com/fecgov/openFEC/issues/951)
- Obama 2012 Transfers are "None", should have value [\#950](https://github.com/fecgov/openFEC/issues/950)
- Glossary feature example doesn't work on the home page [\#947](https://github.com/fecgov/openFEC/issues/947)
- Document deployment workflow [\#942](https://github.com/fecgov/openFEC/issues/942)
- Add back in subtotals for Reports [\#937](https://github.com/fecgov/openFEC/issues/937)
- point dev api back at the dev db [\#936](https://github.com/fecgov/openFEC/issues/936)
- Update title on API page [\#925](https://github.com/fecgov/openFEC/issues/925)
- Make "/" set focus on search input [\#920](https://github.com/fecgov/openFEC/issues/920)
- Main search box type is not contextual [\#918](https://github.com/fecgov/openFEC/issues/918)
- Minify and gzip assets [\#905](https://github.com/fecgov/openFEC/issues/905)
- Add descriptions to Swagger tags [\#900](https://github.com/fecgov/openFEC/issues/900)
- make the "None" result in table generate a \(?\) link to the glossary [\#899](https://github.com/fecgov/openFEC/issues/899)
- Look at recipts and disbursements at the same time [\#897](https://github.com/fecgov/openFEC/issues/897)
- Use pdf links from API  [\#888](https://github.com/fecgov/openFEC/issues/888)
- create warning for older browsers [\#883](https://github.com/fecgov/openFEC/issues/883)
- Termination reports included in reports endpoints [\#881](https://github.com/fecgov/openFEC/issues/881)
- Partial match search results not displaying for Candidates or Committees [\#880](https://github.com/fecgov/openFEC/issues/880)
- Only committees that have filed F3s are imported [\#877](https://github.com/fecgov/openFEC/issues/877)
- API version in response should match url spacing [\#868](https://github.com/fecgov/openFEC/issues/868)
- Add link to API repo on API docs [\#865](https://github.com/fecgov/openFEC/issues/865)
- Candidate filtering [\#855](https://github.com/fecgov/openFEC/issues/855)
- Time-standardized endpoint for charts [\#840](https://github.com/fecgov/openFEC/issues/840)
- Enhance search with pacronyms  [\#839](https://github.com/fecgov/openFEC/issues/839)
- Type ahead tweak [\#833](https://github.com/fecgov/openFEC/issues/833)
- Aggregate financials across multiple authorized committees [\#832](https://github.com/fecgov/openFEC/issues/832)
- Graphs \(cycle filtering\) [\#823](https://github.com/fecgov/openFEC/issues/823)
- Cash on Hand lable \(candidates\) [\#822](https://github.com/fecgov/openFEC/issues/822)
- Send FEC talking points about 18F [\#807](https://github.com/fecgov/openFEC/issues/807)
- Restrict committee reports to monthly and quarterly [\#805](https://github.com/fecgov/openFEC/issues/805)
- Set up user-provided service in CF to keep track of sensitive env vars [\#800](https://github.com/fecgov/openFEC/issues/800)
- Load candidate and committee search results asynchronously [\#797](https://github.com/fecgov/openFEC/issues/797)
- Store secret credentials in user-provided service [\#796](https://github.com/fecgov/openFEC/issues/796)
- www issue [\#791](https://github.com/fecgov/openFEC/issues/791)
- Name filter should accept "Firstname lastname" searches [\#777](https://github.com/fecgov/openFEC/issues/777)
- Unify \*\_list and \*\_detail views [\#773](https://github.com/fecgov/openFEC/issues/773)
- Show election years instead of election cycles for candidates [\#771](https://github.com/fecgov/openFEC/issues/771)
- Zero-downtime deployment [\#764](https://github.com/fecgov/openFEC/issues/764)
- Fulltext search tables should have "ofec\_" prefix [\#761](https://github.com/fecgov/openFEC/issues/761)
- Auto-generate schemas [\#759](https://github.com/fecgov/openFEC/issues/759)
- Separate totals from recent report [\#746](https://github.com/fecgov/openFEC/issues/746)
- Add cycle filtering to charts [\#745](https://github.com/fecgov/openFEC/issues/745)
- add pdf links to committee/id/reports [\#739](https://github.com/fecgov/openFEC/issues/739)
- Add narrative documentation to API docs [\#736](https://github.com/fecgov/openFEC/issues/736)
- Allow user to select the number of results per page [\#728](https://github.com/fecgov/openFEC/issues/728)
- add the ability to accept keys to dev and staging  [\#727](https://github.com/fecgov/openFEC/issues/727)
- Fix accordion icons [\#713](https://github.com/fecgov/openFEC/issues/713)
- Fix footer links on mobile [\#712](https://github.com/fecgov/openFEC/issues/712)
- Run local API server for webapp tests [\#711](https://github.com/fecgov/openFEC/issues/711)
- Update animated gif to reflect current site text [\#710](https://github.com/fecgov/openFEC/issues/710)
- Talk to FEC about Data and SQL views [\#708](https://github.com/fecgov/openFEC/issues/708)
- Use repeated query parameters for list arguments [\#706](https://github.com/fecgov/openFEC/issues/706)
- Committee summary audit [\#705](https://github.com/fecgov/openFEC/issues/705)
- 508 accessibility contrast issues [\#702](https://github.com/fecgov/openFEC/issues/702)
- Make sure all endpoints are filterable by 2-year-period [\#701](https://github.com/fecgov/openFEC/issues/701)
- Candidate cycle dropdown should apply to statements, not candidates [\#692](https://github.com/fecgov/openFEC/issues/692)
- weird browser result on committee filters [\#687](https://github.com/fecgov/openFEC/issues/687)
- Integration tests [\#685](https://github.com/fecgov/openFEC/issues/685)
- No way to filter candidates/committees by territories [\#683](https://github.com/fecgov/openFEC/issues/683)
- Make browse page responsive [\#682](https://github.com/fecgov/openFEC/issues/682)
- Create new test subset [\#681](https://github.com/fecgov/openFEC/issues/681)
- Update In Development banner text [\#675](https://github.com/fecgov/openFEC/issues/675)
- filter out U committees from linkage results [\#673](https://github.com/fecgov/openFEC/issues/673)
- Add cache busting for static assets [\#672](https://github.com/fecgov/openFEC/issues/672)
- Add 2016 to the election cycle choices for candidate browse view [\#671](https://github.com/fecgov/openFEC/issues/671)
- "Learn More" should send user somewhere else [\#670](https://github.com/fecgov/openFEC/issues/670)
- Candidate/committee filter usability: Typing Enter after entering a name clears out field [\#669](https://github.com/fecgov/openFEC/issues/669)
- Make district in candidate header link to filtered view [\#666](https://github.com/fecgov/openFEC/issues/666)
- Go through 508 Checklist [\#659](https://github.com/fecgov/openFEC/issues/659)
- Make charts responsive [\#658](https://github.com/fecgov/openFEC/issues/658)
- Associate an Email Address and Connect to Contact Support Button [\#652](https://github.com/fecgov/openFEC/issues/652)
- Fix Copy to Reflect Timeliness of Data [\#650](https://github.com/fecgov/openFEC/issues/650)
- Improve chart design [\#647](https://github.com/fecgov/openFEC/issues/647)
- As a user ,Im overwhelmed by drop down menus in left hand column. [\#644](https://github.com/fecgov/openFEC/issues/644)
- email missing from "in dev" header [\#643](https://github.com/fecgov/openFEC/issues/643)
- committee history [\#639](https://github.com/fecgov/openFEC/issues/639)
- Pagination returning inconsistent record count for committees [\#638](https://github.com/fecgov/openFEC/issues/638)
- Duplicate related candidates on committee pages [\#628](https://github.com/fecgov/openFEC/issues/628)
- Inconsistent charting [\#627](https://github.com/fecgov/openFEC/issues/627)
- Show which years are applied on browse pages [\#626](https://github.com/fecgov/openFEC/issues/626)
- Force HTTPS by default [\#619](https://github.com/fecgov/openFEC/issues/619)
- Search results count number should be human readable [\#617](https://github.com/fecgov/openFEC/issues/617)
- Animated glossary gif is fuzzy.  [\#616](https://github.com/fecgov/openFEC/issues/616)
- Use factories for unit tests [\#614](https://github.com/fecgov/openFEC/issues/614)
- Add tab-ability and focus states to everything [\#604](https://github.com/fecgov/openFEC/issues/604)
- Things to check after Golden Gate: [\#599](https://github.com/fecgov/openFEC/issues/599)
- Implement pathway from GG data to CF Production instance [\#598](https://github.com/fecgov/openFEC/issues/598)
- Determine best method of copying data into CF [\#597](https://github.com/fecgov/openFEC/issues/597)
- SSL and Domains Sorted Out [\#596](https://github.com/fecgov/openFEC/issues/596)
- Manual QA Test Pages on Production Instance [\#592](https://github.com/fecgov/openFEC/issues/592)
- Implement Final Copy Changes [\#590](https://github.com/fecgov/openFEC/issues/590)
- Complete Security Scans [\#589](https://github.com/fecgov/openFEC/issues/589)
- Merge API refactor [\#588](https://github.com/fecgov/openFEC/issues/588)
- Add team chat integrations [\#587](https://github.com/fecgov/openFEC/issues/587)
- Fix section 508 accessibility notice problems [\#585](https://github.com/fecgov/openFEC/issues/585)
- Fix section 508 accessibility warning problems [\#584](https://github.com/fecgov/openFEC/issues/584)
- Configure environment \(dev, stage, prod\) with FEC\_ENVIRONMENT [\#582](https://github.com/fecgov/openFEC/issues/582)
- Add glossary links consistently throughout site [\#577](https://github.com/fecgov/openFEC/issues/577)
- Update glossary definitions [\#576](https://github.com/fecgov/openFEC/issues/576)
- Conduct Nessus/Owasp testing [\#575](https://github.com/fecgov/openFEC/issues/575)
- Update API documentation [\#569](https://github.com/fecgov/openFEC/issues/569)
- Implement charts with reports [\#560](https://github.com/fecgov/openFEC/issues/560)
- Code responsive changes  [\#559](https://github.com/fecgov/openFEC/issues/559)
- Finalize Production Workflow [\#558](https://github.com/fecgov/openFEC/issues/558)
- Implement Preliminary Google Analytics [\#557](https://github.com/fecgov/openFEC/issues/557)
- Design responsive screens [\#556](https://github.com/fecgov/openFEC/issues/556)
- Implement New Relic or other error monitoring tool [\#555](https://github.com/fecgov/openFEC/issues/555)
- Sweep of AWS resources [\#554](https://github.com/fecgov/openFEC/issues/554)
- Continuous deployment to CF [\#553](https://github.com/fecgov/openFEC/issues/553)
- Finalize Copy on Site [\#552](https://github.com/fecgov/openFEC/issues/552)
- 508 Accessibility Check [\#551](https://github.com/fecgov/openFEC/issues/551)
- Device Testing [\#550](https://github.com/fecgov/openFEC/issues/550)
- Conduct Browser Testing [\#549](https://github.com/fecgov/openFEC/issues/549)
- Implement new committee pages [\#548](https://github.com/fecgov/openFEC/issues/548)
- CF Database Migrations [\#547](https://github.com/fecgov/openFEC/issues/547)
- Duplicated / inconsistent data in join table [\#543](https://github.com/fecgov/openFEC/issues/543)
- Queries on views are slow [\#540](https://github.com/fecgov/openFEC/issues/540)
- DB Refresh Command needs to be fixed for CF [\#532](https://github.com/fecgov/openFEC/issues/532)
- Get SSL Cert [\#531](https://github.com/fecgov/openFEC/issues/531)
- Implement Collapsible Banner [\#529](https://github.com/fecgov/openFEC/issues/529)
- Refactor web app to use un-nested structure [\#527](https://github.com/fecgov/openFEC/issues/527)
- Update server to use Python3 [\#526](https://github.com/fecgov/openFEC/issues/526)
- Discussion: election cycle choosing [\#522](https://github.com/fecgov/openFEC/issues/522)
- Change Super PAC Type Label [\#520](https://github.com/fecgov/openFEC/issues/520)
- Whitelist IPs for API access, including data.gov ones [\#518](https://github.com/fecgov/openFEC/issues/518)
- Flesh out story candidates around filing support [\#515](https://github.com/fecgov/openFEC/issues/515)
- Redesign search interaction [\#514](https://github.com/fecgov/openFEC/issues/514)
- Get front end working with api.data.gov [\#512](https://github.com/fecgov/openFEC/issues/512)
- Update web app for unembedding-resources API refactor [\#511](https://github.com/fecgov/openFEC/issues/511)
- Create HTML + CSS for report summary view [\#509](https://github.com/fecgov/openFEC/issues/509)
- Assess which candidate and committee fields need to be available for web-app [\#507](https://github.com/fecgov/openFEC/issues/507)
- Make candidate `/recent` endpoint [\#506](https://github.com/fecgov/openFEC/issues/506)
- Make candidate history endpoint [\#505](https://github.com/fecgov/openFEC/issues/505)
- Remove nested committees from candidate results [\#504](https://github.com/fecgov/openFEC/issues/504)
- Remove nested candidates from committee results [\#503](https://github.com/fecgov/openFEC/issues/503)
- Factor pagination into a common class [\#502](https://github.com/fecgov/openFEC/issues/502)
- Disable autocomplete on search input [\#500](https://github.com/fecgov/openFEC/issues/500)
- Make web app more forgiving wrt incumbent data [\#498](https://github.com/fecgov/openFEC/issues/498)
- Get filings data and the rest of the report data [\#497](https://github.com/fecgov/openFEC/issues/497)
- Check multiple authorized committees are being treated properly [\#494](https://github.com/fecgov/openFEC/issues/494)
- Add full text tables to the refresh db commands [\#491](https://github.com/fecgov/openFEC/issues/491)
- Implement election cycle chooser [\#489](https://github.com/fecgov/openFEC/issues/489)
- Make sure that responses are in consistent chronological order across endpoints [\#488](https://github.com/fecgov/openFEC/issues/488)
- update documentation [\#486](https://github.com/fecgov/openFEC/issues/486)
- Limit ips  [\#485](https://github.com/fecgov/openFEC/issues/485)
- Error on `npm run sass-build` [\#481](https://github.com/fecgov/openFEC/issues/481)
- Add auth to nosetests [\#479](https://github.com/fecgov/openFEC/issues/479)
- Make front end more Cloud Foundry-ready [\#478](https://github.com/fecgov/openFEC/issues/478)
- Conduct additional user interviews [\#476](https://github.com/fecgov/openFEC/issues/476)
- GitHub training for FEC staff [\#475](https://github.com/fecgov/openFEC/issues/475)
- Explain the value of API with examples [\#474](https://github.com/fecgov/openFEC/issues/474)
- Filings [\#473](https://github.com/fecgov/openFEC/issues/473)
- Conduct 3-5 Usability Tests [\#472](https://github.com/fecgov/openFEC/issues/472)
- Research gateway box cloning solutions [\#471](https://github.com/fecgov/openFEC/issues/471)
- Cloud Foundry set up Web app [\#470](https://github.com/fecgov/openFEC/issues/470)
- Cloud Foundry set up API [\#469](https://github.com/fecgov/openFEC/issues/469)
- Begin detailed site map [\#468](https://github.com/fecgov/openFEC/issues/468)
- Interview Pat at FEC [\#467](https://github.com/fecgov/openFEC/issues/467)
- Interview Greg and Judy at FEC [\#466](https://github.com/fecgov/openFEC/issues/466)
- Make sure that refactored endpoints can be filtered by `year` or `election\_year` [\#464](https://github.com/fecgov/openFEC/issues/464)
- Make sure that refactored committee endpoints can be filtered by committee `type` [\#463](https://github.com/fecgov/openFEC/issues/463)
- Implement API endpoint pluralization changes [\#462](https://github.com/fecgov/openFEC/issues/462)
- Push api\_location var through to JS [\#461](https://github.com/fecgov/openFEC/issues/461)
- Some committees not showing up on the webapp [\#459](https://github.com/fecgov/openFEC/issues/459)
- Sort totals in API most recent first [\#457](https://github.com/fecgov/openFEC/issues/457)
- in committee/\<id\> "active\_through" is really "election\_year" [\#453](https://github.com/fecgov/openFEC/issues/453)
- Match up story candidates and priorities doc [\#447](https://github.com/fecgov/openFEC/issues/447)
- Add migrations framework [\#441](https://github.com/fecgov/openFEC/issues/441)
- Write up summary for FEC [\#440](https://github.com/fecgov/openFEC/issues/440)
- Check data warehouse for filings table [\#437](https://github.com/fecgov/openFEC/issues/437)
- Add more selenium tests [\#436](https://github.com/fecgov/openFEC/issues/436)
- /candidate/\<id\> endpoint [\#435](https://github.com/fecgov/openFEC/issues/435)
- Implement changes to candidate/id API endpoint [\#434](https://github.com/fecgov/openFEC/issues/434)
- Implement new homepage design [\#433](https://github.com/fecgov/openFEC/issues/433)
- Fix padding at top of committee page [\#431](https://github.com/fecgov/openFEC/issues/431)
- Remove joint committee data on candidate page [\#430](https://github.com/fecgov/openFEC/issues/430)
- Change search to look at specific fields [\#428](https://github.com/fecgov/openFEC/issues/428)
- Implement related candidates on committee pages [\#427](https://github.com/fecgov/openFEC/issues/427)
- Implement visual transition notification [\#426](https://github.com/fecgov/openFEC/issues/426)
- Get selenium tests running with Travis/ Sauce [\#422](https://github.com/fecgov/openFEC/issues/422)
- Disambiguate "list" and "detail" endpoints by giving them appropriately singular and plural names [\#417](https://github.com/fecgov/openFEC/issues/417)
-  adding the list of election years in the results returned from /candidate [\#411](https://github.com/fecgov/openFEC/issues/411)
- Create `Report` SQLAlchemy model / Python view [\#409](https://github.com/fecgov/openFEC/issues/409)
- Create `/reports` database view/table [\#408](https://github.com/fecgov/openFEC/issues/408)
- Implement `/committee/\<id\>/candidates` route, et al [\#407](https://github.com/fecgov/openFEC/issues/407)
- /committee/id detail 2/2 [\#406](https://github.com/fecgov/openFEC/issues/406)
- Build out Product Backlog [\#405](https://github.com/fecgov/openFEC/issues/405)
- Rework or rewrite Selenium tests [\#404](https://github.com/fecgov/openFEC/issues/404)
- /committee/id detail 1/2 [\#403](https://github.com/fecgov/openFEC/issues/403)
- Create user stories from user research [\#402](https://github.com/fecgov/openFEC/issues/402)
- Make `/totals` database \(SQLAlchemy\) model and rewrite route/filtering to use it [\#401](https://github.com/fecgov/openFEC/issues/401)
- Create Workflow of FEC.gov [\#400](https://github.com/fecgov/openFEC/issues/400)
- Implement totals API refactor changes to front end Flask app [\#399](https://github.com/fecgov/openFEC/issues/399)
- committee search 2 of 2 [\#398](https://github.com/fecgov/openFEC/issues/398)
- Implement "no data" for candidate / committee pages [\#397](https://github.com/fecgov/openFEC/issues/397)
- Implement committee search API refactor changes to front end Flask [\#396](https://github.com/fecgov/openFEC/issues/396)
- Create `/totals` database view/table [\#395](https://github.com/fecgov/openFEC/issues/395)
- committee search 1 of 2 [\#394](https://github.com/fecgov/openFEC/issues/394)
- Showing stats for Joint Committees [\#391](https://github.com/fecgov/openFEC/issues/391)
- Visually separate principal committees from other committees [\#389](https://github.com/fecgov/openFEC/issues/389)
- consider a less common separator for 'fields'  [\#385](https://github.com/fecgov/openFEC/issues/385)
- Clarify origin of fields/values [\#384](https://github.com/fecgov/openFEC/issues/384)
- include comprehensive list of potential values [\#383](https://github.com/fecgov/openFEC/issues/383)
- Optimize queries and documentation for user's use cases  [\#380](https://github.com/fecgov/openFEC/issues/380)
- Ensure that interactive documentation doesn't require another query  [\#379](https://github.com/fecgov/openFEC/issues/379)
- Ensure example endpoints load quickly and easily [\#378](https://github.com/fecgov/openFEC/issues/378)
- api is underscored instead of camelcase [\#377](https://github.com/fecgov/openFEC/issues/377)
- Add links to terms/forms/etc. where possible  [\#376](https://github.com/fecgov/openFEC/issues/376)
- 'candidate' vs 'candidates' [\#375](https://github.com/fecgov/openFEC/issues/375)
- Better offer the options for different variables  [\#374](https://github.com/fecgov/openFEC/issues/374)
- Add example API calls  [\#372](https://github.com/fecgov/openFEC/issues/372)
- ensure more consistent capitalization  [\#371](https://github.com/fecgov/openFEC/issues/371)
- Add Flask migrations [\#369](https://github.com/fecgov/openFEC/issues/369)
- Integration tests should include JS [\#366](https://github.com/fecgov/openFEC/issues/366)
- Write SQL view for committee search [\#364](https://github.com/fecgov/openFEC/issues/364)
- Flesh out API tests to include testing the actual data dicts that are returned [\#363](https://github.com/fecgov/openFEC/issues/363)
- Use Candidate model to reimplement /candidate/\<id\> endpoint [\#362](https://github.com/fecgov/openFEC/issues/362)
- Field Name Mismatch FEC & API [\#359](https://github.com/fecgov/openFEC/issues/359)
- Candidate not filtering by year in the database [\#358](https://github.com/fecgov/openFEC/issues/358)
- Make spreadsheet of json names, FEC names and what tables they come form  [\#356](https://github.com/fecgov/openFEC/issues/356)
- Make spreadsheet of json names, FEC names and what tables they come form  [\#354](https://github.com/fecgov/openFEC/issues/354)
- Pilot usability script with 18Fers [\#352](https://github.com/fecgov/openFEC/issues/352)
- Specify fields in totals endpoint calls [\#350](https://github.com/fecgov/openFEC/issues/350)
- Come up with a plan for handling support emails [\#347](https://github.com/fecgov/openFEC/issues/347)
- double check flask [\#344](https://github.com/fecgov/openFEC/issues/344)
- keep api results consistent when there are no results returned [\#337](https://github.com/fecgov/openFEC/issues/337)
- Define what happens when there is no summary data [\#333](https://github.com/fecgov/openFEC/issues/333)
- map out summary pages [\#330](https://github.com/fecgov/openFEC/issues/330)
- Merge all committee ids in one total endpoint call [\#329](https://github.com/fecgov/openFEC/issues/329)
- Avoid duplicate results in /name REST endpoint \(for typeahead\) [\#328](https://github.com/fecgov/openFEC/issues/328)
- Implement full gamut of party filters and make sure the table outputs right field [\#327](https://github.com/fecgov/openFEC/issues/327)
- Finish error handling for front end Flask app [\#326](https://github.com/fecgov/openFEC/issues/326)
- rename /total /summary [\#325](https://github.com/fecgov/openFEC/issues/325)
- Unit test front end Flask app [\#324](https://github.com/fecgov/openFEC/issues/324)
- Make election cycle dropdown work using the new history endpoint [\#323](https://github.com/fecgov/openFEC/issues/323)
- Finalize the app diagram [\#322](https://github.com/fecgov/openFEC/issues/322)
- Remove broken / not-yet-working functionality [\#321](https://github.com/fecgov/openFEC/issues/321)
- Fix visual bugs with typeahead [\#320](https://github.com/fecgov/openFEC/issues/320)
- add fields to the api queries to speed up queries [\#319](https://github.com/fecgov/openFEC/issues/319)
- Update CSS for new designs [\#318](https://github.com/fecgov/openFEC/issues/318)
- add coverage dates in /total [\#317](https://github.com/fecgov/openFEC/issues/317)
- Map committee types and fields for report summaries [\#316](https://github.com/fecgov/openFEC/issues/316)
- First Draft of Error Messaging [\#315](https://github.com/fecgov/openFEC/issues/315)
- Finish new round of design refresh [\#314](https://github.com/fecgov/openFEC/issues/314)
- API usability testing [\#313](https://github.com/fecgov/openFEC/issues/313)
- Quick once over and minor CSS tweaks for API documentation [\#312](https://github.com/fecgov/openFEC/issues/312)
- Code financial summary charts [\#311](https://github.com/fecgov/openFEC/issues/311)
- Figure out page titles [\#310](https://github.com/fecgov/openFEC/issues/310)
- Financial totals implemented on committee pages [\#309](https://github.com/fecgov/openFEC/issues/309)
- Web App Hallway Usability Testing [\#308](https://github.com/fecgov/openFEC/issues/308)
- Complete draft of API documentation [\#307](https://github.com/fecgov/openFEC/issues/307)
- Design what happens when no results returned [\#306](https://github.com/fecgov/openFEC/issues/306)
- Donations API endpoint [\#305](https://github.com/fecgov/openFEC/issues/305)
- Create new table that unifies financial summary totals [\#304](https://github.com/fecgov/openFEC/issues/304)
- Code charts on candidate and committee pages [\#300](https://github.com/fecgov/openFEC/issues/300)
- Implement MVP version of the glossary [\#296](https://github.com/fecgov/openFEC/issues/296)
- compressing API results [\#295](https://github.com/fecgov/openFEC/issues/295)
- Typeahead + nav [\#282](https://github.com/fecgov/openFEC/issues/282)
- cycle filtering on totals endpoint [\#280](https://github.com/fecgov/openFEC/issues/280)
- Create icons for Candidates and Committees [\#279](https://github.com/fecgov/openFEC/issues/279)
- Start public-facing docs [\#278](https://github.com/fecgov/openFEC/issues/278)
- Design reviews with 18F designers [\#277](https://github.com/fecgov/openFEC/issues/277)
- 1 User interview: lawyer [\#276](https://github.com/fecgov/openFEC/issues/276)
- Document how all chart data will be received [\#275](https://github.com/fecgov/openFEC/issues/275)
- Make purposal of what FEC API docs will look like [\#274](https://github.com/fecgov/openFEC/issues/274)
- Functional testing audit doc [\#273](https://github.com/fecgov/openFEC/issues/273)
- Explore charting options [\#272](https://github.com/fecgov/openFEC/issues/272)
- Make annotated version of mocs [\#271](https://github.com/fecgov/openFEC/issues/271)
- Restore connectivity to data transfer machine [\#270](https://github.com/fecgov/openFEC/issues/270)
- Add the election cycle to reports that come back with the totals endpoint [\#268](https://github.com/fecgov/openFEC/issues/268)
- format API headers [\#267](https://github.com/fecgov/openFEC/issues/267)
- Refactor typeahead to use new API [\#260](https://github.com/fecgov/openFEC/issues/260)
- sort the totals fields with the most recent on the top  [\#256](https://github.com/fecgov/openFEC/issues/256)
- add filtering for committee by year [\#254](https://github.com/fecgov/openFEC/issues/254)
- Tune typeahead [\#249](https://github.com/fecgov/openFEC/issues/249)
- Tune /totals endpoint [\#248](https://github.com/fecgov/openFEC/issues/248)
- Tuning framework [\#247](https://github.com/fecgov/openFEC/issues/247)
- Add fields requsted [\#246](https://github.com/fecgov/openFEC/issues/246)
- Design solution for variable numbers of related entities [\#245](https://github.com/fecgov/openFEC/issues/245)
- Get Lindsay the fields we want to include on committee and candidate endpoints [\#244](https://github.com/fecgov/openFEC/issues/244)
- Pull candidate data into committee pages on front end [\#243](https://github.com/fecgov/openFEC/issues/243)
- Pull totals data into candidate template on front end [\#240](https://github.com/fecgov/openFEC/issues/240)
- Build out HTML and CSS for totals data on candidate page [\#239](https://github.com/fecgov/openFEC/issues/239)
- Schedule API usability testing [\#238](https://github.com/fecgov/openFEC/issues/238)
- 3 User Interviews [\#237](https://github.com/fecgov/openFEC/issues/237)
- API/query tuning [\#236](https://github.com/fecgov/openFEC/issues/236)
- Field filtering for summary endpoint [\#235](https://github.com/fecgov/openFEC/issues/235)
- Fix internal cites in eRegs [\#234](https://github.com/fecgov/openFEC/issues/234)
- Do Node implementation of candidate page totals data [\#233](https://github.com/fecgov/openFEC/issues/233)
- Design new charts for candidate and committee pages [\#232](https://github.com/fecgov/openFEC/issues/232)
- Add the ability to change the number of results that are viewed on a page [\#230](https://github.com/fecgov/openFEC/issues/230)
- Find where coverage dates come from [\#229](https://github.com/fecgov/openFEC/issues/229)
- Extend search and browse Selenium tests to include sorting results [\#228](https://github.com/fecgov/openFEC/issues/228)
- Extend search and browse Selenium tests to include clicking on a result [\#227](https://github.com/fecgov/openFEC/issues/227)
- Extend search Selenium test to include filters and nav search field [\#226](https://github.com/fecgov/openFEC/issues/226)
- Nav search bar field isn't working [\#225](https://github.com/fecgov/openFEC/issues/225)
- Search results views should be loaded by Node [\#224](https://github.com/fecgov/openFEC/issues/224)
- Search results views should have a unique URL [\#223](https://github.com/fecgov/openFEC/issues/223)
- Tablesort doesn't init if loaded from Node [\#222](https://github.com/fecgov/openFEC/issues/222)
- Create real copy for error modals [\#216](https://github.com/fecgov/openFEC/issues/216)
- Create 404 and server error pages [\#215](https://github.com/fecgov/openFEC/issues/215)
- Determine and implement how filters work w/o JS [\#214](https://github.com/fecgov/openFEC/issues/214)
- Totals endpoint test [\#213](https://github.com/fecgov/openFEC/issues/213)
- Mock API in Selenium tests [\#211](https://github.com/fecgov/openFEC/issues/211)
- Special election totals seprate [\#208](https://github.com/fecgov/openFEC/issues/208)
- Change entity endpoint formatting [\#207](https://github.com/fecgov/openFEC/issues/207)
- committee party fix [\#200](https://github.com/fecgov/openFEC/issues/200)
- Draft usability testing script [\#196](https://github.com/fecgov/openFEC/issues/196)
- Data follow up [\#195](https://github.com/fecgov/openFEC/issues/195)
- set up webserver for fec.18f.us/eregs [\#194](https://github.com/fecgov/openFEC/issues/194)
- Sample of receipts data [\#193](https://github.com/fecgov/openFEC/issues/193)
- Add eRegs to fec.18f.us/eregs [\#192](https://github.com/fecgov/openFEC/issues/192)
- Begin regular refresh of data from FEC [\#191](https://github.com/fecgov/openFEC/issues/191)
- Design MVP version of the receipts table [\#190](https://github.com/fecgov/openFEC/issues/190)
- Partial duplicate of FEC's PROCESSED schema [\#189](https://github.com/fecgov/openFEC/issues/189)
- Duplicate FORM\_\* data from FEC's PROCESSED schema [\#188](https://github.com/fecgov/openFEC/issues/188)
- Design MVP version of the candidate page [\#187](https://github.com/fecgov/openFEC/issues/187)
- Design MVP version of the Committee page [\#186](https://github.com/fecgov/openFEC/issues/186)
- Design MVP version of district page [\#185](https://github.com/fecgov/openFEC/issues/185)
- Totals endpoint [\#177](https://github.com/fecgov/openFEC/issues/177)
- Ordering results ascending or descending by a field of the user's choice [\#176](https://github.com/fecgov/openFEC/issues/176)
- filters [\#173](https://github.com/fecgov/openFEC/issues/173)
- Year improvements to the API [\#172](https://github.com/fecgov/openFEC/issues/172)
- Tweak committee API endpoint [\#171](https://github.com/fecgov/openFEC/issues/171)
- Implement changes to committee API endpoint in JS [\#167](https://github.com/fecgov/openFEC/issues/167)
- Determine difficulty of adapting eRegs for FEC regulations [\#166](https://github.com/fecgov/openFEC/issues/166)
- Research Receipts data [\#165](https://github.com/fecgov/openFEC/issues/165)
- Make committee pages use live data [\#164](https://github.com/fecgov/openFEC/issues/164)
- Make candidate pages use live data [\#163](https://github.com/fecgov/openFEC/issues/163)
- Reach out to 5-10 regulations users to interview  [\#162](https://github.com/fecgov/openFEC/issues/162)
- Live performance status document [\#161](https://github.com/fecgov/openFEC/issues/161)
- What other data can we associate with candidates/committees? [\#155](https://github.com/fecgov/openFEC/issues/155)
- See if amended data is being quiered [\#154](https://github.com/fecgov/openFEC/issues/154)
- Add form 1 data [\#153](https://github.com/fecgov/openFEC/issues/153)
- API Structure Refactor [\#152](https://github.com/fecgov/openFEC/issues/152)
- Run Selenium tests via Travis [\#151](https://github.com/fecgov/openFEC/issues/151)
- Run Selenium tests via Sauce Labs [\#150](https://github.com/fecgov/openFEC/issues/150)
- Split out some modules in client app [\#149](https://github.com/fecgov/openFEC/issues/149)
- Untangle templating module [\#148](https://github.com/fecgov/openFEC/issues/148)
- Evaluate event streams in client side app [\#147](https://github.com/fecgov/openFEC/issues/147)
- Write Selenium tests [\#146](https://github.com/fecgov/openFEC/issues/146)
- Figure out what lang to implement Selenium WebDriver tests in [\#145](https://github.com/fecgov/openFEC/issues/145)
- Draft the single election, multi-candidate view [\#144](https://github.com/fecgov/openFEC/issues/144)
- Create visual links between candidate and committee pages [\#143](https://github.com/fecgov/openFEC/issues/143)
- Format committees [\#142](https://github.com/fecgov/openFEC/issues/142)
- API refactor meeting [\#141](https://github.com/fecgov/openFEC/issues/141)
- Data follow up [\#140](https://github.com/fecgov/openFEC/issues/140)
- Attempt initial responsive design [\#139](https://github.com/fecgov/openFEC/issues/139)
- Code static candidate and committee pages [\#138](https://github.com/fecgov/openFEC/issues/138)
- Refactor CSS [\#137](https://github.com/fecgov/openFEC/issues/137)
- Compile CSS on server [\#136](https://github.com/fecgov/openFEC/issues/136)
- cooperative [\#134](https://github.com/fecgov/openFEC/issues/134)
- show organization type for committees [\#131](https://github.com/fecgov/openFEC/issues/131)
- Logo should link back to the home page [\#127](https://github.com/fecgov/openFEC/issues/127)
- Code style guide page [\#126](https://github.com/fecgov/openFEC/issues/126)
- Take advantage of template caching [\#116](https://github.com/fecgov/openFEC/issues/116)
- Handle zero results [\#115](https://github.com/fecgov/openFEC/issues/115)
- When the FEC gives us committee party information, remove fake\_party add real filtering [\#113](https://github.com/fecgov/openFEC/issues/113)
- Compile JS on server [\#110](https://github.com/fecgov/openFEC/issues/110)
- Filter tags should display description, not code [\#109](https://github.com/fecgov/openFEC/issues/109)
- Style + position error modal [\#107](https://github.com/fecgov/openFEC/issues/107)
- Make clone of browse view for search [\#106](https://github.com/fecgov/openFEC/issues/106)
- Implement filters in Node app for candidates [\#105](https://github.com/fecgov/openFEC/issues/105)
- Activate filters in the UI if the page is loaded with them [\#104](https://github.com/fecgov/openFEC/issues/104)
- Implement pagination and results counts in Node [\#103](https://github.com/fecgov/openFEC/issues/103)
- Results counts and pagination styling [\#102](https://github.com/fecgov/openFEC/issues/102)
- Polish result table styling [\#101](https://github.com/fecgov/openFEC/issues/101)
- Gray out search bar and filters while ajax requests are active [\#100](https://github.com/fecgov/openFEC/issues/100)
- Implement error handling on all ajax calls [\#99](https://github.com/fecgov/openFEC/issues/99)
- Style NProgress [\#98](https://github.com/fecgov/openFEC/issues/98)
- Sort out urls/back button [\#97](https://github.com/fecgov/openFEC/issues/97)
- Uptime improvements to deployment of flask API app [\#95](https://github.com/fecgov/openFEC/issues/95)
- User Story - Walkthrough [\#94](https://github.com/fecgov/openFEC/issues/94)
- Diagram flow throughout all screens of the web app [\#85](https://github.com/fecgov/openFEC/issues/85)
- Code new styles [\#84](https://github.com/fecgov/openFEC/issues/84)
- Complete v1 style guide [\#83](https://github.com/fecgov/openFEC/issues/83)
- Complete candidate and committee page designs [\#82](https://github.com/fecgov/openFEC/issues/82)
- Complete sitemap v1 [\#81](https://github.com/fecgov/openFEC/issues/81)
- Add API.md for openFEC-web-app [\#80](https://github.com/fecgov/openFEC/issues/80)
- Implement committee Node route [\#79](https://github.com/fecgov/openFEC/issues/79)
- Implement filters in Node app for candidates [\#78](https://github.com/fecgov/openFEC/issues/78)
- Implement committee filter API calls [\#77](https://github.com/fecgov/openFEC/issues/77)
- Implement committee filter UI [\#76](https://github.com/fecgov/openFEC/issues/76)
- Refactor search to send two requests for candidate and committee [\#75](https://github.com/fecgov/openFEC/issues/75)
- Make select filters single select [\#74](https://github.com/fecgov/openFEC/issues/74)
- Add + sign submit-type button to name filter [\#73](https://github.com/fecgov/openFEC/issues/73)
- Format the committees API [\#70](https://github.com/fecgov/openFEC/issues/70)
- Enable automated testing in TravisCI [\#69](https://github.com/fecgov/openFEC/issues/69)
- Create test database [\#68](https://github.com/fecgov/openFEC/issues/68)
- Consolidate current research [\#64](https://github.com/fecgov/openFEC/issues/64)
- Implement icon font [\#63](https://github.com/fecgov/openFEC/issues/63)
- Make API filter to current cycle after Demo [\#62](https://github.com/fecgov/openFEC/issues/62)
- Change font on table data [\#60](https://github.com/fecgov/openFEC/issues/60)
- Search query should pre-populate name filter [\#59](https://github.com/fecgov/openFEC/issues/59)
- Include total number of pages in response object [\#57](https://github.com/fecgov/openFEC/issues/57)
- keep webservices up  [\#49](https://github.com/fecgov/openFEC/issues/49)
- Begin live database status document [\#46](https://github.com/fecgov/openFEC/issues/46)
- Public API documentation [\#45](https://github.com/fecgov/openFEC/issues/45)
- Add version to API urls [\#44](https://github.com/fecgov/openFEC/issues/44)
- API side pagination  [\#43](https://github.com/fecgov/openFEC/issues/43)
- API endpoint for candidate list  [\#42](https://github.com/fecgov/openFEC/issues/42)
- Implement new API design [\#41](https://github.com/fecgov/openFEC/issues/41)
- Implement desired filters for /candidate [\#40](https://github.com/fecgov/openFEC/issues/40)
- Database performance tuning  [\#39](https://github.com/fecgov/openFEC/issues/39)
- Implement Bower [\#38](https://github.com/fecgov/openFEC/issues/38)
- Start thinking about the overall new FEC navigation [\#37](https://github.com/fecgov/openFEC/issues/37)
- Determine the list of data fields that should be associated with search results [\#36](https://github.com/fecgov/openFEC/issues/36)
- Design weighted list \(Presidential, Senate, House, etc…\) for search results [\#35](https://github.com/fecgov/openFEC/issues/35)
- Define Icon Usage [\#34](https://github.com/fecgov/openFEC/issues/34)
- Provide general disambiguation \(candidates & committees\) on search results pages [\#33](https://github.com/fecgov/openFEC/issues/33)
- Default to 2012 election cycle [\#32](https://github.com/fecgov/openFEC/issues/32)
- Build search disambiguation UI [\#31](https://github.com/fecgov/openFEC/issues/31)
- Style candidate table [\#30](https://github.com/fecgov/openFEC/issues/30)
- Build UI for filters [\#29](https://github.com/fecgov/openFEC/issues/29)
- Implement pagination in UI [\#28](https://github.com/fecgov/openFEC/issues/28)
- Render candidates results table [\#27](https://github.com/fecgov/openFEC/issues/27)
- Make search bar perform API request [\#26](https://github.com/fecgov/openFEC/issues/26)
- Build filter functionality [\#25](https://github.com/fecgov/openFEC/issues/25)
- Implement chosen.js [\#24](https://github.com/fecgov/openFEC/issues/24)
- Candidate Pages - Research and Wireframes [\#23](https://github.com/fecgov/openFEC/issues/23)
- Implement post merge hook on fec.18f.us [\#22](https://github.com/fecgov/openFEC/issues/22)
- Add links to associated committees to /candidate API output, and vice versa [\#21](https://github.com/fecgov/openFEC/issues/21)
- API should support individual resource pages for /candidate/\<id\>, /committee/\<id\>  [\#20](https://github.com/fecgov/openFEC/issues/20)
- Redesign API output [\#19](https://github.com/fecgov/openFEC/issues/19)
- Research the kinds of relationships users want to search for [\#17](https://github.com/fecgov/openFEC/issues/17)
- Research Compliance Docs  [\#15](https://github.com/fecgov/openFEC/issues/15)
- Work with devs to validate those workflows are supported by the API [\#14](https://github.com/fecgov/openFEC/issues/14)
- Validate User Search Workflows [\#13](https://github.com/fecgov/openFEC/issues/13)
- Design other user search workflows [\#12](https://github.com/fecgov/openFEC/issues/12)
- Research what people are searching for under current analytics [\#11](https://github.com/fecgov/openFEC/issues/11)
- Use fake API response to populate autocomplete [\#10](https://github.com/fecgov/openFEC/issues/10)
- Create a static search page [\#9](https://github.com/fecgov/openFEC/issues/9)
- Determine technical feasibility of calculating sum contributions [\#8](https://github.com/fecgov/openFEC/issues/8)
- Research how FEC data can be used to display relationships [\#7](https://github.com/fecgov/openFEC/issues/7)
- Proxy between JSON API and database [\#6](https://github.com/fecgov/openFEC/issues/6)
- Create replication job [\#5](https://github.com/fecgov/openFEC/issues/5)
- Standup that technology stack  [\#4](https://github.com/fecgov/openFEC/issues/4)
- Decide on a technology stack for data storage and retrieval from FEC [\#3](https://github.com/fecgov/openFEC/issues/3)
- What needs to happen on the backend to support API queries? [\#2](https://github.com/fecgov/openFEC/issues/2)
- What type of API queries do we want to offer? [\#1](https://github.com/fecgov/openFEC/issues/1)

**Merged pull requests:**

- Document git-flow and deployment workflow. [\#954](https://github.com/fecgov/openFEC/pull/954) ([jmcarp](https://github.com/jmcarp))
- Added missing levin fund totals in API [\#949](https://github.com/fecgov/openFEC/pull/949) ([LindsayYoung](https://github.com/LindsayYoung))
- Smaller manifests with inheritance and promotion. [\#941](https://github.com/fecgov/openFEC/pull/941) ([jmcarp](https://github.com/jmcarp))
- Use consistent endpoints for candidate and committee history resources. [\#933](https://github.com/fecgov/openFEC/pull/933) ([jmcarp](https://github.com/jmcarp))
- Add link to github fix in docs [\#929](https://github.com/fecgov/openFEC/pull/929) ([LindsayYoung](https://github.com/LindsayYoung))
- Update \<title\> for API docs. [\#927](https://github.com/fecgov/openFEC/pull/927) ([jmcarp](https://github.com/jmcarp))
- Make git hooks executable. [\#926](https://github.com/fecgov/openFEC/pull/926) ([jmcarp](https://github.com/jmcarp))
- Update README with testing instructions [\#924](https://github.com/fecgov/openFEC/pull/924) ([arowla](https://github.com/arowla))
- List of options now look like formatted code [\#923](https://github.com/fecgov/openFEC/pull/923) ([LindsayYoung](https://github.com/LindsayYoung))
- Create new engine for each multiprocessing instance. [\#922](https://github.com/fecgov/openFEC/pull/922) ([jmcarp](https://github.com/jmcarp))
- Feature/improve performance [\#921](https://github.com/fecgov/openFEC/pull/921) ([jmcarp](https://github.com/jmcarp))
- Add pacronyms to committee search. [\#916](https://github.com/fecgov/openFEC/pull/916) ([jmcarp](https://github.com/jmcarp))
- Install flask extensions from PyPI; use recent versions. [\#915](https://github.com/fecgov/openFEC/pull/915) ([jmcarp](https://github.com/jmcarp))
- Remove custom JSON encoder. [\#914](https://github.com/fecgov/openFEC/pull/914) ([jmcarp](https://github.com/jmcarp))
- Build fulltext search views from detail views. [\#913](https://github.com/fecgov/openFEC/pull/913) ([jmcarp](https://github.com/jmcarp))
- Delete two year period table. [\#912](https://github.com/fecgov/openFEC/pull/912) ([jmcarp](https://github.com/jmcarp))
- Add placeholders for Swagger tag descriptions. [\#907](https://github.com/fecgov/openFEC/pull/907) ([LindsayYoung](https://github.com/LindsayYoung))
- Add API key to Swagger in production. [\#904](https://github.com/fecgov/openFEC/pull/904) ([jmcarp](https://github.com/jmcarp))
- Feature/consolidate search [\#893](https://github.com/fecgov/openFEC/pull/893) ([jmcarp](https://github.com/jmcarp))
- Hide internal fields from Swagger output. [\#892](https://github.com/fecgov/openFEC/pull/892) ([jmcarp](https://github.com/jmcarp))
- Add more wildcards to search terms. [\#891](https://github.com/fecgov/openFEC/pull/891) ([jmcarp](https://github.com/jmcarp))
- Use BigInteger to avoid overflow on image numbers. [\#890](https://github.com/fecgov/openFEC/pull/890) ([jmcarp](https://github.com/jmcarp))
- Allow specification of included and excluded report types. [\#887](https://github.com/fecgov/openFEC/pull/887) ([jmcarp](https://github.com/jmcarp))
- Feature/resource wildcard search [\#882](https://github.com/fecgov/openFEC/pull/882) ([jmcarp](https://github.com/jmcarp))
- Calculate cycles from F1 and F3 filings. [\#878](https://github.com/fecgov/openFEC/pull/878) ([jmcarp](https://github.com/jmcarp))
- Feature/consolidate views [\#876](https://github.com/fecgov/openFEC/pull/876) ([jmcarp](https://github.com/jmcarp))
- Use `beginning\_image\_number` to generate PDF URL. [\#874](https://github.com/fecgov/openFEC/pull/874) ([jmcarp](https://github.com/jmcarp))
- Add pdf-url to schema [\#873](https://github.com/fecgov/openFEC/pull/873) ([LindsayYoung](https://github.com/LindsayYoung))
- Feature/update swagger spec [\#871](https://github.com/fecgov/openFEC/pull/871) ([jmcarp](https://github.com/jmcarp))
- Adding drop-downs and explanations to the API documentaion [\#867](https://github.com/fecgov/openFEC/pull/867) ([LindsayYoung](https://github.com/LindsayYoung))
- Feature/candidate committees by cycle [\#866](https://github.com/fecgov/openFEC/pull/866) ([jmcarp](https://github.com/jmcarp))
- updated help [\#862](https://github.com/fecgov/openFEC/pull/862) ([LindsayYoung](https://github.com/LindsayYoung))
- Feature/docs cleanup [\#861](https://github.com/fecgov/openFEC/pull/861) ([jmcarp](https://github.com/jmcarp))
- Feature/typeahead search by resource [\#859](https://github.com/fecgov/openFEC/pull/859) ([jmcarp](https://github.com/jmcarp))
- Feature/consistent queries [\#858](https://github.com/fecgov/openFEC/pull/858) ([jmcarp](https://github.com/jmcarp))
- Fix sorting on candidate search view. [\#857](https://github.com/fecgov/openFEC/pull/857) ([jmcarp](https://github.com/jmcarp))
- Add full addresses to committee history table. [\#856](https://github.com/fecgov/openFEC/pull/856) ([jmcarp](https://github.com/jmcarp))
- Generate incumbency status in candidate history view. [\#853](https://github.com/fecgov/openFEC/pull/853) ([jmcarp](https://github.com/jmcarp))
- Auto-generate schemas using marshmallow\_sqlalchemy. [\#845](https://github.com/fecgov/openFEC/pull/845) ([jmcarp](https://github.com/jmcarp))
- Feature/harmonize financials columns [\#844](https://github.com/fecgov/openFEC/pull/844) ([jmcarp](https://github.com/jmcarp))
- Calculate committee cycles from fact tables. [\#843](https://github.com/fecgov/openFEC/pull/843) ([jmcarp](https://github.com/jmcarp))
- Feature/nrsc fixes [\#842](https://github.com/fecgov/openFEC/pull/842) ([LindsayYoung](https://github.com/LindsayYoung))
- Move repeated columns to base classes. [\#834](https://github.com/fecgov/openFEC/pull/834) ([jmcarp](https://github.com/jmcarp))
- Feature/committee history [\#830](https://github.com/fecgov/openFEC/pull/830) ([jmcarp](https://github.com/jmcarp))
- ttl\_receipts\_per\_i, ttl\_receipts\_ii act as one data point [\#829](https://github.com/fecgov/openFEC/pull/829) ([LindsayYoung](https://github.com/LindsayYoung))
- Feature/dedupe totals [\#826](https://github.com/fecgov/openFEC/pull/826) ([LindsayYoung](https://github.com/LindsayYoung))
- Feature/sort everything [\#825](https://github.com/fecgov/openFEC/pull/825) ([jmcarp](https://github.com/jmcarp))
- Backend updates to accommodate cycle filtering for candidates. [\#824](https://github.com/fecgov/openFEC/pull/824) ([jmcarp](https://github.com/jmcarp))
- Changed coh\_cop workaround to use COALESCE [\#806](https://github.com/fecgov/openFEC/pull/806) ([arowla](https://github.com/arowla))
- Feature/coh fix [\#804](https://github.com/fecgov/openFEC/pull/804) ([LindsayYoung](https://github.com/LindsayYoung))
- Remove duplicated reports. [\#803](https://github.com/fecgov/openFEC/pull/803) ([jmcarp](https://github.com/jmcarp))
- Upgrade marshmallow to development version. [\#802](https://github.com/fecgov/openFEC/pull/802) ([jmcarp](https://github.com/jmcarp))
- Use consistent names for reports columns. [\#801](https://github.com/fecgov/openFEC/pull/801) ([jmcarp](https://github.com/jmcarp))
- Feature/exclude form z only filers [\#795](https://github.com/fecgov/openFEC/pull/795) ([jmcarp](https://github.com/jmcarp))
- Feature/sort everything [\#792](https://github.com/fecgov/openFEC/pull/792) ([jmcarp](https://github.com/jmcarp))
- Fix principal committee join. [\#790](https://github.com/fecgov/openFEC/pull/790) ([jmcarp](https://github.com/jmcarp))
- Blue-green deploys. [\#784](https://github.com/fecgov/openFEC/pull/784) ([jmcarp](https://github.com/jmcarp))
- Changed staging branch from 'master' to 'release' [\#783](https://github.com/fecgov/openFEC/pull/783) ([arowla](https://github.com/arowla))
- Include subset dump compatible with `pg\_restore`. [\#782](https://github.com/fecgov/openFEC/pull/782) ([jmcarp](https://github.com/jmcarp))
- Feature/api docs routes [\#781](https://github.com/fecgov/openFEC/pull/781) ([jmcarp](https://github.com/jmcarp))
- Changed report views to exclude expired reports [\#779](https://github.com/fecgov/openFEC/pull/779) ([arowla](https://github.com/arowla))
- Feature/narrative docs [\#774](https://github.com/fecgov/openFEC/pull/774) ([jmcarp](https://github.com/jmcarp))
- Restore correct `election\_years` and `active\_through` columns. [\#770](https://github.com/fecgov/openFEC/pull/770) ([jmcarp](https://github.com/jmcarp))
- Harmonize incumbent status across views. [\#769](https://github.com/fecgov/openFEC/pull/769) ([jmcarp](https://github.com/jmcarp))
- Clarify test subset usage. [\#768](https://github.com/fecgov/openFEC/pull/768) ([jmcarp](https://github.com/jmcarp))
- Fixing incumbent [\#767](https://github.com/fecgov/openFEC/pull/767) ([LindsayYoung](https://github.com/LindsayYoung))
- Harmonize committee list and committee detail views. [\#766](https://github.com/fecgov/openFEC/pull/766) ([jmcarp](https://github.com/jmcarp))
- Changed dimcandoffice to pull just most recent [\#765](https://github.com/fecgov/openFEC/pull/765) ([arowla](https://github.com/arowla))
- Adding Code Climate GPA and Coverage badges [\#729](https://github.com/fecgov/openFEC/pull/729) ([arowla](https://github.com/arowla))



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
