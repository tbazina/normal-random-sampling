#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Mon Oct 24 11:30:06 2016

@author: tomislav
"""

import sys
import os
import io
import multiprocessing as mp
import multiprocessing.forking as forking
from scipy.stats.stats import normaltest, chisquare
from time import time, strftime, sleep
import numpy as np
from numpy import random_intel
from numpy.random_intel import seed, normal, randint
from multithread_generate_normal import generate_norm_mt, generate_unif_mt


if sys.platform.startswith('win'):
    # First define a modified version of Popen.
    class _Popen(forking.Popen):
        def __init__(self, *args, **kw):
            if hasattr(sys, 'frozen'):
                # We have to set original _MEIPASS2 value from sys._MEIPASS
                # to get --onefile mode working.
                os.putenv('_MEIPASS2', sys._MEIPASS)
            try:
                super(_Popen, self).__init__(*args, **kw)
            finally:
                if hasattr(sys, 'frozen'):
                    # On some platforms (e.g. AIX) 'os.unsetenv()' is not
                    # available. In those cases we cannot delete the variable
                    # but only set it to the empty string. The bootloader
                    # can handle this case.
                    if hasattr(os, 'unsetenv'):
                        os.unsetenv('_MEIPASS2')
                    else:
                        os.putenv('_MEIPASS2', '')

    # Second override 'Popen' class with our modified version.
    forking.Popen = _Popen


def input_normal():
    # print "\n_-Normalno Uzorkovanje-_"
    mean = float(inpt("Srednja vrijednost niza: "))  # Desired mean
    dmean = 0.  # Mean error
    stdev = float(inpt("Standardna devijacija niza: "))
    # Standard deviation
    dstdev = float(inpt("Odstupanje standardne devijacije: "))
    # Standard deviation error
    sig_lvl = float(inpt("Donja razina signifikantnosti: "))
    sig_lvl_up = float(inpt("Gornja razina signifikantnosti: "))
    if sig_lvl >= sig_lvl_up:
        raise ValueError
    # Significance level for normality test
    size = int(inpt("Broj clanova niza: "))  # Size of each sequence
    seq_number = int(inpt("Broj nizova: "))
    # Number of sequences to generate
    threads = int(inpt("Broj threadova: "))
    # Number of simultaneous processes
    generate_norm_mt(threads, seq_number, mean, stdev, size, dmean,
                     dstdev, sig_lvl, sig_lvl_up)


def input_uniform():
    # print "\n_-Uniformno Uzorkovanje-_"
    mean = float(inpt("Srednja vrijednost niza: "))  # Desired mean
    dmean = 0.  # Mean error
    low = int(inpt("Donja granica niza: "))  # Lowest integer
    high = int(inpt("Gornja granica niza: "))  # Highest integer
    if low >= high:
        raise ValueError
    sig_lvl = float(inpt("Donja razina signifikantnosti: "))
    sig_lvl_up = float(inpt("Gornja razina signifikantnosti: "))
    if sig_lvl >= sig_lvl_up:
        raise ValueError
    # Significance level for uniformity test
    size = int(inpt("Broj clanova niza: "))  # Size of each sequence
    seq_number = int(inpt("Broj nizova: "))
    # Number of sequences to generate
    threads = int(inpt("Broj threadova: "))
    # Number of simultaneous processes
    generate_unif_mt(threads, seq_number, mean, low, high, size, dmean,
                     sig_lvl, sig_lvl_up)


def input_error():
    print "\nUnesite slovo 'n' za normalnu razdiobu, a 'u' za uniformnu!"
    sleep(10)
    sys.exit(0)


def inpt(sentence):
    usr_inpt = "".join(raw_input(sentence).split())
    return usr_inpt


def norm_uniform(rand_sampl_type):
    switcher = {
        'n': input_normal,
        'u': input_uniform,
    }
    func = switcher.get(rand_sampl_type, input_error)
    return func()


if __name__ == '__main__':
    # On Windows calling this function is necessary.
    # On Linux/OSX it does nothing.
    mp.freeze_support()

    try:
        norm_uniform(inpt("n - Normalno uzorkovanje, "
                          "u - Uniformno uzorkovanje: "))
    except ValueError:
        print "\nUnesite ispravan broj!"
        sleep(10)
        sys.exit(0)
    except KeyboardInterrupt:
        print "\n\nPrekid izvodenja od strane korisnika! ... Kraj ..."
        sleep(10)
        sys.exit(0)
