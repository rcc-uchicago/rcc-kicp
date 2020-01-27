'''
    A simple code to demonstrate how to use multiple cores to speed up 
    a program.

    This code is going to use 4 cores to calculate eigen vectors of 4 random matrices. 

'''

import numpy
from multiprocessing import Pool
from itertools import repeat

num_cores = 4
pool = Pool(num_cores)

pool.map(numpy.linalg.eig,repeat(numpy.random.rand(1000,1000),num_cores))
