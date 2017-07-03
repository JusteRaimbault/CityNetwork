import bibtexparser,os,sys,re,functools

bibfile = os.environ['CN_HOME']+'/Biblio/Bibtex/CityNetwork.bib'
texdir = os.environ['CN_HOME']+'/Docs/Memoire/SecondYear/Content'



# read the bibtex file
with open(bibfile) as bibtex_file:
    bibtex_str = bibtex_file.read()

bib_database = bibtexparser.loads(bibtex_str)

# load text files
text = ''

for filename in os.listdir(texdir):
    if re.search('.tex',filename):
        text = text+functools.reduce(lambda s1,s2:s1+s2,list(map(lambda s:s.replace('\n',' '),open(texdir+'/'+filename).readlines())))


for entry in bib_database.entries :
    if not re.search(entry['ID'],text):
        print(entry['ID'])
