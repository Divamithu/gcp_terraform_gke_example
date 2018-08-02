# gcp_terraform_gke_example
Example code for using Terraform to deploy GKE with sample Kubernetes deployments

## Deploy a GKE Cluster

### Initial Setup

1. If this is a new GCP project, make sure to enable the [Google Kubernetes Engine API][5]
1. Create a Service Account with the following permissions:
	* Compute Viewer
	* Kubernetes Engine Admin
	* Service Account User
	* Storage Object Admin
1. Select option to create private JSON key for Service Account (it will be download onto your device)
1. Create a [new GCS bucket][6]
1. Create a Debian GCE instance and set the Service Account as the service account you created previously. Once the instance has started, connect to it through SSH

### Inside the GCE Instance Shell

1. [Install Terraform][1]
1. Once you have verified the install, clone this repo into the VM and `cd` into it
1. Upload the Service Account private key we created earlier to the **terraform/** directory
	* details on how to [transfer a file to an instance][7]
1. You’ll need make the following edits to **terraform/provider.tf**:
	* Add your project id to line 1 -- it should like something like:
 	
 		`variable "project" { default = "<YOUR-PROJECT-ID>"}`
	* Reference your private key file: (in this example it's called **credentials.json**)
		
		```
		provider "google" {
	  		credentials = "${file("credentials.json")}"
	  		project     = "${var.project}"
	  		region      = "us-central1"
		}
		```
	* Update the bucket name to the name of the GCS bucket we created earlier (your Service Account should have access to this bucket through the Storage Object Admin role). This enables a simple locking mechanism to make sure multiple people aren’t running the Terraform job at the same time.
	
		`bucket  = "<SHARED_BUCKET_NAME>"`
1. You can see in **terraform/setup.tf** that it declares the GKE cluster as well as some properties about the deployments. This will include which zones you’ll be using, the size of the machines, and the autoscaling properties. To run terraform, go to the terraform directory and run:
   * `sudo terraform init`
   * `sudo terraform apply`

## Add Your Containers to Google Container Registry (GCR)
1. Using [this tutorial][3] you can see how to quickly get your containers into Google Container Registry (GCR), which can act as a private repo for your containers. This sample code should give an example of two very simple services.
   * `gcloud auth configure-docker` (you may need to authorize docker)
   * `export PROJECT="<PROJECT>"` (replace <PROJECT> with your project id name)
   * `docker build -t endpoint1 deployments/endpoint1`
   * `docker build -t endpoint2 deployments/endpoint2`
   * `docker tag endpoint1 gcr.io/$PROJECT/endpoint1:v1`
   * `docker tag endpoint2 gcr.io/$PROJECT/endpoint2:v1`
   * `docker push gcr.io/$PROJECT/endpoint1:v1`
   * `docker push gcr.io/$PROJECT/endpoint2:v1`
1. Once the containers have been pushed to GCR, update the code in the sample deployment folders to point to the new gcr.io links in both deployment.yaml files on line 20.
   * deployments/endpoint1/deployment.yaml
   * deployments/endpoint2/deployment.yaml

## Deploy Services to Kubernetes
1. Similar to the instructions in [this tutorial][4], deploy the two services to Kubernetes and then apply the load balancer.
   * `gcloud container clusters get-credentials prod-main --zone=us-central1-a` (You may need to run this for kubectl to grab your latest deployment)
   * `kubectl apply -f deployments/endpoint1/deployment.yaml`
   * `kubectl apply -f deployments/endpoint2/deployment.yaml`
   * `kubectl apply -f deployments/fanout-ingress.yaml`
1. This will set up two sets of microservices and can easily be extended to deploy multiple sets individually. The ingress will create a loadbalancer and you can see the paths for each service in the fanout-ingress.yaml file. Note that it will take some time for the IP address on the load balancer to start responding to requests but you can test with the IP and IP/v2/ to see the different deployments

[1]: https://www.terraform.io/intro/getting-started/install.html
[2]: https://cloud.google.com/sdk/install
[3]: https://cloud.google.com/container-registry/docs/quickstart
[4]: https://cloud.google.com/kubernetes-engine/docs/tutorials/http-balancer
[5]: https://support.google.com/cloud/answer/6158841?hl=en
[6]: https://cloud.google.com/storage/docs/creating-buckets
[7]: https://cloud.google.com/compute/docs/instances/transfer-files
