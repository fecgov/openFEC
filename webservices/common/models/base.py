import random

import celery
from flask.ext.sqlalchemy import SQLAlchemy
from flask.ext.sqlalchemy import SignallingSession


class RoutingSession(SignallingSession):
    """Route requests to database leader or follower as appropriate.

    Based on http://techspot.zzzeek.org/2012/01/11/django-style-database-routers-in-sqlalchemy/
    """

    @property
    def followers(self):
        return self.app.config['SQLALCHEMY_FOLLOWERS']

    @property
    def replica_tasks(self):
        return self.app.config['SQLALCHEMY_REPLICA_TASKS']

    def get_bind(self, mapper=None, clause=None):
        use_follower = (
            not self._flushing and
            celery.current_task and
            celery.current_task.name in self.replica_tasks and
            self.followers
        )
        if use_follower:
            return random.choice(self.followers)
        return super().get_bind(mapper=mapper, clause=clause)


class RoutingSQLAlchemy(SQLAlchemy):

    def create_session(self, options):
        return RoutingSession(self, **options)


db = RoutingSQLAlchemy()


class BaseModel(db.Model):
    __abstract__ = True
    idx = db.Column(db.Integer, primary_key=True)
