import cv2
import numpy as np
import math

lns = [x.split(" ") for x in open("output/vect.txt",'r').read().split("\n") if len(x.strip())]
lns = sorted(lns,key=lambda x:x[0])

# lns = lns[:100]

keys = [x[0] for x in lns]
N = len(keys)
nn = (N*(N-1)//2)
# nnn = int(math.ceil(nn/4)*4)
# print(nnn)
# exit()
nnn = 200750720

vs = [np.array([float(y) for y in x[1:]]) for x in lns]
# D = np.zeros((N,N),dtype=np.float32)

im = np.zeros(nnn,dtype=np.float32)
idx = 0

for i in range(N):
	print(i,'/',N)
	for j in range(i+1,N):
		d = np.linalg.norm(vs[i]-vs[j])
		im[idx]=d
		idx += 1
		# D[i,j] = d

	# if i > 100:
	# 	break
m = np.min(im)
# m = 0
im = (im-m)/(np.max(im)-m)
im = np.sqrt(im)
im *= 255
im = im.astype(np.uint8)
# print(im)
im = np.reshape(im,(7240,6932,4))
im = cv2.cvtColor(im,cv2.COLOR_RGBA2BGRA)
cv2.imwrite("output/distmat_sqrt.png",im)


