#################################################################################
## datomic->R interop

library(rJava)
.jinit() # this starts the JVM

## add java deps to classpath (requires the execution of ./deps beforehand)
lapply(list.files("./lib", full.names = TRUE), function(jpath) {
  .jaddClassPath(jpath)
})

options("scipen"=100, "digits"=4) #disable scientific notation

##
is.jobject <- function(o) {
  inherits(o, "jobjRef")
}

##
as.jtype <- function(o, type) {
  .jcast(o, new.class=type)
}

##
as.jstring <- function(o) {
  .jnew("java/lang/String", o)
}

##
as.jobject <- function(o) {
  .jcast(o, new.class="java.lang.Object")
}

##
as.jarray <- function(...) {
  .jarray(c(...))
}

##
as.jlong <- function(l) {
  .jnew("java/lang/Long", l)
}

##
to.long <- function(jobj) {
  .jcall(jobj, "J", "longValue");
}

##
as.jdate <- function(dt) {
  sdf <- .jnew("java/text/SimpleDateFormat", "EEE MMM dd HH:mm:ss yyyy")
  .jcall(sdf, "Ljava/util/Date;", "parse", dt)
}

##
as.uuid <- function(uuid.str) {
  .jcall("java/util/UUID", "Ljava/util/UUID;", "fromString", uuid.str)
}

##
as.keyword <- function(nsname) {
  .jcall("clojure/lang/Keyword", "Lclojure/lang/Keyword;", "intern", as.jstring(nsname))
}

##public static boolean isNumber(java.lang.String);
##  Signature: (Ljava/lang/String;)Z
is.java.number <- function(s) {
  .jcall("org/apache/commons/lang3/math/NumberUtils", "Z", "isNumber"
         , as.jstring(s))
}

##public static java.util.List list(java.lang.Object[]);
##  Signature: ([Ljava/lang/Object;)Ljava/util/List;
as.jlist <- function(jarr) {
  .jcall("datomic/Util", "Ljava/util/List;", "list", jarr)
}

##
as.tuple <- function(...) {
  items <- c(...)
  as.jlist(as.jarray(items))
}

##
jobject.as.list <- function(jobj) {
  lapply(jobj, function(i) { i } )
}

##
## attrvals <- function(qres, attr) {
##   lapply(qres, function(tpl) {
##     lapply(tpl, function(entid) {
##       e <- d.entity(datomic.conn, entid)
##       d.entity.get(e, as.jobject(as.jstring(attr)))
##     })
##   })
## }

##public static final java.lang.Object EAVT;
##  Signature: Ljava/lang/Object;
d.eavt <- .jfield("datomic/Database", "Ljava/lang/Object;", "EAVT")

##public static final java.lang.Object AEVT;
##  Signature: Ljava/lang/Object;
d.aevt <- .jfield("datomic/Database", "Ljava/lang/Object;", "AEVT")

##public static final java.lang.Object AVET;
##  Signature: Ljava/lang/Object;
d.avet <- .jfield("datomic/Database", "Ljava/lang/Object;", "AEVT")

##public static final java.lang.Object VAET;
##  Signature: Ljava/lang/Object;
d.vaet <- .jfield("datomic/Database", "Ljava/lang/Object;", "VAET")

##public static java.lang.Object tempid(java.lang.Object);
##  Signature: (Ljava/lang/Object;)Ljava/lang/Object;
##public static java.lang.Object tempid(java.lang.Object, long);
##  Signature: (Ljava/lang/Object;J)Ljava/lang/Object;
d.tempid <- function(partition, idNumber) {
  if(missing(idNumber)) {
    .jcall("datomic/Peer", "Ljava/lang/Object;", "tempid"
           , as.jobject(as.jstring(partition)))
  } else {
    .jcall("datomic/Peer", "Ljava/lang/Object;", "tempid"
           , as.jobject(as.jstring(partition))
           , .jlong(idNumber))
  }
}

##public static java.util.UUID squuid();
##  Signature: ()Ljava/util/UUID;
d.squuid <- function() {
  res <- .jcall("datomic/Peer", "Ljava/util/UUID;", "squuid")
  res$toString()
}

##public static long squuidTimeMillis(java.util.UUID);
##  Signature: (Ljava/util/UUID;)J
d.squuid.time.millis <- function(uuid.str) {
  res <- .jcall("datomic/Peer", "J", "squuidTimeMillis"
                , as.uuid(uuid.str))
}

##public static boolean createDatabase(java.lang.Object);
##  Signature: (Ljava/lang/Object;)Z
d.create.database <- function(uri) {
  .jcall("datomic/Peer", "Z", "createDatabase", as.jobject(as.jstring(uri)))
}

##public static boolean renameDatabase(java.lang.Object, java.lang.String);
##  Signature: (Ljava/lang/Object;Ljava/lang/String;)Z
d.rename.database <- function(uri, newName) {
  .jcall("datomic/Peer", "Z", "renameDatabase"
         , as.jobject(as.jstring(uri))
         , as.jstring(newName))
}

