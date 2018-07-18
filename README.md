# gcp_terraform_gke_example
Example code for using Terraform to deploy GKE with sample Kubernetes deployments

1. Set up Terraform to deploy GKE. First you’ll need to [install Terraform][1] as well as set up the [gcloud SDK][2] on the machine you’ll run these on, or you can run these from your Cloud console.
1. You’ll need to edit the terraform/provider.tf file to update the bucket on line 10 to a GCS bucket your GCP user has access to. Simply create the bucket and enter the name in provider.tf. This is a simple locking mechanism to make sure multiple people aren’t running the Terraform job at the same time.
   * `terraform/provider.tf`
1. You can see in terraform/setup.tf that it declares the GKE cluster as well as some properties about the deployments. This will include which zones you’ll be using, the size of the machines, and the autoscaling properties.
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
