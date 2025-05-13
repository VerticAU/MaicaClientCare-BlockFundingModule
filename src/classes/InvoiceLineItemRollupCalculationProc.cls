public with sharing class InvoiceLineItemRollupCalculationProc extends AbstractProcessor {

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

        List<maica_cc__Invoice_Line_Item__c> invoiceLineItems = [
            SELECT Id, maica_cc__Quantity__c, maica_cc__Line_Total__c
            FROM maica_cc__Invoice_Line_Item__c
            WHERE Reporting_Period__c = :periodId
            AND maica_cc__Status__c != 'Voided'
        ];

        Decimal periodTotalQuantity = 0;
        Decimal periodTotalValue = 0;

        for (maica_cc__Invoice_Line_Item__c invoiceLineItem : invoiceLineItems) {
            periodTotalQuantity += Utils.objects.defaultIfNull(invoiceLineItem.maica_cc__Quantity__c, 0);
            periodTotalValue += Utils.objects.defaultIfNull(invoiceLineItem.maica_cc__Line_Total__c, 0);
        }

        programPeriod.Period_Total_Quantity__c = periodTotalQuantity;
        programPeriod.Period_Total_Value__c = periodTotalValue;
        update programPeriod;
    }
}