public with sharing class PagerDutyWDCController {
    public PagerDutyWDCController() {
    }

    @AuraEnabled(cacheable=true)
    public static List<PagerDutyWDCIncident> getIncidents() {
        pagerdutyinc.PagerDutyClient pdc = pagerdutyinc.PagerDutyClient.newInstance()
                    .withBaseUrl('callout:PagerDuty_API')
                    .withApiKey('{!$Credential.Password}');
        pagerdutyinc.PagerDutyIncidentsPage ip = pdc.getIncidents();
        List<PagerDutyWDCIncident> incidents = new List<PagerDutyWDCIncident>();
        for ( pagerdutyinc.PagerDutyIncident incident : ip.incidents ) {
            incidents.add(new PagerDutyWDCIncident(incident));
        }
        return incidents;
    }

    @AuraEnabled(cacheable=true)
    public static PagerDutyWDCIncident getPDIncidentForSObjectID(String soid) {
        pagerdutyinc__PagerDutyIncidentMapping__c mapping = null;
        try {
            mapping = [SELECT pagerdutyinc__IncidentID__c, pagerdutyinc__SObjectID__c FROM pagerdutyinc__PagerDutyIncidentMapping__c WHERE pagerdutyinc__SObjectID__c = :soid LIMIT 1];
        }
        catch ( System.QueryException e ) {
            return null;
        }
        if ( mapping == null || mapping.pagerdutyinc__IncidentID__c == null ) {
            return null;
        }
        pagerdutyinc.PagerDutyClient pdc = pagerdutyinc.PagerDutyClient.newInstance()
                    .withBaseUrl('callout:PagerDuty_API')
                    .withApiKey('{!$Credential.Password}');
        PagerDutyWDCIncident incident = null;
        try {
            pagerdutyinc.PagerDutyIncident pdIncident = pdc.getIncident(mapping.pagerdutyinc__IncidentID__c);
            incident = new PagerDutyWDCIncident(pdIncident);
        } catch ( Exception e ) {
            return null;
        }
        return incident;
    }

    @AuraEnabled(cacheable=true)
    public static List<PagerDutyWDCTask> getTasks() {
        return getTasks(null, null);
    }

    @AuraEnabled(cacheable=true)
    public static List<PagerDutyWDCTask> getTasks(String taskSet, String locationId) {
        String whereClause = '';
        if ( taskSet != null ) {
            switch on taskSet.toLowerCase() {
                when 'open' {
                    whereClause = ' WHERE Status != \'Completed\'';
                }
                when 'closed' {
                    whereClause = ' WHERE Status = \'Completed\'';
                }
                when 'all' {
                    whereClause = ' WHERE Id != null';
                }
                when else {
                    whereClause = ' WHERE Status = \'' + taskSet + '\'';
                }
            }
        }

        if ( locationId != null ) {
            whereClause += ' AND wkcc__Location__r.wkcc__LocationPath__c LIKE \'%' + locationId + '%\'';
        }
        Map<String,Schema.SObjectField> mfields = Task.sObjectType.getDescribe().fields.getMap();
        List<String>fields = new List<String>();
        for ( Schema.SObjectField f : mfields.values() ) {
            if ( f.getDescribe().isAccessible() ) {
                fields.add(f.getDescribe().getName());
            }
        }
        fields.add('wkcc__Location__r.Name');

        List<Task> tasks = Database.query('select ' + String.join(fields, ',') + ' from Task' + whereClause);
        List<PagerDutyWDCTask> pdTasks = new List<PagerDutyWDCTask>();
        for ( Task task : tasks ) {
            pdTasks.add(new PagerDutyWDCTask(task, getPDIncidentForSObjectID(task.Id)));
        }
        return pdTasks;
    }
}
