/* 
 * Solution for APEX Specialist Superbadge Challange 1
 * Created By -: Nishant Redu 24-04-2023
*/


public with sharing class MaintenanceRequestHelper {
    /*
	 * updateWorkOrders - adds new Cases for the cases which have been closed and are of type 'Repair' or 'Routine Maintenence'
	 * Accepts - List<Case>, Map<Id, Case>
	 * Returns - None
	 * Created By -: Nishant Redu 24-04-2023
	*/
    public static void updateWorkOrders(List<Case> newList, Map<Id, Case> oldMap) {
        List<Equipment_Maintenance_Item__c> maintenenceListItem = getmaintenenceListItem(oldMap.keySet());
       	Map<Id, Double> caseToFrequencyMap = getFrequencymap(maintenenceListItem);
        List<Case> casesToInsert = new List<Case>();   
        for(Case c : newList){
            if((c.Type == 'Repair' || c.Type == 'Routine Maintenance') 
               && c.status == 'Closed' 
               && c.status != oldMap.get(c.Id).status){
                   Case nc = new Case();
                   nc.Vehicle__c = c.Vehicle__c;  
                   nc.Subject = 'Routine Maintenence for ' + c.Id;
                   nc.Status = 'New';
                   nc.Type = 'Routine Maintenance';
                   nc.Date_Reported__c = Date.today();  
                   nc.ParentId = c.Id;
                   nc.Date_Due__c = Date.today() + (Integer) caseToFrequencyMap.get(c.Id);
                   casesToInsert.add(nc);
            }
        }
        system.debug('Cases To Insert ' + casesToInsert);
        insert casesToInsert;
        List<Equipment_Maintenance_Item__c> mainteneceItemsToInsert = handleMaintenenceItemLogic(casesToInsert, oldMap, maintenenceListItem);
    	insert mainteneceItemsToInsert;
    } 
    
    /* 	
     * getFrequencymap - method to map each case with its minimum maintenence Frequency 
	 * Accepts - List<Equipment_Maintenance_Item__c>
     * Returns - Map<Id, Double>
     * Created By -: Nishant Redu 24-04-2023
	*/
    public static Map<Id, Double> getFrequencymap(List<Equipment_Maintenance_Item__c> mainteneceItemList){
        Map<Id,Double> caseToFrequencyMap = new Map<Id,Double>();
        for(Equipment_Maintenance_Item__c item: mainteneceItemList){
            if(caseToFrequencyMap.containsKey(item.Maintenance_Request__c)){
                if(caseToFrequencyMap.get(item.Maintenance_Request__c) > item.Equipment__r.Maintenance_Cycle__c){
                    caseToFrequencyMap.put(item.Maintenance_Request__c,  item.Equipment__r.Maintenance_Cycle__c); 
                }
            }else{
                caseToFrequencyMap.put(item.Maintenance_Request__c,  item.Equipment__r.Maintenance_Cycle__c);
            }
        }
        return caseToFrequencyMap;
    }
    
    /*  
     * getmaintenenceListItem - gets a list of all maintenece Items related to upadted cases 
	 * Accepts - Set<Id>
	 * Returns - List<Equipment_Maintenance_Item__c>
	 * Created By -: Nishant Redu 24-04-2023
	*/
    public static List<Equipment_Maintenance_Item__c> getmaintenenceListItem(Set<Id> caseIdList){
        return [SELECT Id, Equipment__r.Maintenance_Cycle__c, Maintenance_Request__c FROM Equipment_Maintenance_Item__c WHERE Maintenance_Request__c IN: caseIdList];
    }
    
    /* 
     * handleMaintenenceItemLogic - Maps the maintennce items to the new case and inserts them 
	 * Accepts - List<Case>,Map<Id, Case>, List<Equipment_Maintenance_Item__c>
	 * Returns - List<Equipment_Maintenance_Item__c>
	 * Created By -: Nishant Redu 24-04-2023
	*/
    public static List<Equipment_Maintenance_Item__c> handleMaintenenceItemLogic(List<Case> insertedCases,Map<Id, Case> oldMap, List<Equipment_Maintenance_Item__c> mainteneceItems){
        List<Equipment_Maintenance_Item__c> mainteneceItemsToInsert = new List<Equipment_Maintenance_Item__c>();
        Map<Id, Id> oldCaseToNewCaseMap = new Map<Id, Id>();
        for(Case c: insertedCases){
            oldCaseToNewCaseMap.put(c.ParentId, c.Id);
        }
        
        for(Equipment_Maintenance_Item__c item: mainteneceItems){
            Equipment_Maintenance_Item__c newItem = new Equipment_Maintenance_Item__c();
            newItem.Maintenance_Request__c = oldCaseToNewCaseMap.get(item.Maintenance_Request__c);
            newItem.Equipment__c = item.Equipment__c;
            mainteneceItemsToInsert.add(newItem);
        }
        
        return mainteneceItemsToInsert;
    }
}