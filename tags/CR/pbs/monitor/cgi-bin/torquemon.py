#!/usr/bin/python
###############################################################################
# Copyright (c) 2010 Philip Ilten and University College Dublin               #
#                                                                             #
#    Interactive web monitor for PBS/Torque batch systems, focused on         #
#    providing queue and detailed job information for users. Requires the     #
#    table javascript library by Matt Kruse from,                             #
#                                                                             #
#        http://www.javascripttoolbox.com/lib/table/index.php                 #
#                                                                             #
#    and the PBS Python libraries available through SARA.                     #
#                                                                             #
#        https://subtrac.sara.nl/oss/pbs_python                               #
#                                                                             #
#    Based on pbswebmon by Stephen Childs.                                    #
#                                                                             #
#        http://sourceforge.net/apps/trac/pbswebmon/wiki                      #
#                                                                             #
#    This program is free software: you can redistribute it and/or modify     #
#    it under the terms of the GNU General Public License as published by     #
#    the Free Software Foundation, either version 3 of the License, or        #
#    (at your option) any later version.                                      #
#                                                                             #
#    This program is distributed in the hope that it will be useful,          #
#    but WITHOUT ANY WARRANTY; without even the implied warranty of           #
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            #
#    GNU General Public License for more details.                             #
#                                                                             #
#    You should have received a copy of the GNU General Public License        #
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.    #
#                                                                             #
###############################################################################

from PBSQuery import PBSQuery, PBSError # PBS python module
import commands                         # used to retrieve logs through scp
import time                             # needed for time functions
from time import strftime
import datetime
import cgi                              # used to output to html
import cgitb
import ldap
cgitb.enable()

#############################################################################
# IMPORTANT - these variables need to be specified by user
#############################################################################
# name of Torque server
#SERVER       = 'localhost'
SERVER       = 'pbs-tp'
# path to logo
#LOGO         = "/path/to/logo"
LOGO         = "../icons/logo.png"
# users to report
#USERS        = ['user1', 'user2', 'user3']
#USERS       = ['sizova','memnonov','viz','evarest','gotlib','krauklis','chizhov','ivchenko','melikova','butur','maulini','galyuck','zar','aandreev','opodkopaeva','nivanova','egracheva','esmirnova','vneverov','gmudzhikova','ebrodskaya','omatusevich','mmakarova','agolovin','akomolov','eruzich','eveliev','ishikhman','kkharchenko','kklyukin','nkrivko','vbessonov','danikiev','asamusenko','iashikhmin','vchirkov','akomolkin','enugumanov','npetrov','vshakhardin','maverina','krutkovskij','nfilippov','agagin','snemnygin']
# user for scp log files
#SCP_USER     = 'torque'
SCP_USER     = 'root'
# path (or relative path to this file) where the logs should be stored
#LOG_DIR      = '/var/www/cgi-bin/logs'
LOG_DIR      = '../logs'
# path to Torque on nodes 
TORQUE_PATH  = '/var/spool/torque'
# path to table.js
#JS_PATH      = '/var/www/cgi-bin/table.js'
JS_PATH      = './'
# jobs states to report with associated job color
JOB_STATES   = {'R':'green','Q':'yellow','E':'red','C':'blue'}
LDAPSERVER   = '192.168.0.90'
ldin = ldap.open(LDAPSERVER)
USERS = []
line = "ou=people,dc=ptc,dc=spbu,dc=ru"
LDUSERS=ldin.search_s(line,ldap.SCOPE_SUBTREE,"objectclass=person",['uid'])
for user in LDUSERS:
	USERS.append(user[1]['uid'][0])




#############################################################################
# convert values into gigabytes
#############################################################################
def convert_to_gb(mem):
    idx = mem.rfind("kb")
    if idx != -1:
        mem = float(mem[0:idx])
        return "%s GB" % str(round(mem/(1000.0*1000.0),2))
    idx = mem.rfind("mb")
    if idx != -1:
        mem = float(mem[0:idx])
        return "%s GB" % str(round(mem/(1000.0),2))

