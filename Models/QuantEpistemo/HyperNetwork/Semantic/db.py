# db script
import utils



# dirty for purpose
def read_csv(file):
    conf = open(file,'r')
    res=dict()
    conf.readline()#skip header
    currentLine = conf.readline().replace('\n','')
    while currentLine != '' :
        t=str.split(currentLine,',')
        #print(t[0])
	#print(t[1])
	schid=t[1].replace("\"","")
	if len(schid)>0 : res[t[0]]=schid
        currentLine = conf.readline().replace('\n','')
    return(res)

def readfile(file):
    f = open(file,'r')
    res=""
    currentLine = f.readline().replace('\n',' ')
    while currentLine != '' :
        res = res+currentLine
        currentLine = f.readline().replace('\n',' ')
    return(res)

def update_cyb_abstracts():
    # read csv for correspondance id,schid
    ids = read_csv('../../../Data/raw/cybergeo.csv')

    for i in ids.keys():
	print(i)
        abstract=readfile('../../../Data/raw/texts/'+i+'_abstract.txt').replace('\'','')
        data = utils.get_data('SELECT id FROM refdesc WHERE id=\''+ids[i]+'\';','mysql')
	print(data)
	if len(data)>0:
	    query = 'UPDATE refdesc SET abstract=\''+abstract+'\' WHERE id=\''+ids[i]+'\';'
        else:
	    query = 'INSERT INTO refdesc (id,abstract) VALUES (\''+ids[i]+'\',\''+abstract+'\');'
	print(query)
        utils.query_mysql(query)


update_cyb_abstracts()
