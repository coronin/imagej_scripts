#!/usr/bin/env python
#
# by i@cailiang.net  2017

import os
import csv
import time

folder = '/Users/liang/Downloads/wj/'  # remeber to have / at the end on mac
positiveG = 199.99  # above which view as GFP positive

# use file names to generate unique tag list
files = [f.replace('-Results.csv', '') for f in os.listdir(folder) if f.endswith('-Results.csv')]
timestamp = int(time.time())


def data_from_csv(filename):
    with open(folder + filename, 'r') as f:
        ff = csv.reader(f)
        key = []
        data = []
        for fff in ff:
            if not key:
                key = fff
            else:
                data.append(fff)
    return key, data


# for loop
for file in files:
    print '# Processing %s' % file
    # open each pair, and import data
    [ooKey, ooData] = data_from_csv(file + 'Otsu-Summary.csv')
    [oKey, oData] = data_from_csv(file + '-Results.csv')
    if len(oData) != 4 * len(ooData):
        print '  Failed.'
        continue
    d = []
    for x, oo in enumerate(ooData):
        lineData = {}
        for y, a in enumerate(ooKey):
            if a == 'Slice':
                lineData['ID'] = str(int(oo[y][2:]) + 1)
                continue
            lineData['Roo %s' % a] = oo[y]
        # ID Label Area Mean Min Max BX BY Width Height
        #     G-Mean G-Percentage G-outsideMean
        lineData['nuc Area'] = oData[x][2]
        lineData['B Mean'] = oData[x][3]
        lineData['nuc X,Y,W,H'] = '%s,%s,%s,%s' % (
            oData[x][6], oData[x][7], oData[x][8], oData[x][9])
        lineData['G Mean'] = oData[x][10]
        lineData['G outsideMean'] = oData[x][12]
        lineData['R Mean'] = oData[x + len(ooData)][3]
        # print out summary
        if float(lineData['G Mean']) > positiveG:
            if float(lineData['G outsideMean']) > float(lineData['G Mean']):
                print '  %s. GFP ? (%s) %s' % (
                    lineData['ID'], lineData['G Mean'], lineData['G outsideMean'])
            else:
                print '  %s. GFP+  (%s) %s' % (
                    lineData['ID'], lineData['G Mean'], lineData['G outsideMean'])
            d = [lineData] + d
        else:
            d.append(lineData)
    with open(folder + file[:-5] + '-%d.csv' % timestamp, 'w') as f:
        fields = ['G Mean', 'G outsideMean', 'B Mean', 'R Mean', 'Roo Count', 'Roo Mean', 'Roo Average Size', 'Roo Total Area', 'Roo %Area', 'nuc Area', 'ID', 'nuc X,Y,W,H']
        writer = csv.DictWriter(f, fieldnames=fields)
        writer.writeheader()
        for dd in d:
            writer.writerow(dd)
