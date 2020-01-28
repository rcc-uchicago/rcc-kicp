cudaFlags = -arch=sm_30 -O3 --use_fast_math



simple: simpleKernel.cu
	nvcc -o simple $(cudaFlags) simpleKernel.cu

clean:
	rm -f simple
	rm -f *.err *.out
