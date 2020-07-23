trigger PagerDutyTaskTrigger on Task (after insert, after update) {

    // !Test.isRunningTest() - we don't want tests to trigger
    // !System.isFuture() - we don't support starting engine from future context.
    //    Also it's important to break a circular call when Rule is configured to update sObject
    // !System.isBatch() - we don't support starting engine from batch context.

    if (!System.isFuture() && !System.isBatch()) {
        String oldStr = JSON.serialize(Trigger.oldMap);
        String newStr = JSON.serialize(Trigger.newMap);
        if (!Test.isRunningTest()) pagerdutyinc.PagerDutyEngineLauncher.launchByTrigger(oldStr, newStr, Trigger.isInsert);
    }
}