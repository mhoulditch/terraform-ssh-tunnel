package test
import (
 "os"
 "os/user"
 "log"
 "path/filepath"
 "time"
 "testing"
 "fmt"
 "github.com/gruntwork-io/terratest/modules/terraform"
 // use assert to compare a value you get back from ssh?
 ssh "github.com/metrue/go-ssh-client"
 )

func TestTerrasshDeploy(t *testing.T) {
	terraformOptions := &terraform.Options{
	 TerraformDir: "../",
	}

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)
	host := terraform.Output(t, terraformOptions, "instance_ip_addr")
	script := `echo -n 'Successfully ran ssh script on remote server..'`
	fmt.Printf("waiting 3 minutes for the server to initiate...")
	usr, _ := user.Current()
	dir := usr.HomeDir
	path := "~/.ssh/terrassh"
	keypath := filepath.Join(dir, path[2:])
	fmt.Println(keypath)
	time.Sleep(3 * time.Minute)
	err := ssh.New(host).
		 WithUser("ubuntu"). // TODO get this some other way
		 WithKey(keypath).
		 RunCommand(script, ssh.CommandOptions{
		  Stdout: os.Stdout,
		  Stderr: os.Stderr,
                  Stdin:  os.Stdin,
	 })
  if err != nil {
    log.Fatal(err)
  }
}
