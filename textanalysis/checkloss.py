import cv2
import numpy as np

im0 = cv2.imread("output/distmat_sqrt.png",cv2.IMREAD_UNCHANGED).astype(np.float32)
im1 = cv2.imread("output/distmat_sqrt_quant.png",cv2.IMREAD_UNCHANGED).astype(np.float32)

print(np.sum(im0-im1)/(im0.shape[0]*im0.shape[1]*im0.shape[2]))
