# Multiple Project Pipeline Example on OCP

This project demonstrates how to create a multi-project pipeline based on Redhat's [DevOps with Openshift book](https://www.oreilly.com/library/view/devops-with-openshift/9781491975954/ch04.html). The application used is a [sample PHP application](https://github.com/HCL-Cloud-Native-Labs/cotd).

Why do we want a multi-project pipeline?

"_-- In a software delivery lifecycle we want to separate out the different pipeline activities such as development, testing, and delivery into production. Within a single OpenShift PaaS cluster we can map these activities to projects. Different collaborating users and groups can access these different projects based on the role-based access control provided by the platform._"

The diagram below depicts the general form of our application flow through the various projects (development to testing to production) as well as the access requirements necessary between the projects to allow this flow to occur when using a build, tag, promote strategy.
![multi-project-pipeline.png](multi-project-pipeline.png)

## Prerequisites 

* Access to the OpenShift cluster
* [Jenkins](https://github.com/HCL-Cloud-Native-Labs/labs-ci-cd)
* [Projects created with associated Role-Based Access Control added on](https://github.com/HCL-Cloud-Native-Labs/labs-ci-cd)

## Basic Usage

### Deploy pipeline definition and sample applications
1. Clone this repository.
2. Log on to an OpenShift server `oc login -u <user> https://<server>:<port>/`
3. Set project to `labs-ci-cd`:
```bash
$ oc project labs-ci-cd
```
4. Create pipeline itself using the following command
```bash
$ oc create -n labs-ci-cd -f pipeline.yaml
```
4. Within `labs-dev` project, invoke new-app using the builder image and Git repository URL—remember to replace this with your Git repo. 
```bash
$ oc project labs-dev
$ oc new-app --name=cotd-app openshift/php:5.6~https://github.com/HCL-Cloud-Native-Labs/cotd.git#master
```
5. Create a route, replacing the hostname with something appropriate for your environment:
```bash
$ ansible-playbook site.yml
```

## Uninstalling

1. Delete the projects using the following commands:
```bash
$ oc delete project labs-ci-cd
$ oc delete project labs-dev
$ oc delete project labs-test
$ oc delete project labs-prod
```
2. Delete persistent volumes using the following command:
```bash
$ oc delete -f persistent-volume.yaml
```

