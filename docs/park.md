# Parking/Reusing your instance

To prevent running up an AWS bill, you should stop the instance when you are not using it. When you restart it, AWS will assign it a new public IP address.

If you enabled the auto-stop feature by providing a notification email to terraform, then the instance will auto-stop after 30 min of inactivity, defined as CPU average < 3% for 30 one minute samples.

If you created a DNS entry in Route53 for the instance, then bringing it back up requires the following steps

1. Start the instance
2. Apply the terraform configuration again. Terraform will notice the change in IP and will update the Route53 record accordingly. **Note that if you rebuilt the AMI since the last poweroff, Terraform will redeploy the instance and you will lose anything that's on it.**. In this case you can either
    1. Start the instance, connect directly to the new IP address and SCP your files down
    1. Modify `resources.tf` and set the old AMI ID directly to bring up the previous version with DNS entry
    1. Delete the newer AMI and rebuild it later.

If you did not create a DNS record, you'll have to redo the PuTTY configuration with the new IP.

* [Back](./connect.md) - Connect to your new environment