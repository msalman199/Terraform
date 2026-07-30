# Terraform Plan and Apply Best Practices

## Planning Phase
1. **Always run terraform plan first**
   - Review all changes before applying
   - Save plans to files for documentation
   - Use -detailed-exitcode for automation

2. **Validate configurations**
   - Run terraform validate before planning
   - Use terraform fmt to maintain consistent formatting
   - Check for syntax errors early

## Apply Phase
1. **Backup state files**
   - Always backup terraform.tfstate before major changes
   - Use remote state for team environments
   - Version control your configurations

2. **Use targeted applies when needed**
   - Use -target for specific resource changes
   - Be cautious with partial applies
   - Understand resource dependencies

## Change Management
1. **Monitor for drift**
   - Regularly run terraform plan to detect changes
   - Investigate unexpected drift
   - Document manual changes

2. **Use variables and modules**
   - Make configurations reusable
   - Separate environment-specific values
   - Follow naming conventions

## Safety Measures
1. **Test in non-production first**
   - Use separate environments
   - Validate changes thoroughly
   - Have rollback procedures

2. **Monitor and log**
   - Keep detailed logs of all operations
   - Monitor resource states
   - Set up alerts for failures

## Common Issues and Solutions
1. **State lock issues**
   - Check for stuck locks
   - Use force-unlock carefully
   - Coordinate team access

2. **Resource conflicts**
   - Check for naming conflicts
   - Verify resource dependencies
   - Use unique identifiers

Generated on: $(date)
