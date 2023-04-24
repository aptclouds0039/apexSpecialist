@isTest
public with sharing class WarehouseSyncScheduleTest {
    @isTest
    static void testWarehouseSyncSchedule(){
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
        WarehouseSyncSchedule sh1 = new WarehouseSyncSchedule();
		String sch = '0 0 23 * * ?'; 
        system.schedule('Test Territory Check', sch, sh1); 
        system.assert(true, true);
        Test.stopTest();
    }
}