#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Thu Oct 27 19:56:48 2016

@author: tomislav
"""

import numpy
try:
    from setuptools import setup
    from setuptools import Extension
except ImportError:
    from distutils.core import setup
    from distutils.extension import Extension
from Cython.Build import cythonize

ext_modules = [
    Extension("multithread_generate_normal",
              sources=["multithread_generate_normal.pyx"],
              # libraries=["m"],  # Unix-like specific
              include_dirs=[numpy.get_include()]
              )
]

setup(
  name="Multithread-Generate-Normal",
  ext_modules=cythonize(ext_modules)
)
