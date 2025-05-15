#\!/bin/bash
# Local setup script for Container Security Finance project

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check for required tools
check_requirements() {
  echo -e "${YELLOW}Checking requirements...${NC}"
  
  local missing_tools=0
  
  if \! command -v docker &> /dev/null; then
    echo -e "${RED}Docker not found. Please install it: https://docs.docker.com/get-docker/${NC}"
    missing_tools=1
  fi
  
  if \! command -v docker-compose &> /dev/null; then
    echo -e "${RED}Docker Compose not found. Please install it: https://docs.docker.com/compose/install/${NC}"
    missing_tools=1
  fi
  
  if \! command -v aws &> /dev/null; then
    echo -e "${RED}AWS CLI not found. Please install it: https://aws.amazon.com/cli/${NC}"
    missing_tools=1
  fi
  
  if \! command -v trivy &> /dev/null; then
    echo -e "${YELLOW}Trivy not found. It will be used via Docker instead.${NC}"
  fi
  
  if [ $missing_tools -ne 0 ]; then
    echo -e "${RED}Please install the missing tools and run the script again.${NC}"
    exit 1
  fi
  
  echo -e "${GREEN}All requirements satisfied\!${NC}"
}

# Set up local Docker environment
setup_docker_environment() {
  echo -e "${YELLOW}Setting up local Docker environment...${NC}"
  
  # Create local Docker Compose file if not exists
  if [ \! -f deployments/local/docker-compose.yml ]; then
    cp deployments/local/docker-compose.example.yml deployments/local/docker-compose.yml
    echo -e "${YELLOW}Created docker-compose.yml from example. Please update it with your values.${NC}"
  fi
  
  # Create local environment file if not exists
  if [ \! -f deployments/local/.env ]; then
    cp deployments/local/.env.example deployments/local/.env
    echo -e "${YELLOW}Created .env from example. Please update it with your values.${NC}"
  fi
  
  # Build local Docker images
  echo -e "${YELLOW}Building local Docker images...${NC}"
  docker-compose -f deployments/local/docker-compose.yml build
  
  echo -e "${GREEN}Local Docker environment setup complete\!${NC}"
}

# Set up local development environment
setup_dev_environment() {
  echo -e "${YELLOW}Setting up local development environment...${NC}"
  
  # Create Python virtual environment for local development
  if [ \! -d .venv ]; then
    echo -e "${YELLOW}Creating Python virtual environment...${NC}"
    python3 -m venv .venv
    source .venv/bin/activate
    pip install -r requirements.txt
  fi
  
  # Set up local configuration
  if [ \! -f src/config.local.yaml ]; then
    cp src/config.example.yaml src/config.local.yaml
    echo -e "${YELLOW}Created config.local.yaml from example. Please update it with your values.${NC}"
  fi
  
  echo -e "${GREEN}Local development environment setup complete\!${NC}"
}

# Main function
main() {
  echo -e "${GREEN}Setting up Container Security Finance project...${NC}"
  
  check_requirements
  setup_docker_environment
  setup_dev_environment
  
  echo -e "${GREEN}Setup complete\! Next steps:${NC}"
  echo -e "1. Update deployments/local/.env with your values"
  echo -e "2. Update src/config.local.yaml with your values"
  echo -e "3. Start the local environment with: docker-compose -f deployments/local/docker-compose.yml up"
  echo -e "4. Access the UI at: http://localhost:8080"
}

# Run the main function
main
EOF < /dev/null