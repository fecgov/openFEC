import random
import celery
from flask_sqlalchemy import SQLAlchemy as SQLAlchemyBase
from flask_sqlalchemy import session
from flask import current_app


class RoutingSession(session.Session):
    """Route requests to database leader or follower as appropriate.

    Based on http://techspot.zzzeek.org/2012/01/11/django-style-database-routers-in-sqlalchemy/
    """

    @property
    def followers(self):
        return current_app.config.get('SQLALCHEMY_FOLLOWERS', [])

    @property
    def follower_tasks(self):
        return current_app.config.get('SQLALCHEMY_FOLLOWER_TASKS', [])

    @property
    def restrict_follower_traffic_to_tasks(self):
        return current_app.config.get('SQLALCHEMY_RESTRICT_FOLLOWER_TRAFFIC_TO_TASKS', [])

    @property
    def use_follower(self):
        # Check for read operations and configured followers.
        use_follower = (
            not self._flushing
            and len(self.followers) > 0
        )

        # Optionally restrict traffic to followers for only supported tasks.
        if use_follower and self.restrict_follower_traffic_to_tasks:
            use_follower = (
                celery.current_task
                and celery.current_task.name in self.follower_tasks
            )

        return use_follower

    def get_bind(self, mapper=None, clause=None):
        if self.use_follower:
            return random.choice(self.followers)

        return super().get_bind(mapper=mapper, clause=clause)


db = SQLAlchemyBase(session_options={'class_': RoutingSession})


class BaseModel(db.Model):
    __abstract__ = True
    idx = db.Column(db.Integer, primary_key=True, autoincrement=True)
