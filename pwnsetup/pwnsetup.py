#!/usr/bin/python3
import sys
import subprocess
import argparse
import os
from string import Template
NAME = "Evangelospro"

parser = argparse.ArgumentParser(description='Bin/Rev setup script')
parser.add_argument("-ip", "--ip-address", type=str, required=False, help="IP Address (remote)")
parser.add_argument("-p", "--port", required=False, type=str, help="Port (remote)")
parser.add_argument("-b", "--binary", type=str, required=True, help="Binary file (Local)")
parser.add_argument("--patch", type=bool, required=False, help="Patch with patchelf(libc)")

args = vars(parser.parse_args())

host = args.get('ip_address', None)
port = args.get('port', None)

binary = args['binary']
patch = args.get('patch', None)
subprocess.call(['chmod', '+x', binary])
path = input("PWN solution filename(Default is 'autopwn_(binary_name).py': ")
if path == "" or path == " ":
	path = f"autopwn_{binary}.py"

params = {
	"NAME": NAME,
	"host": host,
	"port": port,
	"binary": binary,
	"patch": patch
}

template_file = os.path.dirname(__file__) + "/" + "template"
print(template_file)
with open(template_file, 'r') as f:
	src = Template(f.read())
	result = src.substitute(params)
	with open(path, 'w') as f:
		f.write(result)
		print(f"pwnsetup.py: wrote {path}")