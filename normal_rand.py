#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Mon Oct 24 11:30:06 2016

@author: tomislav
"""

import sys
from multithread_generate_normal import generate_norm_mt, generate_unif_mt


def input_normal():
    # print "\n_-Normalno Uzorkovanje-_"
    mean = float(inpt("Srednja vrijednost niza: "))  # Desired mean
    dmean = 0.  # Mean error
    stdev = float(inpt("Standardna devijacija niza: "))
    # Standard deviation
    dstdev = float(inpt("Odstupanje standardne devijacije: "))
    # Standard deviation error
    sig_lvl = float(inpt("Razina signifikantnosti: "))
    # Significance level for normality test
    size = int(inpt("Broj članova niza: "))  # Size of each sequence
    seq_number = int(inpt("Broj nizova: "))
    # Number of sequences to generate
    threads = int(inpt("Broj threadova: "))
    # Number of simultaneous processes
    generate_norm_mt(threads, seq_number, mean, stdev, size, dmean,
                     dstdev, sig_lvl)


def input_uniform():
    # print "\n_-Uniformno Uzorkovanje-_"
    mean = float(inpt("Srednja vrijednost niza: "))  # Desired mean
    dmean = 0.  # Mean error
    low = int(inpt("Donja granica niza: "))  # Lowest integer
    high = int(inpt("Gornja granica niza: "))  # Highest integer
    if low >= high:
        raise ValueError
    sig_lvl = float(inpt("Razina signifikantnosti: "))
    # Significance level for normality test
    size = int(inpt("Broj članova niza: "))  # Size of each sequence
    seq_number = int(inpt("Broj nizova: "))
    # Number of sequences to generate
    threads = int(inpt("Broj threadova: "))
    # Number of simultaneous processes
    generate_unif_mt(threads, seq_number, mean, low, high, size, dmean,
                     sig_lvl)


def input_error():
    print "\nUnesite slovo 'n' za normalnu razdiobu, a 'u' za uniformnu!"
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

    try:
        norm_uniform(inpt("n - Normalno uzorkovanje, "
                          "u - Uniformno uzorkovanje: "))
    except ValueError:
        print "\nUnesite ispravan broj!"
    except KeyboardInterrupt:
        print "\n\nPrekid izvođenja od strane korisnika! ... Kraj ..."
        sys.exit(0)
