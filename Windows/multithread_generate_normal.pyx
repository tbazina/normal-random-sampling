#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Wed Oct 26 23:17:59 2016

@author: tomislav
"""

import sys
import os
import io
import multiprocessing as mp
from scipy.stats.stats import normaltest, chisquare
from time import time, strftime, sleep
import numpy as np
from numpy import random_intel

cimport numpy as np

DTYPE = np.float64
DTYPEINT = np.int64
ctypedef np.float64_t DTYPE_t
ctypedef np.int64_t DTYPEINT_t

cimport cython
@cython.boundscheck(False) # turn off bounds-checking for entire function
@cython.wraparound(False)  # turn off negative index wrapping


def generate_norm_mt(unsigned int threads, unsigned int seq_number,
                     double mean, double stdev, unsigned int size,
                     double dmean, double dstdev, double sig_lvl,
                     double sig_lvl_up):

    # print "Creating Lock object ..."
    cdef object lock = mp.Lock()

    # print "Creating Queue objects ..."
    # cdef object qcnt = mp.Queue(threads)
    cdef object qquit = mp.Queue(1)
    cdef object qnum = mp.Queue(1)
    qnum.put(seq_number)

    # print "Starting time count ..."
    cdef double time_start = time()

    # print "Generiram {} niz/a/ova ... Molim pričekajte\n".format(seq_number)
    cdef unsigned int i
    cdef object j

    if seq_number:
        p = [mp.Process(target=generate_norm,
                        args=(mean, stdev, size, dmean, dstdev, sig_lvl,
                              # qcnt,
                              sig_lvl_up, lock, qnum, qquit))
                        for i in range(threads)]

        print
        [j.start() for j in p]
        qit = qquit.get()
        print

    # print "\nStopping time count ..."
    cdef double time_exe = time() - time_start

    # print "\nCreating log file ..."
    __location__ = os.path.realpath(
                    os.path.join(os.getcwd(), os.path.dirname(sys.executable)))
    fname = (r"[{}]LOG_N{}_AVER{}_SD{}_T{}_SIG{}-{}.log").format(
                strftime('%d.%m.%Y_%H-%M-%S'), size, mean, stdev, dstdev,
                sig_lvl, sig_lvl_up)
    with io.open(os.path.join(__location__, fname), mode='w+b',
                 newline=None) as logfile:
        logfile.write('------ Normalno uzorkovanje ------\n\n'
                      'Srednja vrijednost niza: {}\n'
                      'Standardna devijacija niza: {}\n'
                      'Odstupanje standardne devijacije: {}\n'
                      'Donja razina signifikantnosti: {}\n'
                      'Gornja razina signifikantnosti: {}\n'
                      'Broj clanova niza: {}\n'
                      'Broj nizova: {}\n'
                      'Broj threadova: {}\n'
                      'Vrijeme izvodenja: {} s\n'
                      'Prosjecno ispitano nizova po threadu: {}'.format(
                          mean, stdev, dstdev, sig_lvl, sig_lvl_up, size,
                          seq_number, threads, time_exe, qit))

    # print "\nExecution time: {} s".format(time_exe)

    # while not qcnt.empty():
    #     print "Thread checked: {} sequences".format(qcnt.get())

    if seq_number:
        for j in p:
            try:
                j.terminate()
            except WindowsError:
                pass
        [j.join() for j in p]

    raw_input("\nIzvodenje zavrseno ... Pritisnite enter za izlaz")
    sys.exit(0)

def generate_unif_mt(unsigned int threads, unsigned int seq_number,
                     double mean, unsigned int low, unsigned int high,
                     unsigned int size, double dmean, double sig_lvl,
                     double sig_lvl_up):

    # print "Creating Lock object ..."
    cdef object lock = mp.Lock()

    # print "Creating Queue objects ..."
    # cdef object qcnt = mp.Queue(threads)
    cdef object qquit = mp.Queue(1)
    cdef object qnum = mp.Queue(1)
    qnum.put(seq_number)

    # print "Starting time count ..."
    cdef double time_start = time()

    # print "Generiram {} niz/a/ova ... Molim pričekajte\n".format(seq_number)
    cdef unsigned int i
    cdef object j

    if seq_number:
        p = [mp.Process(target=generate_unif,
                        args=(mean, low, high, size, dmean, sig_lvl,
                              # qcnt,
                              sig_lvl_up, lock, qnum, qquit))
                        for i in range(threads)]

        print
        [j.start() for j in p]
        qit = qquit.get()
        print

    # print "\nStopping time count ..."
    cdef double time_exe = time() - time_start

    # print "\nCreating log file ..."
    __location__ = os.path.realpath(
                    os.path.join(os.getcwd(), os.path.dirname(sys.executable)))
    fname = (r"[{}]LOG_U{}_AVER{}_D{}_G{}_SIG{}-{}.log").format(
                strftime('%d.%m.%Y_%H-%M-%S'), size, mean, low, high, sig_lvl,
                sig_lvl_up)
    with io.open(os.path.join(__location__, fname), mode='w+b',
                 newline=None) as logfile:
        logfile.write('------ Uniformno uzorkovanje ------\n\n'
                      'Srednja vrijednost niza: {}\n'
                      'Donja granica niza: {}\n'
                      'Gornja granica niza: {}\n'
                      'Donja razina signifikantnosti: {}\n'
                      'Gornja razina signifikantnosti: {}\n'
                      'Broj clanova niza: {}\n'
                      'Broj nizova: {}\n'
                      'Broj threadova: {}\n'
                      'Vrijeme izvodenja: {} s\n'
                      'Prosjecno ispitano nizova po threadu: {}'.format(
                          mean, low, high, sig_lvl, sig_lvl_up, size,
                          seq_number, threads, time_exe, qit))

    # print "\nExecution time: {} s".format(time_exe)

    # while not qcnt.empty():
    #     print "Thread checked: {} sequences".format(qcnt.get())

    if seq_number:
        for j in p:
            try:
                j.terminate()
            except WindowsError:
                pass
        [j.join() for j in p]

    raw_input("\nIzvodenje zavrseno ... Pritisnite enter za izlaz")
    sys.exit(0)

cpdef int generate_norm(double mean, double stdev, unsigned int size,
                        double dmean, double dstdev, double sig_lvl,
                        # object qcnt,
                        double sig_lvl_up, object lock, object qnum,
                        object qquit) except -1:

    np.random_intel.seed(brng='SFMT19937')
    cdef np.ndarray[DTYPE_t, ndim=1] r
    cdef unsigned int cnt = 0
    cdef unsigned int seq_num = qnum.get()
    cdef unsigned int seq_max = seq_num
    qnum.put(seq_num)
    __location__ = os.path.realpath(
                    os.path.join(os.getcwd(), os.path.dirname(sys.executable)))

    while seq_num:
        r = np.random_intel.normal(mean, stdev, size).round(0)
        cnt += 1
        while not (abs(stdev-r.std(ddof=1)) <= dstdev and
                   abs(mean-r.mean()) <= dmean and
                   normaltest(r).pvalue >= sig_lvl and
                   normaltest(r).pvalue <= sig_lvl_up and r.min() >= 0.):
            r = np.random_intel.normal(mean, stdev, size).round(0)
            cnt += 1
        # print "\nSequence found!"
        fname = (r"{}_N{}_AVER{}_SD{}_T{}_SIG{}-{}_{}.csv").format(
                    np.random_intel.randint(1e6, 1e7), size, mean, stdev,
                    dstdev, sig_lvl, sig_lvl_up, strftime('%H-%M-%S'))
        np.savetxt(fname=os.path.join(__location__, fname), X=r, fmt='%d',
                   delimiter=',', newline='\n')
        # print "Sequence saved!"
        seq_num = max(qnum.get()-1, 0)
        qnum.put(seq_num)
        with lock:
            sys.stdout.write("\rPreostalo: {:{wid}d}/{:d} ...".format(
                                 seq_num, seq_max, wid=len(repr(seq_max))))
            sys.stdout.flush()
    qquit.put(cnt)
    # qcnt.put(cnt)


cpdef int generate_unif(double mean, unsigned int low, unsigned int high,
                        unsigned int size, double dmean, double sig_lvl,
                        # object qcnt,
                        double sig_lvl_up, object lock, object qnum,
                        object qquit) except -1:

    np.random_intel.seed(brng='SFMT19937')
    cdef np.ndarray[DTYPEINT_t, ndim=1] r
    cdef unsigned int cnt = 0
    cdef unsigned int seq_num = qnum.get()
    cdef unsigned int seq_max = seq_num
    high += 1
    qnum.put(seq_num)
    __location__ = os.path.realpath(
                    os.path.join(os.getcwd(), os.path.dirname(sys.executable)))

    while seq_num:
        r = np.random_intel.randint(low, high, size, dtype=DTYPEINT)
        cnt += 1
        while not (abs(mean-r.mean()) <= dmean and
                   chsq(r) >= sig_lvl and chsq(r) <= sig_lvl_up):
            r = np.random_intel.randint(low, high, size, dtype=DTYPEINT)
            cnt += 1
        # print "\nSequence found!"
        fname = (r"{}_U{}_AVER{}_D{}_G{}_SIG{}-{}_{}.csv").format(
                    np.random_intel.randint(1e6, 1e7), size, mean, low, high-1,
                    sig_lvl, sig_lvl_up, strftime('%H-%M-%S'))
        np.savetxt(fname=os.path.join(__location__, fname), X=r, fmt='%d',
                   delimiter=',', newline='\n')
        # print "Sequence saved!"
        seq_num = max(qnum.get()-1, 0)
        qnum.put(seq_num)
        with lock:
            sys.stdout.write("\rPreostalo: {:{wid}d}/{:d} ...".format(
                                 seq_num, seq_max, wid=len(repr(seq_max))))
            sys.stdout.flush()
    qquit.put(cnt)
    # qcnt.put(cnt)


cdef double chsq(np.ndarray[DTYPEINT_t, ndim=1] r) except -1:
    cdef np.ndarray[DTYPEINT_t, ndim=1] bins = np.bincount(r)
    return chisquare(bins[bins.nonzero()[0]]).pvalue

