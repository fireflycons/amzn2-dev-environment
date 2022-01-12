# Connect to your new environment

Note that you *can* connect vnc viewer directly to the instance on port 5901 without doing the following, but the traffic is not encrypted! Use that method only to verify the VNC connection works.

1. Run PuTTY.
1. Enter the hostname (if you set up Route53 DNS) or public IP of the instance if you did not.
![hostname](./connect2.gif)
1. Select **Connection/Data** from the tree menu on the left and enter the Linux username you provided to packer.
![username](./connect3.gif)
1. Expand **Connection/SSH** in the tree menu, click on **Auth** then browse to the `.ppk` file you [created here](./keypair.md).
![privatekey](./connect4.gif)
1. Click on **Tunnels** and configure the tunnel for VNC.&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
![privatekey](./connect5.gif)
1. Press **Open** button at the bottom. This should establish a terminal session with the instance, and at the same time set up the tunnel for VNC
1. Run the Tiger VNC client. Enter `localhost:5901` in the **VNC Server** field, then press connect
![tiger](./connect7.gif)
1. The password box will pop up. Enter the VNC password you provided to packer. It will warn you that it's not secured, but it doesn't know it's being routed via an SSH tunnel.
1. If you're using a Route53 DNS record, and entered the hostname in step 3 above, then you should save the PuTTY session for reuse.

* [Next](./park.md) - Parking/Reusing your instance
* [Back](./provision.md) - Provision Infrastructure