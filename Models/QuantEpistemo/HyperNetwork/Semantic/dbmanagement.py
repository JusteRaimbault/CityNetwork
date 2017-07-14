# -*- coding: utf-8 -*-

# db management

import utils
import pymongo


def sqlite_to_mongo(sqlitedb,mongodb):
    client=pymongo.MongoClient('localhost',27017)
    db=client[mongodb]
    relevant = utils.get_data('SELECT * FROM relevant;',sqlitedb)
    col=db['relevant']
    for row in relevant:
        #col.replace_one({'keyword':row[0],'cumtermhood':row[1],'ids':row[2].split(';')})
        col.replace_one({'keyword':row[0]},{'keyword':row[0],'cumtermhood':row[1],'ids':[]})
    # add index for query efficiency
    col.create_index('keyword')
    #dico = utils.get_data('SELECT * FROM dico;',sqlitedb)
    #col=db['dico']
    #for row in dico:
    #    col.insert_one({'id':row[0],'keywords':row[1].split(';')})
    #col.create_index('id')


def keywords_to_mongo(sqlitedb,mongodb):
    client=pymongo.MongoClient('localhost',27017)
    db=client[mongodb]
    keywords = utils.import_kw_dico_sqlite(sqlitedb)
    dico = keywords[0]
    col=db['keywords']
    col.drop()
    for i in dico.keys():
        col.insert_one({'id':i,'keywords':dico[i]})
    # add index for query efficiency
    col.create_index('id')


#sqlite_to_mongo('bootstrap/run_kw1000_csize5000_b20/bootstrap.sqlite3','cyb_kw1000_csize5000_b20')
#sqlite_to_mongo('/mnt/volume1/juste/ComplexSystems/Cybergeo/Data/dumps/20160224_cybergeo.sqlite3','cyb_kw1000_csize5000_b20')
#keywords_to_mongo('/mnt/volume1/juste/ComplexSystems/Cybergeo/Data/dumps/20160224_cybergeo.sqlite3','cybergeo')
