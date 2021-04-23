import requests
import sys
import os
import base64

#Disable security warnings
requests.packages.urllib3.disable_warnings()

#Get folder name from imput
folder=sys.argv[1]

#Get vsphere creds from env
server=os.environ["VSPHERE_SERVER"]
user=os.environ["VSPHERE_USER"]
password=os.environ["VSPHERE_PASSWORD"]

#Get session
url = "https://"+server+"/rest/com/vmware/cis/session"
encoded_key=base64.b64encode(user+":"+password)
headers = {'content-type': 'application/json', 'Accept-Charset': 'UTF-8', 'vmware-use-header-authn': 'string', 'Authorization': 'Basic '+encoded_key}
r = requests.post(url, headers=headers, verify=False)
session=r.json()['value']

#Get folder id
folder_url="https://"+server+"/rest/vcenter/folder?filter.names="+folder
headers = {'content-type': 'application/json', 'Accept-Charset': 'UTF-8', 'vmware-api-session-id': session}
r = requests.get(folder_url, headers=headers, verify=False)
folderid=r.json()['value'][0]['folder']
