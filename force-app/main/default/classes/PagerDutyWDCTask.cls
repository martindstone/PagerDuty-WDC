public with sharing class PagerDutyWDCTask {
    @AuraEnabled
    public Task task { get; private set; }

    @AuraEnabled
    public PagerDutyWDCIncident pagerDutyIncident { get; private set; }

    @AuraEnabled
    public String taskURL { get; private set; }

    @AuraEnabled
    public static void setStatus(String id, String status) {
        Task task = [SELECT Id, Status from Task WHERE Id = :id LIMIT 1];
        task.Status = status;
        update task;
    }

    @AuraEnabled
    public static string getStatus(String id) {
        Task task = [SELECT Id, Status from Task WHERE Id = :id LIMIT 1];
        return task.Status;
    }

    public PagerDutyWDCTask(Task task, PagerDutyWDCIncident pagerDutyIncident) {
        this.task = task;
        this.pagerDutyIncident = pagerDutyIncident;
        this.taskURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + this.task.Id;
    }
}
