import os

database_server = os.environ.get('PGHOST', "localhost")
database_name = os.environ.get('PGDATABASE', "postgres")
database_user = os.environ.get('PGUSER', "postgres")
database_pw = os.environ.get('PGPASSWORD', "mysecretpassword")
database_port = os.environ.get('PGPORT', "5432")

conn_string = "host=%s dbname=%s user=%s password=%s port=%s" %(database_server, database_name, database_user, database_pw, database_port)
