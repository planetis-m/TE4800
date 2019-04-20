import db_sqlite, strutils

let db = open(connection="dome.db", user="tony", password="",
              database="dome")
let model = readFile("dome_model.sql")
for m in model.split(';'):
   if m.strip != "":
      db.exec(sql(m), [])

db.close()
