public with sharing class PagerDutyWDCIncident {
    @AuraEnabled
    public String id { get; private set; }

    @AuraEnabled
    public String title { get; private set; }

    @AuraEnabled
    public String status { get; private set; }

    @AuraEnabled
    public String priority { get; private set; }

    @AuraEnabled
    public String html_url { get; private set; }

    @AuraEnabled
    public List<PagerDutyWDCAssignee> assignments { get; private set; }

    public PagerDutyWDCIncident(pagerdutyinc.PagerDutyIncident i) {
        id = i.id;
        title = i.title;
        status = i.status;
        priority = i.priority != null ? i.priority.summary : null;
        html_url = i.html_url;
        assignments = new List<PagerDutyWDCAssignee>();
        for ( pagerdutyinc.PagerDutyAssignee ass : i.assignments ) {
            assignments.add(new PagerDutyWDCAssignee(ass));
        }
    }
}
