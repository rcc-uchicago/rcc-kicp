'''
    A code to sequentially calculate eigen vectors of 4 random matrices

'''


import numpy

for i in xrange(0,4):
    v = numpy.linalg.eig(numpy.random.rand(1000,1000))

