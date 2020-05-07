# Terraform SSH tunnel
Proof of Concept to quickly create/destroy an AWS EC2 ssh-tunnel by leveraging terraform. Also a unit test in Go.
## Execute:
run `$ bash runit.sh` or similar. Then follow the prompt.
## Requirements:
for normal runthrough
 - a default vpc and access to create/terminate ec2 instance
 - terraform
for test script
 -  set `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables.
 -  cd into the test directory then `go get` dependencies and `go test -v  -run TestTerrasshDeploy`

## Todo
 - make a custom vpc so no issues with default vpcs
 - create/test more regions
 - make a host user in userdata so no issue with ec2-user vs ubuntu or any other usernames
