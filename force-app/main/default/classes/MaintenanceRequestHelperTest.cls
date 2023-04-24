@isTest
public with sharing class MaintenanceRequestHelperTest {
    @isTest
    static void testupdateWorkOrders(){
        Vehicle__c v = new Vehicle__c();
        insert v;
        Equipment_Maintenance_Item__c emic = new Equipment_Maintenance_Item__c();
        Case c = new Case();
        c.Type = 'Routine Maintenance';
        c.Status = 'New';
        c.EngineeringReqNumber__c ='TEST';
        c.Vehicle__c = v.Id;
        insert c;
        Product2 p = new Product2();
        p.Name = 'Test Prod';
        p.Maintenance_Cycle__c = 20;
        p.Replacement_Part__c = true;
    	insert p;
        Product2 p2 = new Product2();
        p2.Name = 'Test Prod';
        p2.Maintenance_Cycle__c = 10;
        p2.Replacement_Part__c = true;
    	insert p2;
        emic.Maintenance_Request__c = c.Id;
        emic.Equipment__c = p.Id;
        insert emic;
        Equipment_Maintenance_Item__c emic2 = new Equipment_Maintenance_Item__c();
        emic2.Maintenance_Request__c = c.Id;
        emic2.Equipment__c = p2.Id;
        insert emic2;
        c.Status = 'Closed';
        
        
        test.startTest();
        Database.SaveResult result = Database.update(c);
        system.assert(true, result.isSuccess());
        test.stopTest();        
    }
}