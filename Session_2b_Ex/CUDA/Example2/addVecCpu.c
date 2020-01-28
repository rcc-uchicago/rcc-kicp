#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>


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
  double cpuStart=cpuSecond();
  for (int i = 0; i < N; i++) {
    x[i] = i;
    y[i] = 42-i;
    z[i] = x[i] + y[i];
  }
 double cpuEnd=cpuSecond();
 double cpuElapse = cpuEnd - cpuStart;
 printf("Time take on CPU %f s\n", cpuElapse);

  free(x);
  free(y);
}
