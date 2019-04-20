import ormin

importModel(sqlite, "sections_model")

var db {.global.} = open("sections.db", "", "", "")

block:
   # sql("select (id, name) from ipe")
   let ipes = query:
      select ipe(id, name)

   for row in ipes:
      echo(row)

block:
   # sql("select id from ipe order by weight asc limit 2")
   let ipes = query:
      select ipe(id)
      orderby asc(weight)
      limit 2

   for row in ipes:
      echo(row)

# block:
#    # sql("select * from ipe where name in ('IPE100', 'IPE120')")
#    let ipes = query:
#       select ipe(id, name)
#       where name in ('IPE100', 'IPE120')
# 
#    for row in ipes:
#       echo(row)
