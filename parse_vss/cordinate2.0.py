import gzip
import StringIO
import cPickle as pickle
import math
import sqlite3
import glob

DIR = "/net2/presto-users/masaki070540/Desktop/stat/sugar/CN/"
_back = lambda pdbid : ("/net2/presto-users/masaki070540/Desktop/all_pdb/pdb/pdb%s.ent.gz" % (pdbid.lower()))

class point(object):
	def __init__(self,x,y,z):
		self._vec = (x,y,z)
	
	def __add__(self,other):
		x = self._vec[0] + other._vec[0]
		y = self._vec[1] + other._vec[1]
		z = self._vec[2] + other._vec[2]
		return point(x,y,z)
	
	def __sub__(self,other):
		x = self._vec[0] - other._vec[0]
		y = self._vec[1] - other._vec[1]
		z = self._vec[2] - other._vec[2]
		return point(x,y,z)
	
	def pol(self):
		x = self._vec[0]
		y = self._vec[1]
		z = self._vec[2]

		r = math.sqrt(x**2 + y**2 + z**2)
		s = math.acos(z/r)
		f = math.acos(x/math.sqrt(x**2 + y**2))
		return (r,s/math.pi,f/math.pi)

class atom(point):
	def __init__(self,x,y,z,atm,res):
		point.__init__(self,x,y,z)
		self.atm = atm
		self.res = res

	def interaction(self,point1,point2):
		if point1.atm == "C" and point2.atm == "C":
			dist = (point1 - point2).pol()
			if 2.7 <= dist[0] <= 3.3:
				return "Hydrophilic",dist

def parseCN(metal):
	with open(DIR + metal + ".nrd.sort") as fp:
		pdbid = ""
		hatm = 0
		atms = {}
		_atmrec = lambda atm :(int(atm.split(":")[0]),float(atm.split(":")[2]))
		
		for rec in (line.strip().split("\t") for line in iter(fp.readline,"")):
			if "%s.%s" % (pdbid,hatm) != "%s.%s" % (rec[0],rec[1]) and pdbid != "":
				yield pdbid.split(".")[0],[hatm],atms
				atms = {}
			atms.update({_atmrec(atm)[0]:_atmrec(atm)[1] for atm in rec[2:]})
			#atms += [atm_rec(atm) for atm in rec[2:]]
			pdbid = rec[0]
			hatm = int(rec[1])
            

def rollback(pdbid):
	with open(_back(pdbid)) as fp:
		sf = StringIO.StringIO(fp.read())
		with gzip.GzipFile(fileobj = sf) as fpdb:
			for rec in (line.strip() for line in iter(fpdb.readline,"")):
				yield rec

def fpdb(pdbid,atms,hatms = [],readliner = rollback):
	def _strip(string):
		if isinstance(string,str):
			return string.strip()
		else:
			return string
	
	_atms = lambda rec:(rec[12:16],rec[17:20],rec[22:26],rec[21])
	
	asq,hsq = {},{}
	for rec in readliner(pdbid):
		if rec[0:6] in ['ATOM  ','HETATM']:
			natm = int(rec[6:11])
			_atm_data = [_strip(i) for i in _atms(rec)]
			if natm in atms:
				asq.update({natm:_atm_data})
			if natm in hatms:
				hsq.update({natm:_atm_data})
	return asq,hsq

def isHdonar(i):
	if i[1] == "ASN" and i[0] == "ND2":
		return True
	if i[1] == "GLN" and i[0] == "NE2":
		return True
	if i[1] == "HIS":
		pass
	if i[1] == "SER" and i[0] == "OG":
		return True
	if i[1] == "TYR" and i[0] == "OH":
		return True
	if i[1] == "THR" and i[0] == "OG1":
		return True

def isHhet(i):
	if i[1] == "NAG" and i[0] in ["O1","O3","O6","N2"]:
		return True
	if i[1] == "MAN" and i[0] in ["O1","O2","O3","O4","O6"]:
		return True

def isglyc(pdbid,asq):
	with sqlite3.connect("/users/masaki070540/Desktop/glyc.db") as con:
		sql = lambda pdbid:"select seqno,ch from glyc where id = '%s';" % (pdbid)
		glyc = con.execute(sql(pdbid)).fetchall()
	new_asq = {}
	for key,value in asq.items():
		for sqno,ch in glyc:
			#print sqno,ch,value[2],value[3]
			if not (sqno == value[2] and ch == value[3]):
				new_asq.update({key:value})
			else:
				pass
				#print value[:4],"is glycosylated."
	return new_asq
			
def iter_glyc(sugar,cret):
	atmno = lambda x:x[0]
	for pdbid,hatms,atms in parseCN(sugar):
		asq,hsq = fpdb(pdbid,atms = atms.keys(),hatms = hatms,readliner = rollback)
		if hsq[hatms[0]][1] == sugar:
			for atmno in asq.keys():
				if cret(atms[atmno]):
					yield "%s\t%s\t%s\t%s\t%s\n" % (pdbid,hatms[0]," ".join(hsq[hatms[0]])," ".join(asq[atmno]),atms[atmno])


if __name__ == "__main__":
	for sugar in (i.split(".")[0] for i in glob.iglob("*.nrd.sort")):
		print sugar
		with open("%s.CN" % (sugar),"a") as fp:
			for rec in iter_glyc(sugar,cret = lambda x: x > 1.6):
				fp.write(rec)