#############################################################################
# create the users dictionary
#############################################################################
def create_users(user_list):
    users = {}
    # loop over the requested users
    for user in user_list:
        users[user] = {}
        users[user]['total']=0
        for state, color in JOB_STATES.items():
            users[user][state]=0
    return users

#############################################################################
# fill the users dictionary
#############################################################################
def fill_users(jobs):
    # create users
    users = create_users(USERS)
    # loop over jobs
    for name, atts in jobs.items():
        # grab the user name
        if 'job_state' in atts:
            job_type=atts['job_state'][0]
        user=atts['Job_Owner'][0].split('@')[0]
        # add the user
        if not user in users:
            users[user]={}
            users[user]['total']=1
            for state, color in JOB_STATES.items():
                if state == job_type:
                    users[user][state]=1
                else:
                    users[user][state]=0
        # increment the job state
        else:
            users[user]['total']=users[user]['total']+1
            users[user][job_type]=users[user][job_type]+1
    return users
           
#############################################################################
# print a table of the users
#############################################################################
def print_user_table(jobs):
    # fill the users
    users = fill_users(jobs)
    # start totals as empty
    totals={}
    # create the preamble to the user table
    print "<h1>Users</h1>"
    print "<table class='torque table-autosort:0 table-stripeclass:alternate'>"

    # create the header to the summary table
    print "<thead><tr>"
    print "<th class=' table-sortable:default'"
    print "align='left'>User</th>"
    for state, color in JOB_STATES.items():
        print "<th class=' "
        print "table-sortable:numeric'><font color=%s>" % color
        print "%s</font></th>" % state
        totals[state]=0
    print "<th class=' "
    print "table-sortable:numeric'>All</th>"
    print "</tr></thead>"

    # create the rows of the user table
    total=0
    for user, atts in users.items():
        usertotal='0'
        if 'total' in atts.keys():
            usertotal=atts['total']
            total=total+usertotal
            print "<tr><td><a href=?user=%s&state=all>%s</a></td>" % \
                  (user,user)
            for state, color in JOB_STATES.items():
                print "<td><a href=?user=%s&state=%s>%d</a></td>" % \
                      (user,state,atts[state])
                totals[state]=totals[state]+atts[state]
            print "<td><a href=?user=%s&state=all>%s</a></td>" % \
                  (user,usertotal)
            print "</tr>"
    
    # create the footer of the user table
    print "<tfoot><tr><td><b><a href=?user=total>Total</a></b></td>"
    for state, color in JOB_STATES.items():
        print "<td><a href=?user=total&state=%s>%s</a></td>" % \
              (state,totals[state])
    print "<td><a href=?user=total&state=all>%s</a></td>" % (total)
    print "</tr></tfoot></table>"

