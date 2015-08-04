
# coding: utf-8

# In[192]:

import numpy as np
import pandas as pd
import random
from bs4 import BeautifulSoup
import urllib2


# In[193]:

soup = BeautifulSoup(urllib2.urlopen('http://www.pro-football-reference.com/coaches/', timeout = 60).read(), 'html.parser') # read-in website


# In[194]:

my_table = soup('table')[0] # table 0 has coaching data
rows = my_table.findChildren(['tr'])


# In[255]:

rows_no_head = [item for index, item in enumerate(rows) if index % 31 != 0]
print "The NFL Coaching data has", len(rows_no_head), "rows"

data = {'name': [], # coach name
        'yrs': [], # years in football
        'g': [], # games
        'w': [], # wins
        'l': [], # losses
        't': [], # ties
        'perc': [], # w-l percentage
        'poff_g': [], # playoff games
        'poff_w': [], # playoff wins
        'poff_l': [], # playoff losses
        'poff_perc': [], # playoff w-l percentage
        'avg_finish': [], # average division finish
        'champ': [], # championships (sb + champ before sb era)
        'sb': [], # super bowl wins
        'conf': [] # conference championships
        }

keys = ['name', 'yrs', 'g', 'w', 'l', 't', 'perc', 'poff_g', 'poff_w', 'poff_l', 'poff_perc',
        'avg_finish', 'champ', 'sb', 'conf'] # need this because keys data.keys() prints in strange order
cols = [1, 2, 4, 5, 6, 7, 8, 11, 12, 13, 14, 15, 17, 18, 19]

for i in range(len(rows_no_head)):
    x=rows_no_head[i]
    for key, col in zip(keys, cols):
            data[key].append(x.findAll('td')[col])

for i in range(len(rows_no_head)):
    for key in keys:
        data[key][i] = str(data[key][i].get_text())
        if key == "name":
            if data[key][i][-1] == "+":
                data[key][i] = data[key][i][:-1]
        if key in ('yrs', 'g', 'w', 'l', 't', 'poff_g', 'poff_w', 'poff_l', 'champ', 'sb', 'conf'):
            if data[key][i] != '':
                data[key][i] = int(data[key][i])
        if key in ('perc', 'poff_perc', 'avg_finish'):
            if data[key][i] != '':
                data[key][i] = float(data[key][i])


# In[256]:

df = pd.DataFrame(data)


# In[257]:

df.head()


# In[258]:

df.to_csv("nfl_coaches.csv", index=False)


# In[ ]:

print "nfl_coaches.csv updated"

