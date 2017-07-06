# -*- coding: utf-8 -*-

# utils Functions

#import MySQLdb
import sqlite3,datetime
import pymongo


#def findone_mongo():




def get_fulltext_cyb_corpus():
    cybids = read_csv_as_dico('../../../Data/raw/cybergeo.csv',",",2,1)
    schids = get_data("SELECT id FROM cybergeo",'mysql')
    res = []
    for ref in schids:
        res.append([ref[0],read_file('../../../Data/raw/texts/'+str(cybids[ref[0]])+"_text.txt")])
    return(res)



def read_file(f):
    data = open(f,'r')
    res=""
    currentLine = data.readline().replace('\n','')
    while currentLine != '' :
        res=res+" "+currentLine
        currentLine = conf.readline().replace('\n','')
    return(res)

def corpus_from_csv(f,delimiter):
    data = open(f,'r')
    res=[]
    currentLine = data.readline().replace('\n','')
    i=0
    while currentLine != '' :
        t=str.split(currentLine,delimiter)
        title=t[0].replace("\"","")
        ident=t[1].replace("\"","")
        year=t[2].replace("\"","")
        abstract='';authors=''
        if len(t)==5:
            abstract=t[3].replace("\"","");authors=t[4].replace("\"","")
        res.append({'title':title,'id':ident,'year':year,'abstract':abstract,'authors':authors})
        currentLine = data.readline().replace('\n','')
        print(t[1])
        i=i+1
    return(res)


def read_csv_as_dico(f,delimiter,key_column,value_column):
    data = open(f,'r')
    res=dict()
    currentLine = data.readline().replace('\n','')
    while currentLine != '' :
        t=str.split(currentLine,delimiter)
        res[t[key_column].replace("\"","")]=t[value_column].replace("\"","")
        currentLine = conf.readline().replace('\n','')
    return(res)


# read a conf file under the format key:value
# , returns a dictionary
def read_conf(file):
    conf = open(file,'r')
    res=dict()
    currentLine = conf.readline().replace('\n','')
    while currentLine != '' :
        t=str.split(currentLine,':')
        if len(t) != 2 : raise Exception('error in conf file')
        res[t[0]]=t[1]
        currentLine = conf.readline().replace('\n','')
    return(res)




# return the mysql connection
def configure_sql():
    # conf mysql
    conf=read_conf('conf/mysql.conf')
    user = conf['user']
    password = conf['password']
    conn = MySQLdb.connect("localhost",user,password,"cybergeo",charset="utf8")
    return(conn)

# returns sqlite connection
def configure_sqlite(database):
    return(sqlite3.connect(database,600))



def get_ids(database,collection):
    d = get_data_mongo(database,collection,{'id':{'$gt':'0'}},{'id':1})
    ids = []
    for row in d :
        ids.append(row['id'])
    print('Raw data : '+str(len(ids)))
    return(ids)

def get_data_mongo(database,collection,query,filt):
    mongo = pymongo.MongoClient('localhost', 27017)
    database = mongo[database]
    col = database[collection]
    data = col.find(query,filt)
    return(data)


def get_data(query,source):
    if source=='mysql' :
        conn = configure_sql()
    else :
        conn = configure_sqlite(source)
        conn.text_factory = str
    cursor = conn.cursor()
    cursor.execute(query)
    data=cursor.fetchall()
    return(data)


def fetchone_sqlite(query,database):
    conn = configure_sqlite(database)
    cursor = conn.cursor()
    cursor.execute(query)
    res = cursor.fetchone()
    conn.commit()
    conn.close()
    return(res)


def insert_sqlite(query,database):
    conn = configure_sqlite(database)
    cursor = conn.cursor()
    cursor.execute(query)
    conn.commit()
    conn.close()

def query_mysql(query):
    conn = configure_sql()
    cursor = conn.cursor()
    cursor.execute(query)
    conn.commit()
    conn.close()


##
# query formatted with ?
#    'INSERT INTO table VALUES (?,?,?,?,?)'
def insertmany_sqlite(query,values,database):
    conn = configure_sqlite(database)
    cursor = conn.cursor()
    cursor.executemany(query)
    conn.commit()
    conn.close()


#def implode(l,delimiter):
#    res=''
#    i=0
#    for k in l:
#        res = res+str(k)
#        if i<len(l)-1:res=res+delimiter
#    return(res)


