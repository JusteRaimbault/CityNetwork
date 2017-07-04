# -*- coding: utf-8 -*-

# specific utils for bootstrap

##
# mongo version : database is the mongodb object
def update_kw_tm(kw,incr,frequency,tidf,database,table):
    prev = database[table].find_one({'keyword':kw})
    if prev is not None:
        prev['cumtermhood']=prev['cumtermhood']+incr
        prev['frequency'] = frequency;prev['tidf']=tidf
        database[table].replace_one({'keyword':kw},prev)
    else :
        database[table].insert_one({'keyword':kw,'cumtermhood':incr,'docfrequency':frequency,'tidf':tidf})



def update_kw_dico(i,kwlist,database):
    # update id -> kws dico
    #prev = utils.fetchone_sqlite('SELECT keywords FROM dico WHERE id=\''+i+'\';',database)
    #kws = set()
    prev = database.dico.find_one({'id':i})
    #if prev is not None: kws = set(prev[0].split(";"))
    #for kw in kwlist :
    #    kws.add(kw)
    #if prev is not None:
    #    utils.insert_sqlite('UPDATE dico SET id=\''+i+'\',keywords=\''+utils.implode(kws,";")+'\' WHERE id=\''+i+'\';',database)
    #else :
    #    utils.insert_sqlite('INSERT INTO dico VALUES (\''+i+'\',\''+utils.implode(kws,";")+'\')',database)
    if prev is not None:
        kwset=set(prev['keywords'])
        for kw in kwlist :
            kwset.add(kw)
        prev['keywords']=list(kwset)
        database.dico.replace_one({'id':i},prev)
    else :
        database.dico.insert_one({'id':i,'keywords':kwlist})

    # update kw -> id
    for kw in kwlist :
        #prev = utils.fetchone_sqlite('SELECT * FROM relevant WHERE keyword=\''+kw+'\';',database)
        #ids = set()
        prev = database.relevant.find_one({'keyword':kw})
        if prev is not None :
            #ids = set(prev[2].split(";"))
            ids=set(prev['ids'])
            ids.add(i)
            prev['ids']=list(ids)
            #utils.insert_sqlite('UPDATE relevant SET keyword=\''+kw+'\',cumtermhood='+str(prev[1])+',ids=\''+utils.implode(ids,";")+'\' WHERE keyword=\''+kw+'\';',database)
            database.relevant.replace_one({'keyword':kw},prev)
        else :# this case must never happen
            #utils.insert_sqlite('INSERT INTO relevant VALUES (\''+kw+'\',0,\''+i+'\');',database)
            database.relevant.insert_one({'keyword':kw,'cumtermhood':0,'ids':[i]})


def update_count(bootstrapSize,database):
    #prev = utils.fetchone_sqlite('SELECT value FROM params WHERE key=\'count\'',database)
    prev=database.params.find_one({'key':'count'})
    if prev is not None:
        #t=prev[0]+bootstrapSize
	    #utils.insert_sqlite('UPDATE params SET value='+str(t)+' WHERE key=\'count\';',database)
        prev['value']=prev['value']+bootstrapSize
        database.params.replace_one({'key':'count'},prev)
    else :
	    #utils.insert_sqlite('INSERT INTO params VALUES (\'count\','+str(bootstrapSize)+')',database)
        database.params.insert_one({'key':'count','value':bootstrapSize})
