exec {"/usr/bin/touch /tmp/aa.txt":
	creates => ["/tmp/a.txt", "/tmp/b.txt", "/tmp/hsun"]
}