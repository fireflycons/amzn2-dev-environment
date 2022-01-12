# Parking/Reusing your instance

To prevent running up an AWS bill, you should stop the instance when you are not using it. When you restart it, AWS will assign it a new public IP address.

If you created a DNS entry in Route53 for the instance, then bringing it back up requires the following steps

1. Start the instance
2. Apply the terraform configuration again. Terraform will notice the change in IP and will update the Route53 record accordingly.

If you did not create a DNS record, you'll have to redo the PuTTY configuration with the new IP.

