/*
AccountHelper Overview

The `AccountHelper` class is designed to provide helper methods that assist in performing specific operations on Account records. 
This class is intended to modularize the logic used in the `AccountTrigger` to ensure separation of concerns, improve readability, and ease maintenance. 

This class is currently stubbed out. As part of this exercise, you are expected to:
1. Implement the method bodies to carry out the specified operations on Account records.
2. Refactor the `AccountTrigger` to utilize the methods provided in this `AccountHelper` class.

Methods:
- `setTypeProspect(SObject objects)`: 
    - Purpose: Update the 'Type' field of the given Account record to 'Prospect' if it's not already set.
    - Note: You'll likely need to adjust the method signature to accept the necessary parameters.

- `addressCopy()`: 
    - Purpose: Copy the shipping address of the Account to its billing address. 
    - Note: You'll likely need to adjust the method signature to accept the necessary parameters.

- `setRating`: 
    - Purpose: Evaluate certain conditions on the Account and assign a rating based on that evaluation. You'll need to define the method's signature and implement its logic.

- `defaultContact`: 
    - Purpose: Create a default contact related to the Account after the Account is inserted. You'll need to define the method's signature and implement its logic.

Remember:
Always ensure that your helper methods are bulk-safe to handle multiple records efficiently. 
*/
public with sharing class AccountHelper {
    
    public static void updateAccountFileds(List<Account> newAccounts) {
        List<Contact> contacts = new List<Contact>();

        for (Account acc : newAccounts){

            //Set the account type to prospect.
            //When an account is inserted change the account type to 'Prospect' if there is no value in the type field.
            if(String.isBlank(acc.Type)) {
                acc.Type = 'Prospect';
            }            
            

            //Set the account rating to hot.
            //When an account is inserted set the rating to 'Hot' if the Phone, Website, and Fax ALL have a value.
            if(String.isNotBlank(acc.Phone) && String.isNotBlank(acc.Fax) && String.isNotBlank(acc.Fax)) {
                acc.Rating = 'Hot';
            }
            

            //2. Copy the shipping address to the billing address.
            //When an account is inserted copy the shipping address to the billing address.
            //BONUS: Check if the shipping fields are empty before copying.
            if(String.isBlank(acc.BillingStreet) && String.isNotBlank(acc.ShippingStreet)) {
                acc.BillingCity = acc.ShippingCity;
                acc.BillingStreet = acc.ShippingStreet;
                acc.BillingPostalCode = acc.ShippingPostalCode;
                acc.BillingState = acc.ShippingState;
                acc.BillingCountry = acc.ShippingCountry;
            }
            
        }   

    }

    public static void afterAccount(List<Account> newAccounts) {
        List<Contact> newContacts = new List<Contact>();

        for (Account a : newAccounts ) {
            newContacts.add(new Contact(LastName = 'DefaultContact', Email = 'default@email.com', AccountId = a.Id));

        }
        
        if (newContacts.size() > 0) {
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true;
            Database.insert(newContacts, dml);           
        }

    }
}
