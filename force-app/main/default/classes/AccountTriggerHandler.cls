public with sharing class AccountTriggerHandler extends TriggerHandler{
    private List<Account> newAccts;
    private Map<Id, Account> newAcctsMap; 

    public AccountTriggerHandler() {
        this.newAccts = (List<Account>)Trigger.new;
        this.newAcctsMap = (Map<Id, Account>)Trigger.newMap;
        //this.setMaxLoopCount(1);
        
    }

    public override void beforeInsert() {
        AccountHelper.updateAccountFileds(this.newAccts);  
      
    }

    public override void afterInsert() {
        AccountHelper.afterAccount(this.newAccts); 
    
    }
}