##public static boolean deleteDatabase(java.lang.Object);
##  Signature: (Ljava/lang/Object;)Z
d.delete.database <- function(uri) {
  .jcall("datomic/Peer", "Z", "deleteDatabase", as.jobject(as.jstring(uri)))
}

##public static datomic.Connection connect(java.lang.Object);
##  Signature: (Ljava/lang/Object;)Ldatomic/Connection;
d.connect <- function(uri) {
  .jcall("datomic/Peer", "Ldatomic/Connection;", "connect"
         , as.jobject(as.jstring(uri)))
}

#public abstract datomic.Database db();
##  Signature: ()Ldatomic/Database;
d.db <- function(conn) {
  .jcall(conn, "Ldatomic/Database;", "db")
}

## public abstract java.lang.String id();
##   Signature: ()Ljava/lang/String;
d.id <- function(dbase) {
  .jcall(dbase, "Ljava/lang/String;", "id")
}

##public abstract datomic.Database asOf(java.lang.Object);
##  Signature: (Ljava/lang/Object;)Ldatomic/Database;
d.as.of <- function(d, t) {
  my.t <- NULL;
  if(is.numeric(t)) {
    my.t <- as.jobject(as.jlong(.jlong(t)))
  } else {
    my.t <- as.jobject(as.jlong(t))
  }
  .jcall(d, "Ldatomic/Database;", "asOf", my.t)
}

##public abstract java.lang.Long asOfT();
##  Signature: ()Ljava/lang/Long;
d.as.of.t <- function(d) {
  to.long(.jcall(d, "Ljava/lang/Long;", "asOfT"))
}

##public abstract datomic.Database since(java.lang.Object);
##  Signature: (Ljava/lang/Object;)Ldatomic/Database;
d.since <- function(d, t) {
  my.t <- NULL;
  if(is.numeric(t)) {
    my.t <- as.jobject(as.jlong(.jlong(t)))
  } else {
    my.t <- as.jobject(as.jlong(t))
  }
  .jcall(d, "Ldatomic/Database;", "since", my.t)
}

##public abstract java.lang.Long sinceT();
##  Signature: ()Ljava/lang/Long;
d.since.t <- function(d) {
  to.long(.jcall(d, "Ljava/lang/Long;", "sinceT"))
}

##public abstract void gcStorage(java.util.Date);
##  Signature: (Ljava/util/Date;)V
d.gc.storage <- function(conn, dt) {
  .jcall(conn, "V", "gcStorage", as.jdate(dt))
}

##public abstract boolean requestIndex();
##  Signature: ()Z
d.request.index <- function(conn) {
  .jcall(conn, "Z", "requestIndex")
}

##public abstract datomic.ListenableFuture transact(java.util.List);
##  Signature: (Ljava/util/List;)Ldatomic/ListenableFuture;
d.transact <- function(conn, txData) {
  #.jcall(conn, "Ldatomic/ListenableFuture;", "transact", txData)
  res <- .jcall(.jcall(conn, "Ldatomic/ListenableFuture;", "transact", txData)
                , "Ljava/lang/Object;"
                , "get")
  ret <- new.env()
  ret[["db.before"]] = .jcall(res, "Ljava/lang/Object;", "get", as.jobject(as.keyword("db-before")))
  ret[["db.after"]] = .jcall(res, "Ljava/lang/Object;", "get", as.jobject(as.keyword("db-after")))
  ret[["tx.data"]] = .jcall(res, "Ljava/lang/Object;", "get", as.jobject(as.keyword("tx-data")))
  ret[["tempids"]] = .jcall(res, "Ljava/lang/Object;", "get", as.jobject(as.keyword("tempids")))
  ret
}

## TODO: improve type coersion
realize <- function(collection) {
  lapply(collection, function(rw) {
    lapply(rw, function(cl) {
      s <- cl$toString()
      if(is.java.number(s)) {
        as.numeric(s)
      } else {
        s
      }
    })
  })
}

##public static java.util.Collection q(java.lang.Object, java.lang.Object[]);
##  Signature: (Ljava/lang/Object;[Ljava/lang/Object;)Ljava/util/Collection;
d.q <- function(qry, ...) {
  srcs <- c(...)
  res <- .jcall("datomic/Peer", "Ljava/util/Collection;", "q"
                , as.jobject(as.jstring(qry))
                , as.jarray(srcs)
                , evalArray=TRUE)
  realize(res)
}

##public abstract datomic.Entity entity(java.lang.Object);
##  Signature: (Ljava/lang/Object;)Ldatomic/Entity;
d.entity <- function(dbase, id) {
  .jcall(dbase, "Ldatomic/Entity;", "entity"
         , as.jobject(.jnew("java/lang/Long", as.character(id)))) 
}

