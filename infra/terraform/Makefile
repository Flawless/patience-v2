.PHONY: auth

# Extract Kubernetes credentials from current context
auth:
	@echo "# Run this to set environment variables:"
	@echo "export TF_VAR_k8s_cluster_ca_certificate=\"$$(kubectl config view --raw | grep certificate-authority-data | head -n1 | awk '{print $$2}')\""
	@echo "export TF_VAR_k8s_client_certificate=\"$$(kubectl config view --raw | grep client-certificate-data | head -n1 | awk '{print $$2}')\""
	@echo "export TF_VAR_k8s_client_key=\"$$(kubectl config view --raw | grep client-key-data | head -n1 | awk '{print $$2}')\""
	@echo "\n# Or run this command:"
	@echo "source <(make -s auth-source)"

# Generate source-able script
auth-source:
	@echo "export TF_VAR_k8s_cluster_ca_certificate=\"$$(kubectl config view --raw | grep certificate-authority-data | head -n1 | awk '{print $$2}')\""
	@echo "export TF_VAR_k8s_client_certificate=\"$$(kubectl config view --raw | grep client-certificate-data | head -n1 | awk '{print $$2}')\""
	@echo "export TF_VAR_k8s_client_key=\"$$(kubectl config view --raw | grep client-key-data | head -n1 | awk '{print $$2}')\""
