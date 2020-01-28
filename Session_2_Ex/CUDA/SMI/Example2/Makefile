cudaFlags = -arch=sm_30 -O2



addVecGPU: addVec.cu
	nvcc -o addVecGPU $(cudaFlags) addVec.cu

clean:
	rm -f addVecGPU

