package test

import (
	"encoding/json"
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

type Subnet struct {
	AddressPrefixes []string          `json:"address_prefixes"`
	Tags            map[string]string `json:"tags"`
}

type Vnet struct {
	Location          string            `json:"location"`
	ResourceGroupName string            `json:"resource_group_name"`
	AddressSpace      []string          `json:"address_space"`
	Tags              map[string]string `json:"tags"`
	Subnets           map[string]Subnet `json:"subnets"`
}

func loadVnetsConfigFromTFVars(filePath string) map[string]Vnet {
	bytes, err := os.ReadFile(filePath)
	if err != nil {
		panic("Failed to read tfvars file: " + err.Error())
	}

	var tfvars map[string]map[string]Vnet
	if err := json.Unmarshal(bytes, &tfvars); err != nil {
		panic("Failed to parse tfvars JSON: " + err.Error())
	}
	return tfvars["vnets_config"]
}

func TestNetworkTagsSummaryDynamic(t *testing.T) {
	t.Parallel()

	// Load expected input from tfvars
	expectedVnets := loadVnetsConfigFromTFVars("C:/Official/Ravi.Sivaji/DevSecOps/POC/Practise/AzureNetworks/terraform.tfvars.json")

	// Terraform options
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "C:/Official/Ravi.Sivaji/DevSecOps/POC/Practise/AzureNetworks",
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Output from Terraform
	networkTagsSummary := terraform.OutputMapOfObjects(t, terraformOptions, "network_tags_summary")

	// Extract actual tags
	actualVnetTags := networkTagsSummary["vnet_tags"].(map[string]interface{})
	actualSubnetTags := networkTagsSummary["subnet_tags"].(map[string]interface{})

	// Validate VNet tags
	for vnetName, vnetConfig := range expectedVnets {
		expectedTags := vnetConfig.Tags
		actualTags := actualVnetTags[vnetName].(map[string]interface{})

		for key, expectedVal := range expectedTags {
			assert.Equal(t, expectedVal, actualTags[key], "VNet tag mismatch for %s: %s", vnetName, key)
		}
	}

	// Validate Subnet tags
	for vnetName, vnetConfig := range expectedVnets {
		expectedSubnets := vnetConfig.Subnets
		actualSubnets := actualSubnetTags[vnetName].(map[string]interface{})

		for subnetName, subnet := range expectedSubnets {
			expectedTags := subnet.Tags
			actualTags := actualSubnets[subnetName].(map[string]interface{})

			for key, expectedVal := range expectedTags {
				assert.Equal(t, expectedVal, actualTags[key], "Subnet tag mismatch for %s/%s: %s", vnetName, subnetName, key)
			}
		}
	}
}
