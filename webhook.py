from bottle import route, run, template

gitdict = {'po2go':{'https://github.com/cadamswaite/po2go.git:master':'https://github.com/cadamswaite/po2go.git:gh-pages'}}

# Handle http requests to the root address
@route('/')
def index():
 return 'Go away.'
 
@route('/build/<name>')
def greet(name):
 if name in gitdict:
  return 'Building ' + name
 else:
  return name + 'not found in gitdict'
 
run(host='0.0.0.0', port=80)
