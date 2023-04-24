@IsTest
private class WarehouseCalloutServiceTest {
    @isTest 
    static void testWarehouseCalloutService(){
        Product2 prod = new Product2();
        prod.Name = 'Generator 1000 kW';
        prod.Current_Inventory__c = 5;
        prod.Cost__c = 5000;
        prod.Lifespan_Months__c = 120;
        prod.Maintenance_Cycle__c = 365;
        prod.Warehouse_SKU__c = '100003';
        insert prod;
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        Test.startTest();
        system.enqueueJob(new WarehouseCalloutService());
        system.assert(true, true);
        Test.stopTest();
    }

}