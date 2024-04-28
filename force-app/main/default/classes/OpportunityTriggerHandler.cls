public with sharing class OpportunityTriggerHandler extends TriggerHandler{
    private List<Opportunity> newOpps;
    private List<Opportunity> oldOpps;
    private Map<Id, Opportunity> newOppsMap;
    private Map<Id, Opportunity> oldOppsMap;

    public OpportunityTriggerHandler() {
        this.newOpps = (List<Opportunity>)Trigger.new;
        this.oldOpps = (List<Opportunity>)Trigger.old;
        this.oldOppsMap = (Map<Id, Opportunity>)Trigger.oldMap;
        this.newOppsMap = (Map<Id, Opportunity>)Trigger.newMap;

        //this.setMaxLoopCount(1);

    }

    public override void beforeInsert() {
        OpportunityHelper.isBeforeInsert(this.newOpps);
    }

    public override void beforeUpdate() {
        OpportunityHelper.isBeforeUpdate(this.newOpps);

    }

    public override void afterInsert() {
        OpportunityHelper.isAfterInsert(this.newOpps);

    }

    public override void beforeDelete() {
        OpportunityHelper.isBeforeDelete(this.oldOpps);


    } 

    public override void afterUpdate() {
        OpportunityHelper.isAfterUpdate(this.oldOpps);
    }

    public override void afterDelete() {
        OpportunityHelper.notifyOwnersOpportunityDeleted(This.oldOpps);
    }

    public override void afterUndelete() {
        OpportunityHelper.assignPrimaryContact( this.newOppsMap);
    }

   
    
}