#!/usr/bin/env python

"""
Check apache status by mode_status, insert config below into httpd.conf:
ExtendedStatus On
<Location /apache-status>
  SetHandler server-status
  Order deny,allow
  Allow from all
</Location>
"""

import re, sys, getopt, urllib

def main():
  try:
    opts, args = getopt.getopt(sys.argv[1:], "h", ["help", "url="])
  except getopt.GetoptError, err:
    # print help information and exit:
    print "UNKNOWN - " + str(err) 
    sys.exit(2)
  url = None
  for o, a in opts:
    if o in ("-h", "--help"):
      usage(),
      sys.exit(0)
    elif "--url" in o:
      url = a 
    else:
      print "UNKNOWN - error argument:" + o
      sys.exit(2)
  if url is None:
      print "UNKNOWN - could not parse arguments" 
      usage()
      sys.exit(2)
  data = get_data(url)
  summary = data[0]
  metrics = data[1]
  print "OK -", summary, "|", ",".join([name + "=" + val for (name, val) in metrics]) 

def usage():
  print "Usage: check_apache_status --url=url"

def get_data(url):
  data = urllib.urlopen(url)
  data = data.read()
  lines = data.split("\n")
  data = []
  summary = ""
  for line in lines: 
    if "Total Accesses:" in line:
      totalAcc = line.strip(" Total Accesses:")        
      data.append(("total_accesses", totalAcc))
    elif "Total kBytes:" in line:
      totalKB = line.strip(" Total kBytes:")
      totalB = int(totalKB) * 1024
      data.append(("total_bytes", str(totalB)))
    elif "CPULoad:" in line:
      cpuload = line.strip(" CPULoad:")
      data.append(("cpuload", cpuload))
    elif "Uptime:" in line:
      uptime = line.strip(" Uptime:")
      data.append(("uptime", uptime))
    elif "ReqPerSec:" in line:
      reqpersec = line.strip(" ReqPerSec:")
      summary += "request per second = " + reqpersec
      data.append(("req_per_sec", reqpersec))
    elif "BytesPerSec:" in line:
      bytespersec = line.strip(" BytesPerSec:")
      data.append(("bytes_per_sec", bytespersec))
    elif "BytesPerReq:" in line:
      bytesperreq = line.strip(" BytesPerReq:")
      data.append(("bytes_per_req", bytesperreq))
    elif "BusyWorkers:" in line:
      busyworkers = line.strip(" BusyWorkers:")
      data.append(("busy_workers", busyworkers))
    elif "IdleWorkers:" in line:
      idleworkers = line.strip(" IdleWorkers:")
      data.append(("idle_workers", idleworkers))
    elif "Scoreboard:" in line:
      pass
    else:
      pass
  return (summary, data)

if __name__ == "__main__":
  main()