def import_kw_dico(database,collection):
    mongo = pymongo.MongoClient('localhost', 27017)
    database = mongo[database]
    col = database[collection]
    data = col.find()
    ref_kw_dico={}
    kw_ref_dico={}
    for row in data:
        keywords = row['keywords'];ref_id=row['id']
        ref_kw_dico[ref_id] = keywords
        for kw in keywords :
            if kw not in kw_ref_dico : kw_ref_dico[kw] = []
            kw_ref_dico[kw].append(kw)
    print('dicos : '+str(len(ref_kw_dico))+' ; '+str(len(kw_ref_dico)))
    return([ref_kw_dico,kw_ref_dico])


##
# usage : [ref_kw_dico,kw_ref_dico] = import_kw_dico()
def import_kw_dico_req(request,source):
    # import extracted keywords from database
    data = get_data(request,source)

    ref_kw_dico = dict() # dictionnary refid -> keywords as list
    kw_ref_dico = dict() # dictionnary keywords -> refs as list

    for row in data :
        #ref_id = row[0].encode('utf8','ignore')
        ref_id=row[0]
        #print(ref_id)
        #keywords_raw = row[1].encode('utf8','ignore').split(';')
        keywords_raw = row[1].split(';')
        keywords = [keywords_raw[i] for i in range(len(keywords_raw)-1)]
        # pb with last delimiter in
        ref_kw_dico[ref_id] = keywords
        for kw in keywords :
            if kw not in kw_ref_dico : kw_ref_dico[kw] = []
            kw_ref_dico[kw].append(kw)

    return([ref_kw_dico,kw_ref_dico])

def import_kw_dico_sqlite(source):
    return(import_kw_dico_req('SELECT id,abstract_keywords FROM refdesc WHERE abstract_keywords IS NOT NULL;',source))

##
# corpus as (id,...)
def extract_sub_dicos(corpus,occurence_dicos) :
    ref_kw_dico_all = occurence_dicos[0]
    kw_ref_dico_all = occurence_dicos[1]

    ref_kw_dico = dict()
    kw_ref_dico = dict()

    for ref in corpus :
        ref_id = ref[0].encode('ascii','ignore')
        keywords = []
        if ref_id in ref_kw_dico_all :
            keywords = ref_kw_dico_all[ref_id]
            ref_kw_dico[ref_id] = keywords
            for k in keywords :
                if k not in kw_ref_dico : kw_ref_dico[k] = []
                kw_ref_dico[k].append(ref_id)

    return([ref_kw_dico,kw_ref_dico])


def mysql2sqlite(sqlitedatabase):
    data = get_data('SELECT * FROM refdesc WHERE abstract_keywords IS NOT NULL','mysql')
    conn = configure_sqlite(sqlitedatabase)
    cursor = conn.cursor()
    cursor.executemany('INSERT INTO refdesc VALUES (?,?,?,?,?,?)', data)
    conn.commit()
    conn.close()



def export_dico_csv(dico,fileprefix,withDate):
    datestr = ''
    if withDate : datestr = str(datetime.datetime.now())
    outfile=open(fileprefix+datestr+'.csv','w')
    for k in dico.keys():
        outfile.write(k+";")
        for kw in dico[k]:
            outfile.write(kw+";")
        outfile.write('\n')


def export_dico_num_csv(dico,fileprefix,withDate):
    datestr = ''
    if withDate : datestr = str(datetime.datetime.now())
    outfile=open(fileprefix+datestr+'.csv','w')
    for k in dico.keys():
        outfile.write(k+";")
        outfile.write(str(dico[k]))
        outfile.write('\n')


def export_list(l,fileprefix,withDate):
    datestr = ''
    if withDate : datestr = str(datetime.datetime.now())
    outfile=open(fileprefix+datestr+'.csv','w')
    for k in l :
        outfile.write(k)
    outfile.write('\n')



def export_matrix_csv(m,fileprefix,delimiter,withDate):
    datestr = ''
    if withDate : datestr = str(datetime.datetime.now())
    outfile=open(fileprefix+datestr+'.csv','w')
    for r in m :
        #print(len(r))
	#print(r)
        for c in range(len(r)) :
            print(str(r[c]))
        t=''
	    #print(r[c][0])
        if isinstance(r[c],unicode) :
            t=unicode(r[c]).encode('utf8','ignore')
        else :
            t = str(r[c])
        outfile.write(t)
        if c < len(r)-1 :
            outfile.write(delimiter)
    outfile.write('\n')
