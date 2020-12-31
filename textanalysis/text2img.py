import cv2
import numpy as np
from glob import glob

txt = sorted(glob("text_cleaned/*/*/*/*.txt"))
data2 = []
data8 = []

catalog = "";

def char_to_6bits(c):
	c = ord(c)
	if c == ord(' '):
		return [1]
	if ord('A') <= c <= ord('Z'):
		return [c-ord('A')+2]
	if ord('a') <= c <= ord('z'):
		return [c-ord('a')+28]
	if ord('0') <= c <= ord('9'):
		return [c-ord('0')+54]

	if ord('!') <= c <= ord('/'):
		return [0,c-ord('!')+3]
	if ord(':') <= c <= ord('@'):
		return [0,c-ord(':')+18]
	if ord('[') <= c <= ord('`'):
		return [0,c-ord('[')+25]
	if ord('{') <= c <= ord('~'):
		return [0,c-ord('{')+31]
	if c == ord('\n') or c == ord('\r'):
		return [0,1]
	return [0,2]

for t in txt:
    if 1:#try:
        f = open(t,'r',errors='ignore').read().strip()
        for x in f:
        	d6 = char_to_6bits(x)
        	# print(d6)
        	d2 = []
        	for d in d6:
        		d2+=[(d>>4)&0b11,(d>>2)&0b11,(d)&0b11]
        	data2 += d2
        data2 += [0,0,0,0,0,0]
        # exit()
        catalog += t + "\n"
    # except:
    #     print("corrupt file",t)


while len(data2)%4 != 0:
	data2.append(0)


for i in range(0,len(data2),4):
	d8 = (data2[i]<<6) | (data2[i+1]<<4) | (data2[i+2]<<2) | (data2[i+3])
	data8.append(d8)

print(len(data8))
# print(data8[0:100])

# while len(data8) != 3069136:
# 	data8.append(0)

# im = np.array(data8,dtype=np.uint8)
# im = np.reshape(im, (938,818,4))

# print(len(data8))

# while len(data8) != 3079468:
# 	data8.append(0)

# im = np.array(data8,dtype=np.uint8)
# im = np.reshape(im, (1009,763,4))

# im = cv2.cvtColor(im, cv2.COLOR_BGRA2RGBA)

# cv2.imwrite("output/text.png",im,[cv2.IMWRITE_PNG_COMPRESSION,9])

# open("output/catalog.txt",'w').write(catalog)


while len(data8) != 3072492:
	data8.append(0)

im = np.array(data8,dtype=np.uint8)
im = np.reshape(im, (981,783,4))

im = cv2.cvtColor(im, cv2.COLOR_BGRA2RGBA)

cv2.imwrite("output/text.png",im,[cv2.IMWRITE_PNG_COMPRESSION,9])

open("output/catalog.txt",'w').write(catalog)