#############################################################################
# print a table of the jobs
#############################################################################
def print_job_table(jobs):
#    ldin = ldap.open(LDAPSERVER)
    # grab url parameters
    form  = cgi.FieldStorage()
    user  = form.getvalue('user')
    state = form.getvalue('state')
    # make default behavior display all users and states
    if user == None:
        user = 'total'
    if state == None:
        state = 'all'
    # create the preamble to the job table
    print "<h1>Jobs</h1>"
    print "<table class='torque table-autosort:0 table-stripeclass:alternate'>"
    
    # create the header to the job table
    print "<thead><tr>"
    print "<th class=' table-sortable:numeric'"
    print "align='left'>Number</th>"
    print "<th class=' table-sortable:default'"
    print "align='left'>User</th>"
    print "<th class=' table-sortable:default'"
    print "align='left'>Status</th>"
    print "<th class=' table-sortable:default'"
    print "align='left'>Job Name</th>"
    print "<th class=' table-sortable:default'"
    print "align='left'>Mem</th>"
    print "<th class=' table-sortable:default'"
    print "align='left'>VMem</th>"
    print "<th class=' table-sortable:default'"
    print "align='left'>Run Time</th>"
    print "<th class=' table-sortable:default'"
    print "align='left'>Queue</th>"
    print "<th class=' table-sortable:default'"
    print "align='left'>Name</th>"
    print "<th class=' table-sortable:default'"
    print "align='left'>mail</th>"
    print "<th class=' table-sortable:default'"
    print "align='left'>telephone</th>"
    print "</tr></thead>"
    
    if user != 'total':
	lines="uid=%s,ou=people,dc=ptc,dc=spbu,dc=ru" % user
    	userinfo=ldin.search_s(lines, ldap.SCOPE_SUBTREE, "objectclass=*") 	
    	print "<td></td>" 
    	print "<td>%s</td>" % user
    	print "<td></td>"
    	print "<td></td>"
	print "<td></td>"
        print "<td></td>"
	print "<td></td>"
        print "<td></td>"
    	if 'cn' in userinfo[0][1]:
	    print "<td>%s</td>" % userinfo[0][1]['cn'][0]
    	else:
            print "<td></td>"
    	if 'mail' in userinfo[0][1]:
            print "<td>%s</td>" % userinfo[0][1]['mail'][0]
    	else:
            print "<td></td>"
    	if 'telephoneNumber' in userinfo[0][1]:
            print "<td>%s</td>" % userinfo[0][1]['telephoneNumber'][0]
    	else:
            print "<td></td>"
    	print "</tr>"


    # loop over the jobs and fill the rows of the table
    for name, atts in jobs.items():
        # accept the job if it meets the requested user and state
        if (user == atts['Job_Owner'][0].split('@')[0] \
            and (state == atts['job_state'][0] or state == 'all')) \
            or (user == 'total' and (state == atts['job_state'][0]
                                     or state == 'all')):
	    lines="uid=%s,ou=people,dc=ptc,dc=spbu,dc=ru" % atts['Job_Owner'][0].split('@')[0]
	    userinfo=ldin.search_s(lines, ldap.SCOPE_SUBTREE, "objectclass=*")
            # print the rows
            print "<td><a href=?job=%s>%s</a></td>" % \
                  (name,name.split('.')[0])
            print "<td>%s</td>" % atts['Job_Owner'][0].split('@')[0]
            print "<td><font color=\"%s\">%s</font></td>" % \
                  (JOB_STATES[atts['job_state'][0]],atts['job_state'][0])
            print "<td>%s</td>" % atts['Job_Name'][0]
            if 'resources_used' in atts:
                print "<td>%s</td>" % \
                      convert_to_gb(atts['resources_used']['mem'][0])
                print "<td>%s</td>" % \
                      convert_to_gb(atts['resources_used']['vmem'][0])
		print "<td>%s</td>" % atts['resources_used']['walltime'][0]
            else:
                print "<td></td>"
                print "<td></td>"
                print "<td></td>"
	    if 'queue' in atts:
                print "<td>%s</td>" % atts['queue'][0].split('-')[0]
	    else:
                print "<td></td>"
	    if 'cn' in userinfo[0][1]:
        	print "<td>%s</td>" % userinfo[0][1]['cn'][0]
	    else:
	        print "<td></td>"
	    if 'mail' in userinfo[0][1]:
	        print "<td>%s</td>" % userinfo[0][1]['mail'][0]
	    else:
                print "<td></td>"
	    if 'telephoneNumber' in userinfo[0][1]:
                print "<td>%s</td>" % userinfo[0][1]['telephoneNumber'][0]
	    else:
	        print "<td></td>"
	    print "</tr>"
