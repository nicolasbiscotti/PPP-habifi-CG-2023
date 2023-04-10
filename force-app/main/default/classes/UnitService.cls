public with sharing class UnitService {
   public static void unitResponseProcess(Id unitId, String questionAnswer){
    Id currentUserId = UserInfo.getUserId();
    Map <Id, Id> questionAnswerObj = (Map<Id, Id>) JSON.deserializeStrict(questionAnswer, Map<Id, Id>.class);
    User_Unit__c unitResponse = new User_Unit__c(Status__c = 'Draft', User__c = currentUserId, Unit__c = unitId);
   }
}