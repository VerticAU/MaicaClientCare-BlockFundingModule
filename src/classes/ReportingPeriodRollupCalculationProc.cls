public with sharing class ReportingPeriodRollupCalculationProc extends AbstractProcessor {

    public override Response process(Request request) {
        this.request = request;
        this.doSubmit();
        return this.response;
    }

    private void doSubmit() {
        String periodId = this.request.getRequiredString('periodId');

        Program_Period__c programPeriod = (Program_Period__c) Utils.arrays.firstOrException(
            [SELECT Id FROM Program_Period__c WHERE Id = :periodId],
            'No Funding Program_Period__c with Id: ' + periodId
        );

        List<Program_Period__c> programPeriods = [
            SELECT Id, Period_Total_Quantity__c, Period_Total_Value__c
            FROM Program_Period__c
            WHERE Funding_Period__c = :periodId
            AND Period_Type__c != 'Reporting'
        ];

        Decimal periodTotalQuantity = 0;
        Decimal periodTotalValue = 0;

        for (Program_Period__c programPeriodItem : programPeriods) {
            periodTotalQuantity += Utils.objects.defaultIfNull(programPeriodItem.Period_Total_Quantity__c, 0);
            periodTotalValue += Utils.objects.defaultIfNull(programPeriodItem.Period_Total_Value__c, 0);
        }

        programPeriod.Period_Total_Quantity__c = periodTotalQuantity;
        programPeriod.Period_Total_Value__c = periodTotalValue;
        update programPeriod;
    }
}