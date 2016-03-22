#!/usr/bin/env python
import xmlrpclib
import pprint

def inspect_cobbler(host, user, password):
	server = xmlrpclib.Server("http://%s/cobbler_api" % host)
	token = None
	if user and password:
		token = server.login("username","password")

	INFORMATION = {
		"DISTROS" : server.get_distros(),
		"PROFILES": server.get_profiles(),
		"SYSTEMS" : server.get_systems(),
		"IMAGES"  : server.get_images(),
		"REPOS"   : server.get_repos()
	}

	pp = pprint.PrettyPrinter(indent=4)

	for name, output in INFORMATION.iteritems():
		print name
		pp.pprint(output)



def main(argv=None):
    import sys
    from argparse import ArgumentParser, FileType

    argv = argv or sys.argv

    parser = ArgumentParser(description='Inspect a Cobbler Environment')
    parser.add_argument('cobbler_host', help='Cobbler target Host',
                        nargs='?', default='127.0.0.1')
    parser.add_argument('--cobbler-user', '-u', help='Username for Target Cobbler',
                        nargs='?')
    parser.add_argument('--cobbler-password', '-p', help='Password for Target Cobbler',
                        nargs='?')
    args = parser.parse_args(argv[1:])

    inspect_cobbler(args.cobbler_host, args.cobbler_user, args.cobbler_password)


if __name__ == '__main__':
    main()