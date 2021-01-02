# you need to create db_settings.py file with following content:
# sql_server = "your sql server name"
# sql_database = "database name where bot create tables"
# sql_schema = "schema name to group bot tables"
# sql_user = "user name"
# sql_password = "password"

from typing import Optional

from pyodbc import Connection, connect, Cursor, Row
import db_settings
from model import User

connection: Connection
connection = None


def _get_connection_string() -> str:
    return f"driver={{SQL Server}};" \
           f"server={db_settings.sql_server};" \
           f"database={db_settings.sql_database};" \
           f"uid={db_settings.sql_user};" \
           f"pwd={db_settings.sql_password}"


def _connect():
    global connection
    connection = connect(_get_connection_string())
    with open("create_schema.sql", mode='rt', encoding='utf-8') as schema:
        schema_txt = schema.read()
        schema_txt = schema_txt.replace("#SCHEMA#", db_settings.sql_schema)
        # check db schema
        connection.execute(schema_txt)
        connection.commit()


def get_connection() -> Connection:
    global connection
    if connection is None:
        _connect()
    return connection


def log(txt):
    _cn: Connection
    _cn = get_connection()
    _cn.execute("insert into [" + db_settings.sql_schema + "].t_log(txt) values(?)", [txt])
    _cn.commit()


def get_user(chat_id) -> Optional[User]:
    cn: Connection = get_connection()
    cur: Cursor

    with cn.cursor(f"select * from [{db_settings.sql_schema}].t_users "
                   f" where chat_id = ?", [chat_id]) as cur:
        row: Row
        row = cur.fetchone()
        if row is not None:
            return User(row.username, row.chat_id)

    return None
