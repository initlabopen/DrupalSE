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
	def __init__(self,name,root,db,userdb,charset):
		self.name=name
		self.root=root
		self.db=db
		self.userdb=userdb
		self.charset=charset

	def output(self,num):
		print '%3d%25s%+15s%+15s%+40s%10s' % (num, self.name,self.db,self.userdb,self.root,self.charset)

onlyfiles = [f for f in os.listdir(mypath) if isfile(join(mypath, f))]

result=[]
for file in onlyfiles:
	fb=open(join(mypath,file), 'r').read()
	r = re.findall('server_name[\s\S]+?;', fb)
	root = re.findall('root[\s\S]+?;', fb)
	root = root[0][:-1].split()[1]
	charset =  re.findall('charset[\s\S]+?;', fb)
	if charset:
		charset = charset[0][:-1].split()[1]
	r=r[0][:-1].split(' ');
        r.remove('server_name')
	result.append([r,root,charset])

for i,r in enumerate(result):
	for j,t in enumerate(r[0]):
		if t=='_':
			result[i][j][r[0].index(t)]='default'
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
for sit in result:
	root=sit[1]
	charset=sit[2]
	for site in sit[0]:
		if 'www' not in site:
			name=site.split('.')[0]
			db="db"+name if list_mysql_db.index("db"+name) else "not found"
	                userdb="user"+name if list_mysql_user.index("user"+name) else "not found"
			site_obj=DrupalSite(site,root[:-4],db,userdb,charset)
			list_sites.append(site_obj)
print '%3s%25s%+15s%+15s%+40s%10s' % ('#','Site Name', 'DB name' ,'User DB','DocumentRoot','Charset')
for num,site in enumerate(list_sites):
	site.output(num)
