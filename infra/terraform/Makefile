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

auth-kubeconfig:
	@# Extract credentials
	$(eval CA_CERT := $(shell kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[].cluster.certificate-authority-data}'))
	$(eval CLIENT_CERT := $(shell kubectl config view --raw --minify --flatten -o jsonpath='{.users[].user.client-certificate-data}'))
	$(eval CLIENT_KEY := $(shell kubectl config view --raw --minify --flatten -o jsonpath='{.users[].user.client-key-data}'))
	$(eval TOKEN := $(shell kubectl create token admin-user -n kube-system 2>/dev/null || echo ''))
	$(eval HOST := https://kube.aidbox.dev.last-try.org:6443)
	@# Generate kubeconfig.yaml based on available credentials
	@echo "Generating temporary kubeconfig.yaml..."
	@echo "apiVersion: v1" > kubeconfig.yaml
	@echo "clusters:" >> kubeconfig.yaml
	@echo "- cluster:" >> kubeconfig.yaml
	@echo "    server: $(HOST)" >> kubeconfig.yaml
	@echo "    certificate-authority-data: $(CA_CERT)" >> kubeconfig.yaml
	@echo "  name: my-cluster" >> kubeconfig.yaml
	@echo "contexts:" >> kubeconfig.yaml
	@echo "- context:" >> kubeconfig.yaml
	@echo "    cluster: my-cluster" >> kubeconfig.yaml
	@echo "    user: admin-user" >> kubeconfig.yaml
	@echo "  name: my-context" >> kubeconfig.yaml
	@echo "current-context: my-context" >> kubeconfig.yaml
	@echo "users:" >> kubeconfig.yaml
	@echo "- name: admin-user" >> kubeconfig.yaml
	@echo "  user:" >> kubeconfig.yaml
	@if [ -n "$(TOKEN)" ]; then \
		echo "    token: $(TOKEN)" >> kubeconfig.yaml; \
	elif [ -n "$(CLIENT_CERT)" ] && [ -n "$(CLIENT_KEY)" ]; then \
		echo "    client-certificate-data: $(CLIENT_CERT)" >> kubeconfig.yaml; \
		echo "    client-key-data: $(CLIENT_KEY)" >> kubeconfig.yaml; \
	else \
		echo "Error: No token or client certificate/key found" >&2; exit 1; \
	fi
	@echo "Temporary kubeconfig generated at ./kubeconfig.yaml"
