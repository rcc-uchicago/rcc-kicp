#include <stdio.h>
#include <sys/time.h>

__global__
void add(int n, float *x, float *y, float *z)
{
  int i = blockIdx.x*blockDim.x + threadIdx.x;
  if (i < n){
    z[i] = x[i] + y[i];
  }
}

double cpuSecond(){
  struct timeval tp;
  gettimeofday(&tp, NULL);
  double timeRet=(double)tp.tv_sec + (double)tp.tv_usec*1e-6;
  return timeRet;


}


int main(int argc, char **argv)
{
  int N = 1 << 24;
  
  float*x = (float*)malloc(N*sizeof(float));
  float*y = (float*)malloc(N*sizeof(float));
  float*z = (float*)malloc(N*sizeof(float));
  float *zcpu = (float*)malloc(N*sizeof(float));
  for (int i = 0; i < N; i++) {
    x[i] = i;
    y[i] = 42-i;
  }

#if 0
  double cpuStart=cpuSecond();
  for (int i = 0; i < N; i++) {
    zcpu[i] = x[i] + y[i];
  }
 double cpuEnd=cpuSecond();
 double cpuElapse = cpuEnd - cpuStart;
 printf("Time take on CPU %f s\n", cpuElapse);
#endif

  // note the reference of a *pointer*!
  float *x_c, *y_c, *z_c;
  cudaMalloc(&x_c, N*sizeof(float)); 
  cudaMalloc(&y_c, N*sizeof(float));
  cudaMalloc(&z_c, N*sizeof(float));

  // copy host memory over to GPU 
  cudaMemcpy(x_c, x, N*sizeof(float), cudaMemcpyHostToDevice);
  cudaMemcpy(y_c, y, N*sizeof(float), cudaMemcpyHostToDevice);

  // add vectors together
  int Nthreads = atoi(argv[1]);
  dim3 threadsPerBlock(Nthreads,1,1);
  dim3 blocks((N+Nthreads-1)/Nthreads,1,1);
  double iStart=cpuSecond();
  add <<< blocks, threadsPerBlock >>> (N, x_c, y_c, z_c);
  // copy result z_c back to CPU (in z)
  cudaMemcpy(z, z_c, N*sizeof(float), cudaMemcpyDeviceToHost);
  cudaDeviceSynchronize();
  double iStop=cpuSecond();
  // check result
  double elapsed=iStop - iStart;
  float maxError = 0.0f;
  for (int i = 0; i < N; i++)
    maxError = max(maxError, abs(z[i]-42.f));

  printf("Max error: %f\n", maxError);
  printf("AddVec Kernel on GPU with <<<%d, %d>>> and Elapsed time is %f sec \n", blocks.x, threadsPerBlock.x, elapsed);

  // free memory on both CPU and GPU
  cudaFree(x_c);
  cudaFree(y_c);
  free(x);
  free(y);
}
