from __future__ import print_function
import importlib
import logging
from utils.common import get_projects

import click
from prettytable import PrettyTable


@click.group()
def cli1():
    pass


@click.group()
def cli2():
    pass


@cli1.command()
def list():
    """Command to list the projects in the directory

    example:
        python pipeline.py list
    """
    projects = get_projects()
    if projects:
        table = PrettyTable(["No.", "Project Name", "Data Loader Type"])
        for i, x in enumerate(projects):
            table.add_row([i + 1] + x)
        print(table)
    else:
        print("Currently there is no project available.")


@cli2.command()
@click.option('--projects', default="", help='Specify the projects to be run')
@click.option('--settings', default='settings.dev', help='Environment settings')
@click.option('--verbose', default=2, help='Verbose logging (repeat for more verbose)')
def run(projects, settings, verbose):
    """Command to run the specified projects

    example:
        python pipeline.py run --projects=sampler --settings=settings.dev

    """

    levels = [logging.ERROR, logging.WARN, logging.INFO, logging.DEBUG]
    logging.basicConfig(level=levels[min(verbose, len(levels) - 1)],
                        format='%(asctime)s - %(name)s - %(levelname)s: %(message)s',
                        datefmt="%Y-%m-%d %H:%M:%S")
    # exclude elasticsearch since it generates too much logging at lower level
    logging.getLogger('elasticsearch').setLevel(logging.WARNING)

    settings = importlib.import_module(settings)

    if projects == "":
        logging.warning("Since no project is specified, the program will run all projects available.")
        current_projects = get_projects()
    else:
        current_projects = [x.strip() for x in projects.split(',')]

    for each_project in current_projects:
        logging.warning("Now will run the project of {}.".format(each_project))
        exec("from projects.{} import index as {}_index".format(each_project, each_project))
        exec("{}_index.build(settings)".format(each_project))
        logging.warning("The project {} is finished.".format(each_project))


cli = click.CommandCollection(sources=[cli1, cli2])

if __name__ == '__main__':
    cli()
