# Azure Terraform Homework!

## Premise

There are 3 Azure Subscriptions (We shall refer to them as Subscriptions A, B and C).
In "Subscription A" there is a NSG which contains rules that are already in place.

```resource "azurerm_network_security_group" "example" ```

The resources inside Subscriptions B and C need to access the whole VNET of Subscription A over Port 80 and all other ports be blocked

## The Challenge

Both Subscription B and C use a Module called Networking which is where the change needs to be made.

At the moment the priority is set to 100 but this is already in use so the Networking Module needs to be updated to find the next free number in the NSG within Subscription A when it is called.

```resource "azurerm_network_security_rule" "example"```

Once the priority has been set this should not change when a plan is ran again so if the rule is created with priority 101 it would stay as 101 when terraform runs again.

*Dummy Subscription ID's have been provided but can be changed 

## Considerations

How would you get the data from the Network Security Group in Subscription A?

What logic would you use to loop through the security rules?

How would you check if the data source contains the priority before assigning it to a rule?

How could this module be further improved?
