# azure-cyclecloud-terraform

This repo can be used to quickly provision and destroy an [Azure CycleCloud](https://docs.microsoft.com/en-us/azure/cyclecloud/overview?view=cyclecloud-8) instance. It will provision all the underlying resources to host the Azure CycleCloud web application.

The output of the terraform configuration will be the URL for your Azure CycleCloud. You will need to [configure the rest of CycleCloud using the web interface](https://docs.microsoft.com/en-us/azure/cyclecloud/qs-install-marketplace?view=cyclecloud-8#log-into-the-cyclecloud-application-server).

Quickest and easisiest way to deploy this repo is to clone in [Azure Cloud Shell](https://docs.microsoft.com/en-us/azure/cloud-shell/overview) as it already has Terrafrom installed.

Take a look at the [main.auto.tfvars](main.auto.tfvars) file and adjust the values accordingly (based on your Azure environment).

Run `terraform init` to initialize.

Run `terraform apply` to provision infrastructure.

When you are done, run `terraform destroy` to delete infrastructure.