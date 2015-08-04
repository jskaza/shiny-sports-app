
# coding: utf-8

# In[1]:

import numpy as np
import pandas as pd
import random
from bs4 import BeautifulSoup
import urllib2


# In[2]:

soup = BeautifulSoup(urllib2.urlopen('http://www.hittrackeronline.com/index.php?perpage=10000', timeout = 60).read(), 'html.parser') # read-in website
print "MLB HR soup created"


# In[3]:

my_table = soup('table')[16] # table 16 has 2015 season hrs 
rows = my_table.findChildren(['tr'])
print "The MLB HR data has", len(rows), "rows"


# In[4]:

data = {'hitter': [], # hitter name
        'pitcher': [], # pitcher name
        'dist': [], # hr dist
        'speed': [], # speed off bat
        'apex': [], # hit apex
        'elev': [], # elevation angle
        'horiz': [] # horizontal angle
        }

keys = ['hitter', 'pitcher', 'dist', 'speed', 'apex', 'elev', 'horiz'] # need this because keys data.keys() prints in strange order
cols = [3, 5, 10, 11, 14, 12, 13]

size = 50 # set sample size
sample = random.sample(xrange(3, len(rows)-2), size)

#for i in sample: # get a subset of the data
for i in range(3,len(rows)-2): # get the full dataset
    x=rows[i]
    for key, col in zip(keys, cols):
        data[key].append(x.findAll('td')[col])
            #data[key].append(soup('table')[16].findAll('tr')[i].findAll('td')[col])


# In[5]:

# cleanup data
floats = ['apex', 'dist', 'elev', 'horiz', 'speed'] # floats
for i in range(0,len(data['hitter'])):
    for key in keys:
        data[key][i] = data[key][i].get_text()
        data[key][i] = data[key][i].strip()
        data[key][i] = data[key][i].encode('ascii','ignore')
    for flo in floats:
        data[flo][i] = float(data[flo][i])


# In[6]:

# change names to First Last
data['hitter'] = [h.split(',')[1] + " " + h.split(',')[0] for h in data['hitter']]
data['pitcher'] = [p.split(',')[1] + " " + p.split(',')[0] for p in data['pitcher']]


# In[7]:

df = pd.DataFrame(data)
print "The number of missings is", df.count()["hitter"] - df[df.dist > 0].count()["hitter"] 
df = df[df.dist != 0] # remove row if dist == 0


# In[10]:

def flip_horiz(row):
    if row['horiz'] > 90:
        return row['horiz'] - 2*(row['horiz'] - 90)
    elif row['horiz'] < 90:
        return row['horiz'] + 2*(90 - row['horiz'])
    else:
        return 90


# In[11]:

df.apply (lambda row: flip_horiz(row),axis=1)


# In[12]:

df['horiz_flipped'] = df.apply (lambda row: flip_horiz(row),axis=1)


# In[14]:

#plot(df['horiz_flipped'], df['horiz'])


# In[15]:

df.to_csv("hr_data.csv", index=False)


# In[16]:

print "hr_data.csv updated"


# In[ ]:



