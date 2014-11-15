# openFEC

We are taking data from the Federal Election Commission and creating an API around it. We will be harmonizing/cleaning it up to make it easier for external developers to use and analyze as well as creating a web application to make some analyzation and comparison of the data easier.

**Note**: This project is still in alpha and may never be deployed. We're still investigating the best ways to present this data to the public.

There is a corresponding web application at [18F/openFEC-web-app](http://github.com/18F/openFEC-web-app).

## Installation
This will work best when installed in to its own [Virtual Environment](http://docs.python-guide.org/en/latest/dev/virtualenvs/)

- `$ python setup.py develop`
- `$ python openfec/entities/pipeline.py CleanData --local-scheduler`

This will showcase work so far, which includes combining data from a number of different raw exports from FEC's Data Warehouse (sample files are downloaded) in to a single local database powered by LevelDB for analysis, then beginning the steps of cleaning this data to be a little more sane.

More to come!
