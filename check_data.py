#!/usr/bin/env python
import os
import sys
#import casac
#msmd = casac.casac.msmetadata()
#tb = casac.casac.table()
from casatools import msmetadata,table
msmd=msmetadata()
tb=table()

vis=sys.argv[1]
os.system('du -hs {0}'.format(vis))
msmd.open(vis)
tb.open(vis)
print('nant: {0}'.format(msmd.nantennas()))
print('nbaseline: {0}'.format(msmd.nbaselines()))
#antennas = msmd.antennaids()
antennas = msmd.antennasforscan(msmd.scannumbers()[0])
#print(antennas,antennas.size)
dat = tb.query("ANTENNA1=={0} AND ANTENNA2=={0}".format(antennas[0],antennas[0]))
print('Columns present: {0}'.format(dat.colnames()))
#print('Auto-correlation (antenna {0}) data length: {1}'.format(antennas[0],len(dat.getcol('DATA'))))
nspw=msmd.nspw()
print('nspw: {0}'.format(nspw))
low=msmd.chanfreqs(0)[0]/1e6
high=msmd.chanfreqs(nspw-1)[-1]/1e6
print('Freqs: {0:.0f}-{1:.0f} MHz'.format(low,high))
print('Channel width: {0:.0f} kHz'.format(msmd.chanwidths(0)[0]/1e3))
nchans=0
for spw in range(nspw):
  nchan = msmd.nchan(spw)
  nchans += nchan
  low=msmd.chanfreqs(spw)[0]/1e6
  high=msmd.chanfreqs(spw)[-1]/1e6
  print('Freqs (spw {0}): {1}-{2} MHz (nchan: {3})'.format(spw,low,high,nchan))
print('nchans: {0}'.format(nchans))
print('fields: {0}'.format(msmd.fieldnames()))
print('npol: {0}'.format(msmd.ncorrforpol()[0]))
T=msmd.timerangeforobs(0)
hours=(T['end']['m0']['value'] - T['begin']['m0']['value']) * 24.0
print('Tobs: {0} hours'.format(hours))
print('Dump time: {0}'.format(msmd.exposuretime(msmd.scannumbers()[0])['value']))
print('nscans: {0}'.format(msmd.nscans()))
msmd.done()
