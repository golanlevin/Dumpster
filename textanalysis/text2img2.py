import cv2
import numpy as np
import re
from glob import glob

txt = sorted(glob("text_cleaned/*/*/*/*.txt"))
data8 = []

wordlist = "";

def get_words(f):
  f = f.replace("&amp;"," & ")\
       .replace("&gt;"," > ")\
       .replace("&lt;"," < ")\
       .replace("\n"," \n ")

  f = re.sub(r' .*?-?font-.+?',"",f);
  f = re.sub(r'(____*)',' --- ',f);
  f = re.sub(r'(----*)',' --- ',f);
  f = re.sub(r'(\.\.\.\.*)',' ... ',f);
  f = re.sub(r'(\*\*\**)',' *** ',f);
  f = re.sub(r'(\!\!\!*)',' !!! ',f);
  f = re.sub(r'([0-9]+)',r' \1 ',f);
  f = re.sub(r'([^A-Za-z0-9 ]+)',r' \1 ',f);
  
  f = re.sub(r' +'," ",f)
  return [x for x in f.split(" ") if len(x)]

words = {}
corp = []

for t in txt:
    if 1:#try:
        f = open(t,'r',errors='ignore').read().strip()
        ws = get_words(f)
        corp.append(ws)
        for w in ws:
          if w not in words:
            words[w] = 0
          words[w]+=1

# tot = sum([words[x] for x in words])
# words = {x:words[x] for x in words if words[x]>1}
words = sorted([(x,words[x]) for x in words], key=lambda x:-x[1])
# words = words[:32895]


# print(words,len(words))
# ntot = sum([x[1] for x in words])
# print(ntot,'/',tot, '=', ntot/tot)
# skip = tot - ntot
# exit()

idx0 = 128
idx1 = 128+16384

words = [("<EOF>",0)]+words[0:idx1-1]


wordset = [x[0] for x in words]
wordidx = {}
for i in range(len(words)):
  wordidx[words[i][0]]=i
  if words[i][0] == '\n':
    wordlist += "<NL>\n"
  else:
    wordlist+=words[i][0]+"\n"

# print(wordset)
# exit()
for i in range(len(corp)):
  ws = corp[i]
  for j in range(len(ws)):
    w = ws[j]
    if w in wordidx:
      idx = wordidx[w]
      if idx < idx0:
        data8.append(idx|0b10000000)
        # print('a',data8)
      else:
        ii = idx - idx0
        b0 = (ii >> 7) & 0b01111111
        b1 = ii & 0b01111111
        b1 = b1 | 0b10000000
        data8.append(b0)
        data8.append(b1)
        # print('b',data8)
    else:
      while (len(w)<3):
        w += " "
      for k in range(len(w)):
        data8.append( ord(w[k]) & 0b01111111 )
      data8.append(0);
    # print(w,data8)
  data8.append(0b10000000)
  # break;
# exit()
print(len(data8))
# print(data8)
# print(data8[0:100])
# exit()

while len(data8) != 1486208:
	data8.append(0)

im = np.array(data8,dtype=np.uint8)
im = np.reshape(im, (683,544,4))

im = cv2.cvtColor(im, cv2.COLOR_BGRA2RGBA)

cv2.imwrite("output/text2.png",im,[cv2.IMWRITE_PNG_COMPRESSION,9])

open("output/text2_words.txt",'w').write(wordlist)


# while len(data8) != 1454640:
#   data8.append(0)

# im = np.array(data8,dtype=np.uint8)
# im = np.reshape(im, (627,580,4))

# im = cv2.cvtColor(im, cv2.COLOR_BGRA2RGBA)


# cv2.imwrite("output/text2.png",im,[cv2.IMWRITE_PNG_COMPRESSION,9])

# open("output/text2_words.txt",'w').write(wordlist)