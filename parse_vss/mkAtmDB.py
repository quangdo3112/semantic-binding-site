#coding:utf-8
import sqlite3
import re
import glob
from math import sqrt

def iterData(fpdb):
    pdbid = fpdb.split('/')[-1].strip('.vss')
    with open(fpdb) as fp:
        for rec in (line.strip().strip('$').split('$') for line in iter(fp.readline,"")
                       if line[0] == '$'):
            rec = [i.strip() for i in rec]
            if rec[0] == 'Molecule Name':
                pdbid = rec[1]
                continue
            if rec[0] == 'Het Name':
                continue
            #posid = ('%s%s.%s.%s' % (pdbid,rec[4],rec[3],rec[7])).lower()
            #atmid = '%s.%s.%s' % (posid,rec[0],rec[5])
            yield (int(rec[0]),rec[1],int(rec[5]),rec[6],(pdbid + rec[4]).lower())

def iterDist(fpdb):
    def _parse(fp):
        start = re.compile('^\$')
        end = re.compile('\$$')
        record = ""
        for rec in (line.strip() for line in iter(fp.readline,'')):
            if len(rec) < 1:
                continue
            if rec[0] == '@':
                continue
            if rec[:6] == 'Header':
                continue
            _s = re.match(start,rec)
            _e = re.search(end,rec)
            if  _s is not None and  _e is not None:
                yield rec
                record = ""
            elif _s is not None:
                record += rec
            elif _e is not None:
                record += rec
                yield record
                record = ""
    
    pdbid = fpdb.split('/')[-1].strip('.vss')
    with open(fpdb) as fp:
        for rec in (line.strip().strip('$').split('$') for line in _parse(fp)):
            rec = [i.strip() for i in rec]
            if rec[0] == 'Molecule Name':
                pdbid = rec[1]
                continue
            if rec[0] == 'Het Name':
                continue
            if len(rec) != 16:
                print "Length Error",rec[0]
                print len(rec)
                continue
            yield (pdbid,int(rec[0]),rec[1],rec[4].lower(),
                   int(rec[5]),rec[6],rec[7].lower(),sqrt(float(rec[-1])))

def initdb(con):
    sql1 = """
    create table atms (
       id text,
       atm interger,
       name text,
       ch text,
       hatm interger,
       hname text,
       hch text,
       dist real
       );"""
    con.execute(sql1)
    
def updtdb(con,table,rec):
    sql = "insert into %s values (" % (table)  + ",".join(["?" for i in range(len(rec))]) + ");"
    con.execute(sql,rec)

def updtDist(con,table,atmid,dist):
    sql = "update %(tbl)s set dist = '%(dst)s' where atmid = '%(id)s'" % {
        "tbl":table,"id":atmid,"dst":dist}
    con.execute(sql)

def mkdb(archive,dbname):
    with sqlite3.connect(dbname) as con:
        initdb(con)
        for fname in glob.iglob(archive + "*.vss"):
            print fname
            if fname.split('/')[-1].strip('.vss') in ['Volume','Shape']:
                continue
            for rec in iterDist(fname):
                

                updtdb(con,"atms",rec)
        con.commit()

if __name__ == '__main__':
    import argparse

    parser = argparse.ArgumentParser(description = "Make partioned dabases.")
    parser.add_argument('-o',action='store',dest ="dbname")
    parser.add_argument('-i',action='store',dest ="archive")
    dbname = parser.parse_args().dbname
    archive = parser.parse_args().archive

    mkdb(archive,dbname)
