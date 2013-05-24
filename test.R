
if(!exists("tempid", mode="function")) source("datomic.R")

datomic.test.uri <- "datomic:mem://test"

## d.tempid
ret <- d.tempid("foo")
if(!is.jobject(ret)) {
  print("failed to create tempid")
}

ret <- d.tempid("foo", 1)
if(!is.jobject(ret)) {
  print("failed to create tempid with num")
}

## d.squuid
ret <- d.squuid()
if(!is.character(ret)) {
  print("failed to call d.squuid")
}

## d.squuid.time.millis
ret <- d.squuid.time.millis(d.squuid())
if(!is.numeric(ret)) {
  print("failed to call d.squuid.time.millis")
}

## d.create.database
ret <- d.create.database(datomic.test.uri)  #used for the rest of the script
dbname <- runif(1, min=1, max=999999999)
db.uri <- paste(datomic.test.uri, ".", db.name, sep="")
ret <- d.create.database(db.uri)
if(ret!=TRUE) {
  print("could not create database");
}

## d.rename.database
dbname.new <- runif(1, min=1, max=999999999)
ret <- d.rename.database(db.uri, dbname.new)
if(ret!=TRUE) {
  print("could not rename database");
}

## d.delete.database
db.uri <- paste(datomic.test.uri, ".", dbname.new, sep="")
ret <- d.rename.database(db.uri, dbname.new)
if(ret!=TRUE) {
  print("could not delete database");
}

## d.connect
ret <- d.connect(datomic.test.uri)
if(!is.jobject(ret)) {
  print("failed to call d.connect")
}

## d.db
ret <- d.db(d.connect(datomic.test.uri))
if(!is.jobject(ret)) {
  print("failed to call d.db")
}

## d.id
ret <- d.id(d.db(d.connect(datomic.test.uri)))
if(ret!=datomic.test.uri) {
  print("failed to call d.id")
}

## d.as.of
ret <- d.as.of(d.db(d.connect(datomic.test.uri)), 1)
if(!is.jobject(ret)) {
  print("could not run d.as.of")
}

## d.as.of.t
ret <- d.as.of.t(d.as.of(d.db(d.connect(datomic.test.uri)), 1))
if(ret!=1) {
  print("could not run d.as.of.t")
}

## d.since
ret <- d.since(d.db(d.connect(datomic.test.uri)), 1)
if(!is.jobject(ret)) {
  print("could not run d.since")
}

## d.since.t
ret <- d.since.t(d.since(d.db(d.connect(datomic.test.uri)), 1))
if(ret!=1) {
  print("could not run d.since.t")
}

## d.gc.storage (returns void)
d.gc.storage(d.connect(datomic.test.uri), date())

## d.request.index
ret <- d.request.index(d.connect(datomic.test.uri))
if(ret!=TRUE) {
  print("failed to call d.request.index")
}

## d.transact
datom.test <- as.tuple(as.jstring("db/add")
                       , d.tempid("db.part/user")
                       , as.jstring("db/doc")
                       , as.jstring("R test tx"))
ret <- d.transact(d.connect(datomic.test.uri), as.tuple(datom.test))
## ?? "Java-Object{datomic.promise$settable_future$reify__3675@455e0638}"

## d.q
query.test <- "
[:find ?e
 :where
 [?e :db/doc \"R test tx\"]]"
ret <- d.q(query.test, d.db(d.connect(datomic.test.uri)))
if(!is.numeric(ret[[1]][[1]])) {
  print("failed to call d.q")
}

## d.entity
ret <- d.entity(d.db(d.connect(datomic.test.uri)), 1)
if(!is.jobject(ret)) {
  print("could not run d.entity")
}

## d.entity.db
ret <- d.entity.db(d.entity(d.db(d.connect(datomic.test.uri)), 1))
if(!is.jobject(ret)) {
  print("could not run d.entity.db")
}

## d.entid
ret <- d.entid(d.db(d.connect(datomic.test.uri)), 1)
if(ret!=1) {
  print("could not run d.entid")
}

## d.entity.keys
ret <- d.entity.keys(d.entity(d.db(d.connect(datomic.test.uri)), 1))
if(!is.list(ret)) {
  print("failed to call d.entity.keys")
}

## d.entity.get
ret <- d.entity.get(d.entity(d.db(d.connect(datomic.test.uri)), 1), ":db/doc")
if(!is.character(ret)) {
  print("failed to call d.entity.get")
}

## d.par
ret <- d.part(d.entid(d.db(d.connect(datomic.test.uri)), 1))

## d.to.t
ret <- d.to.t(NULL) # ??

## d.to.tx
ret <- d.to.tx(NULL) # ??

## d.history
## d.datoms
## d.touch
## d.basis.t
## d.next.t
## d.is.history
## d.ident
