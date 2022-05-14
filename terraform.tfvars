label = "example-lke-cluster"
k8s_version = "1.23"
region = "us-east"
pools = [
    {
        type: "g6-standard-1"
        count: 3
    }
]