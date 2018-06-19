import random

import celery
from flask_sqlalchemy import SQLAlchemy
from flask_sqlalchemy import SignallingSession


class RoutingSession(SignallingSession):
    """Route requests to database leader or follower as appropriate.

    Based on http://techspot.zzzeek.org/2012/01/11/django-style-database-routers-in-sqlalchemy/
    """

    @property
    def followers(self):
        return self.app.config['SQLALCHEMY_FOLLOWERS']

    @property
    def follower_tasks(self):
        return self.app.config['SQLALCHEMY_FOLLOWER_TASKS']

    @property
    def restrict_follower_traffic_to_tasks(self):
        return self.app.config['SQLALCHEMY_RESTRICT_FOLLOWER_TRAFFIC_TO_TASKS']

    @property
    def use_follower(self):
        # Check for read operations and configured followers.
        use_follower = (
            not self._flushing and
            len(self.followers) > 0
        )

        # Optionally restrict traffic to followers for only supported tasks.
        if use_follower and self.restrict_follower_traffic_to_tasks:
            use_follower = (
                celery.current_task and
                celery.current_task.name in self.follower_tasks
            )

        return use_follower

    def get_bind(self, mapper=None, clause=None):
        if self.use_follower:
            return random.choice(self.followers)

        return super().get_bind(mapper=mapper, clause=clause)


class RoutingSQLAlchemy(SQLAlchemy):

    def create_session(self, options):
        return RoutingSession(self, **options)


db = RoutingSQLAlchemy()


class BaseModel(db.Model):
    __abstract__ = True
    idx = db.Column(db.Integer, primary_key=True, autoincrement=True)