#	else:
#	    lines="uid=%s,ou=people,dc=ptc,dc=spbu,dc=ru" % user
#            userinfo=ldin.search_s(lines, ldap.SCOPE_SUBTREE, "objectclass=*")
#            print "<td></td>"
#            print "<td>%s</td>" % user
#            print "<td></td>"
#            print "<td></td>"
#            print "<td></td>"
#            print "<td></td>"
#            print "<td></td>"
#            print "<td></td>"
#            if 'cn' in userinfo[0][1]:
#                print "<td>%s</td>" % userinfo[0][1]['cn'][0]
#            else:
#                print "<td></td>"
#            if 'mail' in userinfo[0][1]:
#                print "<td>%s</td>" % userinfo[0][1]['mail'][0]
#            else:
#                print "<td></td>"
#            if 'telephoneNumber' in userinfo[0][1]:
#                print "<td>%s</td>" % userinfo[0][1]['telephoneNumber'][0]
#            else:
#                print "<td></td>"
#            print "</tr>"
	    

    # create the footer to the job table
    print "</table>"

#############################################################################
# print the logs for a job
#############################################################################
def print_job_logs(job,jobs):
    textbox = "<textarea readonly=\"readonly\" rows=\"20\" cols=\"80\""
    if job in jobs:
        if 'exec_host' in jobs[job]:
            host = jobs[job]['exec_host'][0].split('/')[0]
            print "scp -o stricthostkeychecking=no -B %s@%s:%s/spool/%s* %s" % (SCP_USER,host,TORQUE_PATH,job,LOG_DIR)
            scp = "scp -o stricthostkeychecking=no -B %s@%s:%s/spool/%s* %s"\
                  % (SCP_USER,host,TORQUE_PATH,job,LOG_DIR)
            rm  = "rm %s/%s.OU %s/%s.ER" % (LOG_DIR,job,LOG_DIR,job)
            commands.getoutput(scp)

            # print the error file
            try:
                file = open('%s/%s.ER' % (LOG_DIR,job),'r')
            except IOError:
                text = "Error file not available."
            else:
                text = file.read()
            print "<h1>Error File</h1>"
            print "%s style=\"background-color: FF6666\">" % textbox
            print text
            print "</textarea>"

            # print the output file
            try:
                file = open('%s/%s.OU' % (LOG_DIR,job),'r')
            except IOError:
                text = "Output file not available."
            else:
                text = file.read()
            print "<br/><h1>Output File</h1>"
            print "%s style=\"background-color: lightgreen\">" % textbox
            print text
            print "</textarea>"
            commands.getoutput(rm)
        else:
            print "<h1>Log details not available.</h1>"
    
#############################################################################
# print the details for a job
#############################################################################
def print_job_detail(job,jobs):
    if job in jobs:
        # grab all relevant information (but check it's there first!)
        qtime = ""; stime = ""; ctime = ""; etime = ""; rtime = "";
        host = ""; server = ""; owner = "";queue = "";
        mem = ""; vmem = ""; ptime = ""; nodes = "";hostss = [];
        if 'qtime' in jobs[job]:
            qtime = time.ctime(float(jobs[job]['qtime'][0]))
        if 'start_time' in jobs[job]:
            stime = time.ctime(float(jobs[job]['start_time'][0]))
        if 'ctime' in jobs[job]:
            ctime = time.ctime(float(jobs[job]['ctime'][0]))
        if 'etime' in jobs[job]:
            etime = time.ctime(float(jobs[job]['etime'][0]))
        if 'exec_host' in jobs[job]:
            host = jobs[job]['exec_host'][0].split('/')[0]
	    hosts = jobs[job]['exec_host'][0].split('+')
#	    hostss = []
	    for hhh in hosts:
		hostss.append(hhh.split('/')[0])
		
		
        if 'server' in jobs[job]:
            server = jobs[job]['server'][0]
        if 'Job_Owner' in jobs[job]:
            owner = jobs[job]['Job_Owner'][0].split('@')[0]
        if 'Resource_List' in jobs[job]:
