@isTest
private class InvoiceLineItemRollupCalculationTest {

    @TestSetup
    static void makeData() {
        Contact contact = new Contact(
            LastName = 'Test Contact',
            maica_cc__NDIS_Number__c = '123456781'
        );
        insert contact;

        Account accountVar = new Account(
            Name = 'test',
            maica_cc__ABN__c = '1234',
            maica_cc__Account_Name__c = 'test'
        );
        insert accountVar;

        maica_cc__Invoice__c invoice = new  maica_cc__Invoice__c(
            maica_cc__Participant__c = contact.Id,
            maica_cc__Provider__c = accountVar.Id,
            maica_cc__Claim_Behaviour__c = 'Claimed Attempted',
            maica_cc__Funding_Type__c = 'Agency Managed'
        );
        insert invoice;

        Funding_Program__c fundingProgram = new Funding_Program__c(
            Name = 'Test Program'
        );
        insert fundingProgram;

        Program_Period__c period = new Program_Period__c(
            Period_Type__c = 'Reporting',
            Funding_Program__c = fundingProgram.Id,
            Period_End_Date__c = Date.today().addMonths(2)
        );
        insert period;

        maica_cc__Support_Category__c supportCategory = new maica_cc__Support_Category__c(
            maica_cc__NDIS_Name__c = 'CONSUMABLES'
        );
        insert supportCategory;

        maica_cc__Support_Item__c supportItem = new maica_cc__Support_Item__c(
            Name = 'Support Item',
            maica_cc__Support_Item_Number__c = '1234',
            maica_cc__Support_Category__c = supportCategory.Id
        );
        insert supportItem;

        List<maica_cc__Invoice_Line_Item__c> items = new List<maica_cc__Invoice_Line_Item__c>{
            new maica_cc__Invoice_Line_Item__c(
                Reporting_Period__c = period.Id,
                maica_cc__Support_Item__c = supportItem.Id,
                maica_cc__Invoice__c = invoice.Id,
                maica_cc__Status__c = 'Partially Paid',
                maica_cc__Quantity__c = 5,
                maica_cc__Line_Total__c = 100
            ),
            new maica_cc__Invoice_Line_Item__c(
                Reporting_Period__c = period.Id,
                maica_cc__Support_Item__c = supportItem.Id,
                maica_cc__Invoice__c = invoice.Id,
                maica_cc__Status__c = '	Entered',
                maica_cc__Quantity__c = 3,
                maica_cc__Line_Total__c = 50
            )
        };
        insert items;
    }

    @isTest
    static void testBehavior() {
        Test.startTest();
        Database.executeBatch(new InvoiceLineItemRollupCalculationBatch());
        Test.stopTest();

        Program_Period__c updatedPeriod = [
            SELECT Period_Total_Quantity__c, Period_Total_Value__c
            FROM Program_Period__c LIMIT 1
        ];

        // Zeroing occurs in FLow
        Assert.areEqual(0, updatedPeriod.Period_Total_Quantity__c, 'Invalid Quantity amount');
        Assert.areEqual(0, updatedPeriod.Period_Total_Value__c, 'Invalid Line Total amount');
    }
}