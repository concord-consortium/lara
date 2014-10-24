# This fixes a strange problem on our EC2 servers where this constant isn't
# defined. If you can please fix our EC2 server and then remove this.
OpenSSL::SSL::VERIFY_PEER=1
