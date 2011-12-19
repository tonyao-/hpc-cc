#!/usr/bin/env python
#
# Author: Andrey Zarochentsev <andrey.zar@gmail.com>
# Date  : 10 May 2011
# Desc. : show free cpu on cluster
#
#
#
#

import pbs
import sys
import commands                         # used to retrieve logs through scp
import time                             # needed for time functions
from time import strftime
import datetime
import cgi                              # used to output to html
import cgitb
from PBSQuery import PBSQuery, PBSError # PBS python module

cgitb.enable()


JS_PATH      = '/table.js'
pbs_server   = 'pbs-tp'
LOGO         = "../icons/logo.png"
cpunumber    = 8
np 	     = " "

#def main():

#  pbs_server = 'pbs-tp'

#  con = pbs.pbs_connect(pbs_server)
#  nodes = pbs.pbs_statnode(con, "", "NULL", "NULL")


#  for node in nodes:
#    jobnumber = 0
#    for attrib in node.attribs:
#     if attrib.name == 'jobs':
#	jobnumber = len(attrib.value.split(','))
#    print "%s numberjobs = %d " %(node.name, jobnumber)

def print_node_table(nodes,jobs):
	form  = cgi.FieldStorage()
	print "<h1>nodes</h1>"
	print "<table class='torque table-autosort:0 table-stripeclass:alternate'>"

	# create the header to the job table
	print "<thead><tr>"
	print "<th class=' table-sortable:numeric'"
	print "align='left'>nodename</th>"
	print "<th class=' table-sortable:numeric'"
	print "align='left'>number jobs</th>"
	print "<th class=' table-sortable:numeric'"
	print "align='left'>free cpu</th>"
	S = (0,1,2,3,4,5,6,7)
	for i in S:
	     l=i+1
	     print "<th class=' table-sortable:default'"
             print "align='left'>user%d</th>" %l


	print "</tr></thead>"
	
	alljobnumber = 0;	
	allfreecpu = 0;
	freecpu = 0;
	jnumber = 0;
	nodelist=[]
	for node in nodes:
	    jnumber = 0;
	    users=[]
	    jobnumber = 0
	    for attrib in node.attribs:
		if attrib.name == 'jobs':
			jobnumber = len(attrib.value.split(','))
			jnumber = int(jobnumber)
			jobnames = attrib.value.split(',')
			for joba in jobnames:
			    for jobb in jobs.items():
				if jobb[0] == joba.split('/')[1]:
				    user=jobb[1]['euser'][0]
				    users.append(user)
			
#			jnumber = int(jobnumber)
		if attrib.name == 'np':	        
			cpnumber = attrib.value
			cpunumber = int(cpnumber)
#			jnumber = int(jobnumber)
#			freecpu = cpunumber-jnumber
		if attrib.name == 'properties': 
			color = attrib.value

	    freecpu = cpunumber-jnumber 
	    alljobnumber = alljobnumber+jnumber
	    allfreecpu = allfreecpu+freecpu
	    print "<td><span style=\"color: %s\">%s</span></td>" % (color,node.name) #line[0]
	    print "<td>%d</td>" % jnumber #line[1]
	    print "<td>%d</td>" % freecpu
	    for i in S:
		if len(users) > i:
		    print "<td>%s</td>" % users[i]
		else:
		    print "<td></td>"
            print "</tr>"
	    
	# create the footer to the job taible

#	print "</table>"
	
#	print "<table class='torque table-autosort:0 table-stripeclass:alternate'>"
	print "<td>sum </td>"
	print "<td>%d</td>" % alljobnumber
	print "<td>%d</td>" % allfreecpu
	print "</tr>"
	print "</table>"

	
	

#main()
#    print node.name
#    print node.jobs
#       print '\t', attrib.name, '=', attrib.value
#    for attrib in node.attribs:
#      print "attrib = %s" %(attrib )
#      print '\t', attrib.name, '=', attrib.value


def print_header():
    # try connecting to the PBS server
#    print " "
    print "Content-Type: text/html"
#    print " "
#    print " "
    try:
	con = pbs.pbs_connect(pbs_server)
	nodes = pbs.pbs_statnode(con, "", "NULL", "NULL")
    except pbserr, error:
	print "<h1>Error connecting to PBS server:</h1><tt>",error,"</tt>"
        sys.exit(1)	

    # print the html header
    print '''
    <!-- define style -->
    <style type="text/css">
       /* division definitions */
       body{margin:0; padding:10 0 0 0}
       div#sidebar{text-align:center; position:fixed; width:350px;
                   height:100%%; background-color:white}
       div#main{text-align:center; position:absolute; left:350px; height:100%%;
                width:auto}
       h1{font-size:0.7em}
       /* table style */
       table.torque{font-size:0.7em; border:1px solid black;
                    border-collapse:collapse; margin-left:auto;
                    margin-right:auto}
       table.torque th, table.torque td{border:1px solid #aaaaaa;
                                        padding: 2px 15px 2px 15px}
       table.torque thead th{background-color:#ccccff}
       table.torque tfoot td{background-color:#ffccff}
       tr.alternate{background-color:#ffffcc}
       th.table-sortable{cursor:pointer}
       /* link style */
       A:link{text-decoration: none; color: black}
       A:visited{text-decoration: none; color: black}
       A:active{text-decoration: none; color: black}
       A:hover{text-decoration: underline; color: red;}
    </style>
    <!-- declare header -->
    <head>
       <title>Job list by nodes</title> 
       <script src="%s" type="text/javascript"></script>
    </head>
    ''' % JS_PATH
    return nodes


nodes = print_header()
pbs  = PBSQuery(pbs_server)
jobs = pbs.getjobs()

#print "ZAr noses = %s " % nodes
print "<div id=\"main\">"
# determine if specific job requested
#job = cgi.FieldStorage().getvalue('node')
#if job == None:
    # print job table if not
print_node_table(nodes,jobs)
#else:
    # print job details and logs if requested
#   print_job_detail(job,nodes)
#    print "<br/>"
#    print_job_logs(job,nodes)

print "</div>"


print "<div id=\"sidebar\">"
print "<img src=\"%s\" height=\"146\" width=\"100\" align=\"middle\">" % LOGO
print "<h1>%s</h1>" % strftime("%Y-%m-%d %H:%M:%S")
print "<br/>"
# print user table
#print_user_table(jobs)
print "</div>"




