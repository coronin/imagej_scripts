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
if not os.path.exists(folder + '%d/' % timestamp):
    os.makedirs(folder + '%d/' % timestamp)


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
fields = ['G Mean', 'G outsideMean', 'B Mean', 'R Mean', 'Roo Count', 'Roo Mean', 'Roo Average Size', 'Roo Total Area', 'Roo %Area', 'nuc Area', 'ID', 'nuc X,Y,W,H']
dHigh = []
dLow = []
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
            oData[x][6].replace(',', ''), oData[x][7].replace(',', ''),
            oData[x][8].replace(',', ''), oData[x][9].replace(',', ''))
        lineData['G Mean'] = oData[x][10]
        lineData['G outsideMean'] = oData[x][12]
        lineData['R Mean'] = oData[x + len(ooData)][3]
        # print out summary
        if float(lineData['G Mean']) > positiveG:
            if float(lineData['G outsideMean']) > float(lineData['G Mean']):
                print '  %s. GFP ? (%s) %s' % (
                    lineData['ID'],
                    lineData['G Mean'], lineData['G outsideMean'])
            else:
                print '  %s. GFP+  (%s) %s' % (
                    lineData['ID'],
                    lineData['G Mean'], lineData['G outsideMean'])
            d = [lineData] + d
            lineData['file tag'] = file[:-5]
            dHigh.append(lineData)
        else:
            d.append(lineData)
            lineData['file tag'] = file[:-5]
            dLow.append(lineData)
    with open(folder + '%d/' % timestamp + file[:-5] + '-%d.csv' % timestamp, 'w') as f:
        writer = csv.DictWriter(f, fieldnames=fields)
        writer.writeheader()
        for dd in d:
            writer.writerow(dd)

with open(folder + '%d/' % timestamp + 'GFP-high-%d.csv' % timestamp, 'w') as f:
    writer = csv.DictWriter(f, fieldnames = fields + ['file tag'])
    writer.writeheader()
    for dd in dHigh:
        writer.writerow(dd)
with open(folder + '%d/' % timestamp + 'GFP-low-%d.csv' % timestamp, 'w') as f:
    writer = csv.DictWriter(f, fieldnames = fields + ['file tag'])
    writer.writeheader()
    for dd in dLow:
        writer.writerow(dd)
