public with sharing class PagerDutyWDCAssignee {
    @AuraEnabled
    public String id { get; private set; }

    @AuraEnabled
    public String summary { get; private set; }

    public PagerDutyWDCAssignee(pagerdutyinc.PagerDutyAssignee a) {
        id = a.assignee.id;
        summary = a.assignee.summary;
    }
}
