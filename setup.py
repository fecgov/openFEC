import setuptools

setuptools.setup(
  name='openfec',
  version='0.01',
  maintainer='openFEC',
  maintainer_email='sean.herron@gsa.gov',
  install_requires=[
    'click',
    'luigi',
    'nose',
    'python-gflags',
    'pyyaml',
    'simplejson',
    'xmltodict',
    'scrapelib',
    'leveldb',
    'simplejson',
    'requests',
    'elasticsearch'
  ],
  description=('A research project to provide open APIs, raw data downloads, '
               'documentation and examples, and a developer community for an '
               'important collection of FEC public datasets.'),
  packages = ['openfec',
              'openfec.entities',
              ],
  zip_safe=False,
  test_suite = 'nose.collector',
)