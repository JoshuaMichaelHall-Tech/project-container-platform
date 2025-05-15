package container.security.financial

# Financial services specific policy rules

# Rule to enforce non-root containers for PCI compliance
deny[msg] {
    input.config.user == "root"
    msg = "Running as root user is prohibited for financial services. Use a non-root user in your Dockerfile."
}

# Rule to enforce secure environment variables
deny[msg] {
    env := input.config.env[_]
    contains(lower(env), "password")
    contains(lower(env), "=")
    parts := split(env, "=")
    count(parts) > 1
    msg := sprintf("Environment variable '%s' contains a hardcoded password. Use secrets management instead.", [parts[0]])
}

# Rule to enforce image scanning
warn[msg] {
    not input.security_scan
    msg = "Image has not been scanned for vulnerabilities. All images must be scanned before deployment."
}

# Rule to enforce base image compliance
deny[msg] {
    not startswith(input.config.image, "approved-registry.financial.com/")
    not startswith(input.config.image, "gcr.io/distroless/")
    not startswith(input.config.image, "us-docker.pkg.dev/cloudrun/container/")
    msg = "Base image must be from an approved registry. Use an approved base image."
}

# Rule to enforce resource limits
warn[msg] {
    not input.config.resources.limits.cpu
    msg = "Container CPU limits not set. All containers must have resource limits defined."
}

warn[msg] {
    not input.config.resources.limits.memory
    msg = "Container memory limits not set. All containers must have resource limits defined."
}

# Rule to enforce network policy
deny[msg] {
    input.config.hostNetwork == true
    msg = "Host network access is prohibited for financial services. Use container networking instead."
}

# Rule to enforce volume mounts security
deny[msg] {
    volume := input.config.volumes[_]
    volume.hostPath
    not startswith(volume.hostPath.path, "/var/log")
    not startswith(volume.hostPath.path, "/tmp")
    msg := sprintf("Host path volume mount '%s' is not allowed. Use only approved mount points.", [volume.hostPath.path])
}

# Rule to enforce image tag policy
warn[msg] {
    image := input.config.image
    not contains(image, ":")
    msg = "Image without specific tag found. Using 'latest' tag is not recommended for financial services."
}

warn[msg] {
    image := input.config.image
    contains(image, ":latest")
    msg = "Using 'latest' tag is not recommended for financial services. Use specific version tags."
}

# Rule to enforce security context
deny[msg] {
    input.config.securityContext.privileged == true
    msg = "Privileged containers are not allowed for financial services."
}

# Rule to enforce read-only root filesystem
warn[msg] {
    not input.config.securityContext.readOnlyRootFilesystem
    msg = "Read-only root filesystem is recommended for financial services containers."
}
EOF < /dev/null