#!/usr/bin/env python

"""
check_http
TODO: how to get content-length when ('transfer-encoding', 'chunked')?
"""
import sys, getopt, time, httplib, socket

def run(args):
    host = args['host']
    port = args['port']
    url = args['url']
    if url == '':
      url = '/'

    conn = s = None
    try:
      #check tcp socket first
      s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
      s.settimeout(5)
      s.connect((host, int(port)))

      #check http
      start = time.time()
      conn = httplib.HTTPConnection(host, int(port))
      conn.request("GET", url)
      resp = conn.getresponse()
      status = resp.status
      reason = resp.reason
      length = resp.getheader('content-length', 0)
      if length == 0:
        data = resp.read()
        length = len(data)
      elapsed_time = time.time() - start
      summary = "status = %s %s, size = %s(byte), response time = %.3f(s)" % (status, reason, length, elapsed_time)
      metrics = "time=%.3fms,length=%s" % (1000*elapsed_time, length)
      if status >= 500:
        print "CRITICAL -", summary, "|", metrics
      elif status >= 400:
        print "WARNING -", summary, "|", metrics
      else:
        print "OK -", summary, "|", metrics
    except socket.error, msg:
      print "CRITICAL -", msg
    except:
      print "CRITICAL -", sys.exc_info()[0]
    if s is not None:
      s.close()
    if conn is not None:
      conn.close()

def usage():
    print "Usage: check_http -h --host=host --port=port --url=url"

if __name__ == "__main__":
    try:
        opts, args = getopt.getopt(sys.argv[1:], "h", ["help", "host=", "port=", "url="])
    except getopt.GetoptError, err:
    # print help information and exit:
        print "UNKNOWN -", str(err)
        sys.exit(2)
    cmd_args = {} 
    for o, a in opts:
      if o in ("-h", "--help"):
        usage(),
        sys.exit(0)
      elif o in ("--host"):
        cmd_args['host'] = a
      elif o in ("--port"):
        cmd_args['port'] = a
      elif o in ("--url"):
        cmd_args['url'] = a
      else:
        print "UNKNOWN - error argument:" + o
        usage()
        sys.exit(2)
    if not ('host'in cmd_args and 'port' in cmd_args and 'url' in cmd_args):
      print "UNKNOWN - invalid arguments"
      usage()
      sys.exit(2)
    try:
      run(cmd_args)
    except:
      print "UNKNOWN -", sys.exc_info()[0]
      sys.exit(2)
