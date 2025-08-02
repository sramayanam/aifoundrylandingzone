## Contributing

We welcome contributions! Please follow these guidelines:

### Development Setup

1. **Prerequisites**:
   - Terraform >= 1.0
   - Azure CLI
   - Appropriate Azure subscriptions and permissions

2. **Local Development**:
   ```bash
   # Clone the repository
   git clone <repository-url>
   cd terraform-foundry-nocaphost
   
   # Copy and configure variables
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your environment details
   
   # Initialize and validate
   terraform init
   terraform validate
   terraform plan
   ```

### Code Standards

- Follow Terraform best practices and naming conventions
- Use meaningful variable descriptions
- Include appropriate tags on all resources
- Ensure cross-subscription compatibility
- Test with different environment configurations

### Pull Request Process

1. Create a feature branch from `main`
2. Make your changes with clear, descriptive commits
3. Test your changes thoroughly
4. Update documentation as needed
5. Submit a pull request with a clear description

### Issue Reporting

Please use GitHub issues to report bugs or request features. Include:
- Clear description of the issue
- Steps to reproduce
- Expected vs actual behavior
- Terraform version and Azure CLI version

## Security

- Never commit sensitive data like subscription IDs or secrets
- Use `terraform.tfvars.example` for documentation
- Report security vulnerabilities privately via email

## License

This project is licensed under the MIT License - see the LICENSE file for details.
