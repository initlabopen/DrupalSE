import re
import MySQLdb
import sys
import getopt
import os
import datetime
import yaml
from os.path import isfile, join

mypath='/etc/nginx/sites-enabled'
class DrupalSite:
	def __init__(self,name,db,userdb):
		self.name=name
		self.db=db
		self.userdb=userdb

	def output(self,num):
		print '%3d%25s%+25s%+25s' % (num, self.name,self.db,self.userdb)

onlyfiles = [f for f in os.listdir(mypath) if isfile(join(mypath, f))]

result=[]
for file in onlyfiles:
	fb=open(join(mypath,file), 'r').read()
	r = re.findall('server_name[\s\S]+?;', fb)
	r=r[0][:-1].split(' ');
	result +=r
while result.count('server_name'):
	result.remove('server_name')
for r in result:
	if r=='_':
		result[result.index(r)]='default'
#	if 'www' in r:
#		result1.remove(r)
my_cnf=open('/root/.my.cnf','r')
mysql_passwd=[x.split('=')[1].split('\"')[1] for x in my_cnf.readlines() if 'password' in x]
db = MySQLdb.connect(host="localhost", user="root",passwd=mysql_passwd[0], db="mysql", charset='utf8')
cursor = db.cursor()

sql = """SELECT user FROM user"""
cursor.execute(sql)
list_mysql_user = [x[0] for x in cursor.fetchall()]


sql = """show databases"""
cursor.execute(sql)
data =  cursor.fetchall()

list_mysql_db= [x[0] for x in data]
db.close()

list_sites = []
for site in result:
	if 'www' not in site:
		name=site.split('.')[0]
		db="db"+name if list_mysql_db.index("db"+name) else "not found"
                userdb="user"+name if list_mysql_user.index("user"+name) else "not found"
		site_obj=DrupalSite(site,db,userdb)
		list_sites.append(site_obj)
#print '%+3s%25s%+25s%+25s' % ('#','Site Name', 'DB name' ,'User DB')
#for num,site in enumerate(list_sites):
#	site.output(num)
print len(list_sites)
