public with sharing class ReportingPeriodRollupCalculationBatch implements Database.Batchable<SObject>, Schedulable {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        Date todayPlusMonth = Date.today().addMonths(1);

        return Database.getQueryLocator(
            'SELECT Id FROM Program_Period__c ' +
            'WHERE Period_Type__c = \'Funding\' ' +
            'AND Period_End_Date__c > :todayPlusMonth'
        );
    }

    public void execute(Database.BatchableContext bc, List<SObject> records) {
        for (SObject record : records) {
            Response response = new ReportingPeriodRollupCalculationProc().process(
                new Map<String, Object>{
                    'periodId' => record.Id
                }
            );
        }
    }

    public void finish(Database.BatchableContext bc) {}

    public void execute(SchedulableContext param) {
        Database.executeBatch(new InvoiceLineItemRollupCalculationBatch(), 1);
    }
}