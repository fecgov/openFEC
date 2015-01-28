# openFEC

We are taking data from the Federal Election Commission and creating an API around it. We will be harmonizing/cleaning it up to make it easier for external developers to use and analyze as well as creating a web application to make some analyzation and comparison of the data easier.

**Note**: This project is still in alpha and not yet deployed. We're still investigating the best ways to present this data to the public.

## Outside Contributors

Hello! If you're interested in learning more about this project, check out some related repos and don't be afraid to ask us questions (general questions usually go here: [fec](https://github.com/18F/fec)). 

If you'd like to contribute to our project, please check out our [openfec] (https://github.com/18F/openfec) repo. We try to tag things that are easy to pick up without being entrenched in our project with a "help wanted" tag. Things in our [backlog] (https://github.com/18F/openfec/milestones/Backlog) are usually also up for grabs, so let us know if you'd like to pick something up from there. 

For those interested in contributing, please check out our [contributing guidelies] (https://github.com/18F/openfec/blob/master/CONTRIBUTING.md) we use to guide our development processes internally. You don't have to adhere to them to participate, but following them may help keep things from getting messy. 

## Our Repos

* [fec](https://github.com/18F/fec) - A discussion forum where we can discuss the project. 
* [openfec] (https://github.com/18F/openfec) - Where our work happens. We create issues related to each sprint and our backlog here. If you're interested in contribution, please look for "help wanted" tags or ask!

## Installation
This will work best when installed in to its own [Virtual Environment](http://docs.python-guide.org/en/latest/dev/virtualenvs/)

- `$ python setup.py develop`
- `$ python openfec/entities/pipeline.py CleanData --local-scheduler`

This will showcase work so far, which includes combining data from a number of different raw exports from FEC's Data Warehouse (sample files are downloaded) in to a single local database powered by LevelDB for analysis, then beginning the steps of cleaning this data to be a little more sane.

More to come!
