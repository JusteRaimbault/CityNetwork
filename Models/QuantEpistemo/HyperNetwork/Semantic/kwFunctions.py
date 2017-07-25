# -*- coding: utf-8 -*-
import nltk,math,operator
import utils

# kw extraction functions common to kw Extraction and Bootstrap
#  -> for separation TreeTagger/other (necessites server installation)

# extract relevant keywords, using unithood and termhood
#  @returns [tselected,p_tsel_dico] : dico kw -> termhood ; dico patent -> kws
def extract_relevant_keywords(corpus,kwLimit,eth,occurence_dicos):
    print('Extracting relevant keywords...')

    #[ref_kw_dico,kw_ref_dico] = utils.extract_sub_dicos(corpus,occurence_dicos)
    ref_kw_dico = occurence_dicos[0]
    kw_ref_dico = occurence_dicos[1]

    print('Refs : '+str(len(ref_kw_dico))+" ; kws : "+str(len(kw_ref_dico)))

    # compute doc frequencies
    print('Compute frequencies...')
    docfrequencies = {}
    for k in kw_ref_dico.keys():
        docfrequencies[k] = len(kw_ref_dico[k])

    # compute unithoods
    print('Compute unithoods...')
    unithoods = dict()
    for k in kw_ref_dico.keys():
        l = len(k.split(' '))
        unithoods[k]=math.log(l+1)*len(kw_ref_dico[k])

    # sort and keep K*N keywords ; K = 4 for now ?
    selected_kws = {} # dictionary : kw -> index in matrix
    sorted_unithoods = sorted(unithoods.items(), key=operator.itemgetter(1),reverse=True)
    for i in range(min(4*kwLimit,len(kw_ref_dico))):
        selected_kws[sorted_unithoods[i][0]] = i

    # computing cooccurrences
    print('Computing cooccurrences...')
    coocs = {}
    n=len(ref_kw_dico)/100;pr=0
    for r in ref_kw_dico.keys() :
        pr = pr + 1
        if pr % n == 0 : print('cooccs : '+str(pr/n)+'%')
        sel = []
        for k in ref_kw_dico[r] :
            if k in selected_kws : sel.append(k)
        for i in range(len(sel)-1):
            #ii = selected_kws[sel[i]]
            ki = sel[i]
            if ki not in coocs : coocs[ki] = {}
            for j in range(i+1,len(sel)):
                kj= sel[j]
                if kj not in coocs : coocs[kj] = {}
                if kj not in coocs[ki] :
                    coocs[ki][kj] = 1
                else :
                    coocs[ki][kj] = coocs[ki][kj] + 1
                if ki not in coocs[kj] :
                    coocs[kj][ki] = 1
                else :
                    coocs[kj][ki] = coocs[kj][ki] + 1


    # compute termhoods
    colSums = {}
    for ki in coocs.keys():
        colSums[ki] = sum(coocs[ki].values())

    termhoods = {}
    for ki in coocs.keys():
        s = 0;
        for kj in coocs[ki].keys():
            if kj != ki : s = s + ((coocs[ki][kj]-colSums[ki]*colSums[kj])*(coocs[ki][kj]-colSums[ki]*colSums[kj]))/(colSums[ki]*colSums[kj])
        termhoods[ki]=s

    #print(termhoods)
    # sort and filter on termhoods
    #sorting_termhoods = dict()
    #for k in selected_kws.keys():
    #    sorting_termhoods[k]=termhoods[selected_kws[k]]
    [tselected,dico,freqselected] = extract_from_termhood(termhoods,ref_kw_dico,docfrequencies,kwLimit)

    # construct graph edge list (! undirected)
    edge_list = []
    for kw in tselected.keys():
        for ki in coocs[kw].keys():
            if ki in tselected :
                if coocs[kw][ki] >= eth :
                    edge_list.append({'edge' : kw+";"+ki, 'weight' : coocs[kw][ki]})

    return([tselected,dico,freqselected,edge_list])



def extract_from_termhood(termhoods,ref_kw_dico,frequencies,kwLimit):
    sorted_termhoods = sorted(termhoods.items(), key=operator.itemgetter(1),reverse=True)

    tselected = {}
    freqselected = {}
    for i in range(kwLimit):
        tselected[sorted_termhoods[i][0]] = sorted_termhoods[i][1]
        freqselected[sorted_termhoods[i][0]] = frequencies[sorted_termhoods[i][0]]

    # reconstruct the ref -> tselected dico, finally necessary to build kw nw
    ref_tsel_dico = dict()
    for ref in ref_kw_dico.keys() :
        sel = []
        for k in ref_kw_dico[ref] :
            if k in tselected and k not in sel : sel.append(k)
        ref_tsel_dico[ref] = sel

    return([tselected,ref_tsel_dico,freqselected])
