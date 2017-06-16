# -*- coding: utf-8 -*-

import re
import requests
import platform
import subprocess


def create_tmp_file(content):
    """
    not used anymore
    """
    with open('tmp', 'w+') as inputData:
        inputData.write(content)

def convert_source(source):
    """
    calls SAXON as subprocess and fetches console output
    """
    process = 'java -jar saxon/saxon9he.jar -xsl:xslt/cs_nlp.xsl -s:' + source
    #subprocess.check_output(['java', '-jar', 'saxon9he.jar', '-xsl:cs_nlp.xsl', '-s:tmp', '-o:tmp'], shell=True)
    return subprocess.check_output(process, shell=True)

def post_cleanup(data):
    """
    cleanup the converted coptic scriptorium data
    """
    transform = re.sub('\)@@\(', ' ', data)
    transform = re.sub('\)@[\s]?', ' ', transform)
    transform = re.sub('[\s]?@\(', ' ', transform)
    transform = re.sub('([\s]?·[\s]?)|([\s]?·[\s]?)', ' ‧ ', transform)
    return transform

def construct_url(args, params):
    """
    constructs the source URL pushed to Saxon
    """
    base = params['base'] 
    for k in args:
        if params.get(k):
            params[k] = [args[k]] 
    #print params
    
    # system check since saxons url-source interface don't handle this well
    print platform.system()
    if platform.system() == "Windows":
        return '"' + base + '?' + '&'.join( [ "%s=%s" % (key, value[0]) for (key, value) in params.items() if key != 'base' ] ) + '"'
    else:
        return "'" + base + '?' + '&'.join( [ "%s=%s" % (key, value[0]) for (key, value) in params.items() if key != 'base' ] ) + "'"

def conversion(args, actual_params):
    """
    the simple conversion workflow binding it all together
    """
    url = construct_url(args, actual_params)
    #print url
    data = convert_source(url)
    data = post_cleanup(data)
    return data

if __name__ == '__main__':
    pass