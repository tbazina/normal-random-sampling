#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Thu Dec 15 21:38:11 2016

@author: tomislav
"""

import numpy as np
from timeit import timeit, Timer
from numpy import random_intel
from operator import itemgetter

def timer_brng(brng_name):
    return Timer('numpy.random_intel.randint(10000,50000000,size=250000)', 
        setup='import numpy.random_intel; numpy.random_intel.seed(77777, brng="{}")'.format(brng_name))

_brngs = ['WH', 'PHILOX4X32X10', 'MT2203', 'MCG59', 'MCG31', 'MT19937', 'MRG32K3A', 'SFMT19937', 'R250']
tdata = sorted([(brng, timer_brng(brng).timeit(number=1000)) for brng in _brngs], key=itemgetter(1))

def relative_perf(tdata):
	base = dict(tdata).get('MT19937')
	return [(name, t/base) for name, t in tdata]

print relative_perf(tdata)