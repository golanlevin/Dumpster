from glob import glob
import re
import numpy as np

txt = glob("text_cleaned/*/*/*/*.txt")


def getwords(f):
    f = f.split("\n")[1]
    f = [x.lower() for x in 
        f.replace("!"," ")
         .replace(","," ")
         .replace("."," ")
         .replace("\n"," ")
         .replace("?"," ")
         .replace("="," ")
         .replace(":"," ")
         .replace("*"," ")
         .replace("&amp;"," ")
         .replace("&amp;"," ")
         .replace("lt;"," ")
         .replace("gt;"," ")
         .replace("("," ")
         .replace(")"," ")
         .split(" ") if len(x)]
    f = [re.sub(' ','-',re.sub(r'[^A-Za-z]',' ',x).strip()) for x in f]
    f = [x for x in f if len(x)]
    return f;

def proc1():
    words = {}
    for t in txt:
        try:
            f = getwords(open(t,'r').read())
            for x in f:
                # if "font" in x:
                #     print(t,open(t,'r').read(),f)
                if x not in words:
                    words[x] = 0;
                words[x]+=1
        except:
            pass

    tot = sum([words[x] for x in words])

    words = {x:words[x] for x in words if words[x]>3}
    words = sorted([(x,words[x]) for x in words], key=lambda x:-x[1])
    words = words[:4999]


    print(words,len(words))

    ntot = sum([x[1] for x in words])
    print(ntot,'/',tot)
    skip = tot - ntot

    wordset = [x[0] for x in words]

    corp = []
    for t in txt:
        try:
            f = getwords(open(t,'r').read())
            for x in f:
                if x in wordset:
                    corp.append(x)
                else:
                    corp.append("___")
        except:
            pass

    corp = " ".join(corp)
    open('output/corp.txt','w').write(corp)
    open('output/word.txt','w').write("\n".join([x[0]+"\t"+str(x[1]) for x in words])+"\n___\t"+str(skip))
    # print(corp)


def proc2():
    vecs = [x for x in open("output/vectors.txt",'r').read().split("\n")[2:] if len(x)]
    V = {}
    for v in vecs:
        vs = [x for x in v.split(" ") if len(x)]
        V[vs[0]] = np.array([float(x) for x in vs[1:]])

    o = ""
    for t in txt:
        tv = np.array([0.0 for i in range(128)])
        try:
            f = getwords(open(t,'r').read())
        except:
            continue
        for x in f:
            if x in V:
                tv += V[x]
            else:
                tv += V['___']
        if len(f):
            tv /= len(f)
        o += t+" "+(" ".join([str(x) for x in list(tv)]))+"\n"

    open('output/vect.txt','w').write(o)



proc2()