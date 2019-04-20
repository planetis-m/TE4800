import ormin

importModel(DbBackend.sqlite, "dome_model")

var db {.global.} = open("dome.db", "", "", "")


