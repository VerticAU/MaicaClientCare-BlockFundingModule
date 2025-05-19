@isTest
private class ReportingPeriodRollupCalculationTest {

    @TestSetup
    static void makeData() {
        Funding_Program__c fundingProgram = new Funding_Program__c(
            Name = 'Test Program'
        );
        insert fundingProgram;

        Program_Period__c period = new Program_Period__c(
            Period_Type__c = 'Funding',
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

        List<Program_Period__c> programPeriods = new List<Program_Period__c>{
            new Program_Period__c(
                Period_Total_Quantity__c = 3,
                Period_Total_Value__c = 4,
                Funding_Program__c = fundingProgram.Id,
                Funding_Period__c = period.Id
            ),
            new Program_Period__c(
                Period_Total_Quantity__c = 5,
                Period_Total_Value__c = 6,
                Funding_Program__c = fundingProgram.Id,
                Funding_Period__c = period.Id
            )
        };
        insert programPeriods;
    }

    @isTest
    static void testBehavior() {
        Test.startTest();
        Database.executeBatch(new ReportingPeriodRollupCalculationBatch());
        Test.stopTest();

        Program_Period__c updatedPeriod = [
            SELECT Period_Total_Quantity__c, Period_Total_Value__c
            FROM Program_Period__c
            WHERE Period_Type__c = 'Funding'
            LIMIT 1
        ];

        // Zeroing occurs in FLow
        Assert.areEqual(0, updatedPeriod.Period_Total_Quantity__c, 'Invalid Period Total Quantity amount');
        Assert.areEqual(0, updatedPeriod.Period_Total_Value__c, 'Invalid Period Total Value amount');
    }
}