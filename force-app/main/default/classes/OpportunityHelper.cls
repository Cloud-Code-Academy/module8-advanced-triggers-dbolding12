public with sharing class OpportunityHelper {

    
    public static void isBeforeInsert(List<Opportunity> opps) {
        for (Opportunity opp: opps) {
            if (opp.Type == null){
                opp.Type = 'New Customer';
            }        
        }
    }

    public static void isBeforeUpdate(List<Opportunity> opps) {
       
        for (Opportunity opp: opps) {
            if(opp.amount < 5000)  {
               opp.adderror('Opportunity amount must be greater than 5000'); 
                      
            }if (opp.StageName != null){
                opp.Description += '\n Stage Change:' + opp.StageName + ':' + DateTime.now().format();
            } 
        }

        List<Id> accountIds = new List<Id>();
        for(Opportunity o : opps) {
            if(accountIds.size() != null) {
                accountIds.add(o.AccountId);
            }
            
        }
                                                                 
        if(accountIds.size() > 0) {
            List<Contact> contacts = [SELECT Id, AccountId, Title FROM Contact WHERE AccountId IN :accountIds AND Title = 'CEO'];
            Map<Id, Contact> acctConMap = new Map<Id, Contact>();

            for(Contact con : contacts) {
                acctConMap.put(con.AccountId, con);
                
            
                for (Opportunity op : opps) {                
                    if(acctConMap.containsKey(op.AccountId) && acctConMap.get(op.AccountId).Id != null ) {
                        op.Primary_Contact__c = acctConMap.get(op.AccountId).Id;  

                 }
            }       

         }      
      }     
                       
   }

    public static void isBeforeDelete(List<Opportunity> opps) {
        //When an opportunity is deleted prevent the deletion of a closed won opportunity if the account industry is 'Banking'.
        Set<Id> accountIds = new Set<Id>();
       
        for(Opportunity opp : opps) {
            if(opp.StageName == 'Closed Won') {
                accountIds.add(opp.AccountId);

           }

        }

        Map<Id, Account> accountIdMap = new Map<Id, Account>([SELECT Id FROM Account WHERE ID IN :AccountIds AND Industry = 'Banking']);
        for(Opportunity o: opps) {
            if(o.StageName == 'Closed Won'|| o.IsClosed) {
                o.adderror('Cannot delete closed opportunity');                  

          }          
          
       }
    }

    public static void isAfterInsert(List<Opportunity> opps) {
    List<Task> tasks = new List<Task>();

    for (Opportunity opp : opps) {
        Task tsk = new Task();
        tsk.Subject = 'Call Primary Contact';
        tsk.WhatId = opp.Id;
        tsk.WhoId = opp.Primary_Contact__c;
        tsk.OwnerId = opp.OwnerId;
        tsk.ActivityDate = Date.today().addDays(3);

        tasks.add(tsk);
     
        }

        insert tasks;
    }

    Public static void isAfterUpdate(List<Opportunity> opps){

       
    }

    /*notifyOwnersOpportunityDeleted:
    - Sends an email notification to the owner of the Opportunity when it gets deleted.
    - Uses Salesforce's Messaging.SingleEmailMessage to send the email.
    */
    public static void notifyOwnersOpportunityDeleted(List<Opportunity> opps) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Set<Id> oppsSet = new Set<Id>();
        for (Opportunity o : opps) {
            oppsSet.add(o.OwnerId);
        }

        Map<Id, User> mapOpps = new Map<Id, User>([SELECT Id, Email 
                                                  FROM User 
                                                  WHERE Id IN : oppsSet]);


        for (Opportunity opp : opps){
           String ownerEmail = opp.Owner.Email;
            if (opp.Owner.Email != null) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new List<String>{mapOpps.get(opp.OwnerId).Email});
                mail.setSubject('Opportunity Deleted : ' + opp.Name);
                mail.setPlainTextBody('Your Opportunity: ' + opp.Name +' has been deleted.');
                mails.add(mail);
            } 
            
        }        
        
        try {
            Messaging.sendEmail(mails);
        } catch (Exception e){
            System.debug('Exception: ' + e.getMessage());
        }
    }

    public static void assignPrimaryContact(Map<Id,Opportunity> oppNewMap) {        
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        Set<Id> accountIds = new Set<Id>();

        for(opportunity o : oppNewMap.values()) {
            accountIds.add(o.AccountId);
        }

        String title = 'VP Sales';

        List<Contact> contacts = new List<Contact>([SELECT Id, AccountId 
                                                    FROM Contact 
                                                    WHERE Title = :title AND AccountId IN :accountIds
                                                    LIMIT 1]);

        Map<Id, Id> acctConMap = new Map<Id, Id>();

        for (Contact con : contacts) {
            acctConMap.put(con.AccountId, con.Id);

        }      
      
        for (Opportunity opp : oppNewMap.values()){            
           
            if (opp.Primary_Contact__c == null){
                String primaryContact = acctConMap.get(opp.AccountId);
                if(primaryContact != null) {
                    Opportunity oppToUpdate = new Opportunity(Id = opp.Id);
                    oppToUpdate.Primary_Contact__c = primaryContact;
                    oppMap.put(opp.Id, opp);

              }                
           }            
        }
        insert oppMap.values();
    }

}
    
