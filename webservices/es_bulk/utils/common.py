import json
import datetime
import os


json.JSONEncoder.default = lambda self, obj: (obj.isoformat() if isinstance(obj, datetime.datetime) else None)


def print_json(value):
    return json.dumps(value, indent=4, sort_keys=True)


def get_mappings(filename):
    with open(filename) as infile:
        return json.load(infile)


def get_data_loader_type(file):
    with open(file, 'r') as infile:
        for _, l in enumerate(infile):
            if "import" in l and "DataLoaderZeroDownTime" in l and "#" not in l:
                return "Zero-downtime ES data loader"
    return "Regular ES data loader"


def get_projects(project_dir="../projects"):
    project_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), project_dir))
    res = []
    projects_available = [x for x in os.listdir(project_dir) if not x.startswith("__")]
    for project_name in projects_available:
        current_dir = os.path.join(project_dir, project_name)
        if "index.py" in os.listdir(current_dir):
            current = [project_name, get_data_loader_type(os.path.join(current_dir, "index.py"))]
            res.append(current)
    return sorted(res)
