global with sharing class WarehouseSyncSchedule implements Schedulable {
    global void execute(SchedulableContext SC) {
      system.enqueueJob(new WarehouseCalloutService());
   }
}