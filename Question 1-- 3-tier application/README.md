**Strategy for 3-tier architecture in GCP.**
There will below layer/tier will be created by terraform files.

Web, App, DB
Web-- apache httpd
App-- Hello world Python application
DB-- GCP cloud SQL instance

I wil create 2 project in 2 different GCP region
A service account will be created with proper roles in each project. we will download a JSON key of service account.
create a VPC in each project.
VPC peering will be used connect 2 vpc in different region.
create a Cloud SQL in one VPC in one project in private network
Create a Google Kubernetes engine in another VPC in other project. where web layer will have public IP (Load balaencer IP). App will have private IP in internal kubernetes subnet. 
create a deployement of hello world python application using public docker image
we will put the Load balencer IP of Cloud run deployment. In firewall rule we will manage so that no other IP can hit Cloud SQL.

Enable the API
compute.googleapis.com
container.googleapis.com

Another project
compute.googleapis.com
sqladmin.googleapis.com

main.tf is main file for terraform to apply.
here i have used custom module

provider.tf
i hv specified google provider with project detail, region, location of key.json file.

vpc.tf
here i am creating vpc & custom mode subnet.
google_compute_network_peering modeue is used to VPC network peering

db_gcp_sql.tf
we will configure Cloud SQL instance

Run below command

terraform apply
