public with sharing class WarehouseCalloutService implements Queueable{
	
    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';
    public void execute(QueueableContext context){
        callWarehouse();
    }
    @future(callout=true)
    public static void callWareHouse(){
        HttpRequest req = new HttpRequest();
        req.setEndpoint(WAREHOUSE_URL);
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        List<responseWrapper> responseList = (List<responseWrapper>)JSON.deserialize(res.getBody(), List<responseWrapper>.class);
        processResponse(responseList);
    }
    
    public static void processResponse(List<responseWrapper> responseList){
        Map<String, responseWrapper> skuToResMap = new Map<String, responseWrapper>();
        for(responseWrapper res: responseList){
            skuToResMap.put(res.sku, res);
        } 
        Map<Id,Product2> mapOfEquipments = new Map<Id,Product2>([SELECT Id, Name, Current_Inventory__c, Cost__c, Lifespan_Months__c, Maintenance_Cycle__c, Warehouse_SKU__c FROM Product2 WHERE Warehouse_SKU__c IN: skuToResMap.keySet()]);
        Set<String> skuSInSalesforce = new Set<String>();
        for(Product2 prod: mapOfEquipments.values()){
            prod.Name = skuToResMap.get(prod.Warehouse_SKU__c).name;
            prod.Current_Inventory__c = skuToResMap.get(prod.Warehouse_SKU__c).quantity;
            prod.Cost__c = skuToResMap.get(prod.Warehouse_SKU__c).cost;
            prod.Lifespan_Months__c = skuToResMap.get(prod.Warehouse_SKU__c).lifespan;
            prod.Maintenance_Cycle__c = skuToResMap.get(prod.Warehouse_SKU__c).maintenanceperiod;
            skuSInSalesforce.add(prod.Warehouse_SKU__c);
        }
        update mapOfEquipments.values();
        insertNewRecords(skuToResMap, skuSInSalesforce);
    }
    
    public static void insertNewRecords(Map<String, responseWrapper> skuToResMap, Set<String> skuSInSalesforce){
        List<Product2> prodsToInsert = new List<Product2>();
        for(responseWrapper res: skuToResMap.values()){
            if(!skuSInSalesforce.contains(res.sku)){
                Product2 prod = new Product2();
                prod.Name = skuToResMap.get(res.sku).name;
                prod.Current_Inventory__c = skuToResMap.get(res.sku).quantity;
                prod.Cost__c = skuToResMap.get(res.sku).cost;
                prod.Lifespan_Months__c = skuToResMap.get(res.sku).lifespan;
                prod.Maintenance_Cycle__c = skuToResMap.get(res.sku).maintenanceperiod;
                prod.Warehouse_SKU__c = res.sku;
                prodsToInsert.add(prod);
            }
        }
        insert prodsToInsert;
    }
    
    public class responseWrapper{
        Boolean replacement;
        Integer quantity;
        String name;
        Integer maintenanceperiod;
        Integer lifespan;
        Double cost;
        String sku;
    }
    
}