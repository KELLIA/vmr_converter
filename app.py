# -*- coding: utf-8 -*-

import json
import requests
import urllib
import converter


from flask import Flask, request, render_template, jsonify
from flask import make_response
from flask_cors import CORS
app = Flask(__name__, static_url_path='/static')
CORS(app)

#source = "'http://coptot.manuscriptroom.com/community/vmr/api/transcript/get/?docID=690003&pageID=0-400&joinParts=true&format=teiraw'" 

# index is used to define the data-providers. this dict is also used for ducumentation
provider_index = { 'vmr' : 
                    {
                        'base' : 'http://coptot.manuscriptroom.com/community/vmr/api/transcript/get/',
                        'docID' : ['690003', 'The vmr Document ID. This is mandatory!'],
                        'pageID' : ['ALL', 'The vmr Document Page-ID'],
                        'joinParts' : ['true', 'Actually i do not know what this is for'],
                        'format' : ['teiraw', 'The provided format from vmr']    
                    }}

@app.route("/")
def home():
    """
    Home space giving some information
    """
    app_title = 'home'
    return render_template('api.html', title=app_title)

@app.route("/provider/")
def provider():
    """
    Provider-sapace giving the defined parameters for GET or POST-Requests. Post is not working right now
    """
    app_title = 'providers'
    return render_template('provider.html', title=app_title, provider=provider_index)

@app.route("/converter/", methods=['POST'])
def post_converter():
    doc = "POST is not working"
    resp = make_response( doc )
    return resp

@app.route("/converter/<provider>/", methods=['GET'])
def get_converter(provider):

    # Is provider defined? if not just quit!
    if not provider_index.get(provider):
        resp = make_response( provider + ' is unknown to converter' )
        #resp.headers['Content-Type'] = "application/html"
        return resp
    
    args = request.args.to_dict()
    actual_params = provider_index[provider]

    # respond the conversion data
    resp = make_response( converter.conversion(args, actual_params) )
    resp.headers['Content-Type'] = "application/xml"
    return resp
    
    


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)