#            wtime = jobs[job]['Resource_List']['walltime'][0]
	     nodes = jobs[job]['Resource_List']['nodes'][0]
#	     if len(jobs[job]['Resource_List']['nodes'][0].split('=')) == 2:
#		cpu=jobs[job]['Resource_List']['nodes'][0].split('=')[1]
#	     else:
#		cpu=1
        if 'resources_used' in jobs[job]:
            mem   = convert_to_gb(jobs[job]['resources_used']['mem'][0])
            vmem  = convert_to_gb(jobs[job]['resources_used']['vmem'][0])
            ptime = jobs[job]['resources_used']['cput'][0]
            rtime = jobs[job]['resources_used']['walltime'][0]
#	    wtime = jobs[job]['resources_used']['walltime'][0]
	comment = ""
	if 'comment' in jobs[job]:
	    comment = jobs[job]['comment'][0]
	if 'queue' in jobs[job]:
	    queue = jobs[job]['queue'][0].split('-')[0]
	

        # create the preamble to the detail table
        print "<h1>Job Details for  %s: %s</h1>" % \
              (job,jobs[job]['Job_Name'][0])
        print "<table class='torque table-autostripe"
        print "table-stripeclass:alternate'>"

        # create the detail table
        print "<tr>"
        print "<td><b>Eligible Time:</b></td><td>%s</td>" % qtime
        print "<td><b>Owner:</b></td><td>%s</td>" % owner
        print "</tr><tr>"
        print "<td><b>Create Time:</b></td><td>%s</td>" % ctime
        print "<td><b>Server:</b></td><td>%s</td>" % server
        print "</tr><tr>"
        print "<td><b>Queue Time:</b></td><td>%s</td>" % etime
        print "<td><b>Queue :</b></td><td>%s</td>" % queue
        print "</tr><tr>"
        print "<td><b>Start Time:</b></td><td>%s</td>" % stime
        print "<td><b>nodes:</b></td><td>%s</td>" % nodes
        print "</tr><tr>"
        print "<td><b>CPU Time:</b></td><td>%s</td>" % ptime
        print "<td><b>Memory:</b></td><td>%s</td>" % mem
        print "</tr><tr>"
        print "<td><b>Run Time:</b></td><td>%s</td>" % rtime
        print "<td><b>Virtual Memory:</b></td><td>%s</td>" % vmem
        print "</tr><tr>"
	print "<td><b>Comment :</b></td><td>%s</td>" % comment
        print "<td><b>hosts :</b></td><td>%s</td>" % hostss
        print "</tr>"

        print "</table>"
        
    else:
        print "<h1>Job details not available.</h1>"

#############################################################################
# initialize PBS and print header (and css template)
#############################################################################
def print_header():
    # try connecting to the PBS server
    print "Content-Type: text/html"

    try:
        pbs  = PBSQuery(SERVER)
        jobs = pbs.getjobs()
#	ldin = ldap.open("192.168.0.90")
    except PBSError, error:
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
       <title>Torque Monitor</title> 
       <script src="%s/table.js" type="text/javascript"></script>
    </head>
    ''' % JS_PATH
    return jobs

#############################################################################
# main program
#############################################################################
# print the header
jobs  = print_header()

# print the main division
print "<div id=\"main\">"
# determine if specific job requested
job = cgi.FieldStorage().getvalue('job')
if job == None:
    # print job table if not
    print_job_table(jobs)
else:
    # print job details and logs if requested
    print_job_detail(job,jobs)
    print "<br/>"
    print_job_logs(job,jobs)
print "</div>"

# print the sidebar division
print "<div id=\"sidebar\">"
print "<a href='/torque'>"
print "<img src=\"%s\" height=\"146\" width=\"100\" align=\"middle\">" % LOGO
print "</a>"
print "<h1>%s</h1>" % strftime("%Y-%m-%d %H:%M:%S")
print "<br/>"
# print user table
print_user_table(jobs)
print "</div>"
