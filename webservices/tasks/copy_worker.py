#!/usr/bin/env python3
import sys
import json
import psycopg2
from postgres_copy import format_flags


def main():
    config = json.loads(sys.stdin.read())

    # connect without psycogreen?
    conn = psycopg2.connect(
        host=config['host'],
        port=config['port'],
        database=config['database'],
        user=config['user'],
        password=config['password']
    )
    try:
        with conn.cursor() as cursor:
            formatted_flags = f"({format_flags(config['flags'])})" if config['flags'] else ""
            copy_sql = f"COPY ({config['query']}) TO STDOUT {formatted_flags}"
            cursor.copy_expert(copy_sql, sys.stdout.buffer)
    finally:
        conn.close()


if __name__ == '__main__':
    main()