##public abstract java.lang.Object entid(java.lang.Object);
##  Signature: (Ljava/lang/Object;)Ljava/lang/Object;
##TODO: handle symbolic keyword id arg
d.entid <- function(dbase, id) {
  to.long(.jcall(dbase, "Ljava/lang/Object;", "entid"
         , as.jobject(.jnew("java/lang/Long", as.character(id)))))
}

## public abstract datomic.Database db();
##   Signature: () Ldatomic/Database;
d.entity.db <- function(ent) {
  .jcall(ent, "Ldatomic/Database;", "db")
}

##public abstract java.lang.Object get(java.lang.Object);
##  Signature: (Ljava/lang/Object;)Ljava/lang/Object;
##TODO: better coersion of java->R type
d.entity.get <- function(e, p) {
  ret <- .jcall(e, "Ljava/lang/Object;", "get", as.jobject(as.jstring(p)))
  s <- ret$toString()
  if(is.java.number(s)) {
    as.numeric(s)
  } else {
    s
  }
}

## public abstract java.util.Set keySet();
##   Signature: ()Ljava/util/Set;
d.entity.keys <- function(e) {
  ph <- NULL
  lapply(.jcall(e, "Ljava/util/Set;", "keySet")
         , function(i) { ph <- c(ph, .jcall(i, "S", "toString")) })
}

##public static java.lang.Object part(java.lang.Object);
##  Signature: (Ljava/lang/Object;)Ljava/lang/Object;
d.part <- function(entityId) {
  .jcall("datomic/Peer", "Ljava/lang/Object;", "part"
         , as.jobject(.jnew("java/lang/Long", as.character(entityId))))
}

##public static long toT(java.lang.Object);
##  Signature: (Ljava/lang/Object;)J
d.to.t <- function(tx) {
  .jcall("datomic/Peer", "J", "toT", tx)
}

##public static java.lang.Object toTx(long);
##  Signature: (J)Ljava/lang/Object;
d.to.tx <- function(tid) {
  .jcall("datomic/Peer", "Ljava/lang/Object;", "toTx", .jlong(tid))
}

##public abstract datomic.Database history();
##  Signature: ()Ldatomic/Database;
d.history <- function(d) {
  .jcall(d, "Ldatomic/Database;", "history")
}

##public abstract java.lang.Iterable datoms(java.lang.Object, java.lang.Object[]);
##  Signature: (Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Iterable;
##index - one of EAVT, AEVT, AVET, VAET
##TODO: handle case of missing varargs in jcall
d.datoms <- function(d, idx, ...) {
  components <- c(...)
  .jcall(d, "Ljava/lang/Iterable;", "datoms"
         , as.jobject(idx)
         , as.jarray(components)
         , evalArray=TRUE)
}

##public abstract datomic.Entity touch();
##  Signature: ()Ldatomic/Entity;
d.touch <- function(e) {
  .jcall(e, "Ldatomic/Entity;", "touch")
}

## public abstract long basisT();
##   Signature: ()J
d.basis.t <- function(dbase) {
  .jcall(dbase, "J", "basisT")
}

## public abstract long nextT();
##   Signature: ()J
d.next.t <- function(dbase) {
  .jcall(dbase, "J", "nextT")
}

## public abstract boolean isHistory();
##   Signature: ()Z
d.is.history <- function(dbase) {
  .jcall(dbase, "Z", "isHistory")
}

## public abstract java.lang.Object ident(java.lang.Object);
##   Signature: (Ljava/lang/Object;)Ljava/lang/Object;
d.ident <- function(dbase, id) {
  .jcall(dbase, "Ljava/lang/Object;", "ident"
         , as.jobject(.jnew("java/lang/Long", as.character(id))))
}

## public abstract java.lang.Object a();
##   Signature: ()Ljava/lang/Object;
d.datom.a <- function(datom) {
  .jcall(datom, "Ljava/lang/Object;", "a")
}

## public abstract java.lang.Object e();
##   Signature: ()Ljava/lang/Object;
d.datom.e <- function(datom) {
  .jcall(datom, "Ljava/lang/Object;", "e")
}

## public abstract java.lang.Object v();
##   Signature: ()Ljava/lang/Object;
d.datom.v <- function(datom) {
  .jcall(datom, "Ljava/lang/Object;", "v")
}

## public abstract java.lang.Object tx();
##   Signature: ()Ljava/lang/Object;
d.datom.tx <- function(datom) {
  .jcall(datom, "Ljava/lang/Object;", "tx")
}

## public abstract boolean added();
##   Signature: ()Z
d.datom.added <- function(datom) {
  .jcall(datom, "Z", "added")
}

## public abstract java.lang.Object get(int);
##   Signature: (I)Ljava/lang/Object;
d.datom.get <- function(datom, idx) {
  .jcall(datom, "Ljava/lang/Object;", "get", as.integer(idx))
}

## TODO: add-listener
## TODO: filter
## TODO: function
## TODO: index-range
## TODO: invoke
## TODO: is-filtered
## TODO: remove-tx-report-queue
## TODO: resolve-tempid
## TODO: transact-async
## TODO: tx-report-queue
## TODO: with
