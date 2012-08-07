import sqlite3

# NonRedundunt Set
sql1 = lambda metal:"""select distinct prot.idch,min(rank) from prot,cls70
         where prot.idch = cls70.idch and hetid ="%s"
		 and substr(prot.idch,0,5) in(
		 select id from resol where resol <> "NOT")
		 group by cls70.cls;""" % (metal)

# Resolution
sql2 = lambda metal:"""select distinct idch from prot
         where hetid = "%s" and substr(idch,0,5) in(
		 select id from resol where resol <> "NOT");""" % (metal)

db = "/net2/presto-users/masaki070540/Desktop/xbp.db.ver2"
stat = "/net2/presto-users/masaki070540/Desktop/stat/sugar/pdbid/"

def iter_hetsgr():
	with open("/users/masaki070540/code/xbind/dataset/ligand/linucs/hetid2sugar.mono") as fp:
		for rec in (line.strip().split() for line in iter(fp.readline,"")):
			yield rec[0]


if __name__ == "__main__":
	with sqlite3.connect(db) as con:
		for sugar in iter_hetsgr():
			print sql1(sugar)
			for rec in con.execute(sql1(sugar)):
				with open(stat + "pdbid." + sugar + ".nrd","a") as fp:
					fp.write("\t".join([str(i) for i in rec]) + "\n")
