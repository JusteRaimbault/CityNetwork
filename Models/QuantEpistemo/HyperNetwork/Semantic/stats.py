# -*- coding: utf-8 -*-
import utils

# export from base for stats

def full_stats():
    export_ref_info()
    export_secondaryref_info('SELECT citing FROM links INNER JOIN cybergeo on cybergeo.id=links.cited;','stats/citing_info')
    export_secondaryref_info('SELECT cited FROM links INNER JOIN cybergeo on cybergeo.id=links.citing;','stats/cited_info')


def export_ref_info():
    data = utils.get_data('SELECT refs.id,refs.year,language FROM refdesc INNER JOIN refs ON refs.id=refdesc.id;','mysql')
    #for r in data : print(r)
    export_matrix_csv(data,'stats/ref_info',';',False)


##
#  export infos for refs whose od is obtain from a primary request (parameter)
def export_secondaryref_info(request,outfile):
    ids = utils.get_data(request,'mysql')
    res=[]
    data = utils.get_data('SELECT refdesc.id,year,language,keywords FROM refdesc INNER JOIN refs ON refs.id=refdesc.id WHERE keywords IS NOT NULL;','mysql')
    # put in dico
    data_dico = dict()
    for row in data :
	r = list(row)
        #print('r : '+r[0].encode('utf8'))
	data_dico[r[0].encode('utf8')]=[r[i] for i in range(1,len(r))]
    for i in ids :
        #print(i[0])
        if i[0].encode('utf8') in data_dico :
	    #print('i : '+i[0].encode('utf8'))
	    #print(data_dico[i[0].encode('utf8')])
	    res.append(data_dico[i[0].encode('utf8')])
    utils.export_matrix_csv(res,outfile,'\t',False)
    #utils.export_list(ids,outfile+'_id',False)


#full_stats()
