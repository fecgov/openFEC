from sqlalchemy import event
from sqlalchemy.engine import Engine
import time
import logging
import io
import contextlib
import yappi

logging.basicConfig()
logger = logging.getLogger("sql_profiling")
logger.setLevel(logging.DEBUG)


@event.listens_for(Engine, "before_cursor_execute")
def before_cursor_execute(conn, cursor, statement, parameters, context, executemany):
    conn.info.setdefault("query_start_time", []).append(time.time())
    logger.debug("Start Query: %s", statement)


@event.listens_for(Engine, "after_cursor_execute")
def after_cursor_execute(conn, cursor, statement, parameters, context, executemany):
    total = time.time() - conn.info["query_start_time"].pop(-1)
    logger.debug("Query Complete!")
    logger.debug("Total Time: %f", total)


@contextlib.contextmanager
def profiled(sort_by="ttot"):  # total time
    yappi.set_clock_type("wall")  # includes time spent waiting
    yappi.set_context_backend("greenlet")
    yappi.clear_stats()
    yappi.start()
    try:
        yield
    finally:
        yappi.stop()
        s = io.StringIO()

        yappi.get_func_stats().sort(sort_by).print_all(out=s)

        s.write("\n--- Greenlet Stats ---\n")
        yappi.get_greenlet_stats().print_all(out=s)

        logger.debug(s.getvalue())
