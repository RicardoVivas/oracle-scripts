$listener_suffix = "true"

case $listener_suffix {
	"" : {$listener_name = "listner"}
	default: {
	  $listener_name = "listener.$hostname"
	}
}
notify {"The listener is $listener_name":}
