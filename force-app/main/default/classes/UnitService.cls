public with sharing class UnitService {
  public static void unitResponseProcess(Id unitId, String questionAnswer) {
    // grab the logged userId
    Id currentUserId = UserInfo.getUserId();

    Map<Id, Id> questionAnswerMap = (Map<Id, Id>) JSON.deserializeStrict(
      questionAnswer,
      Map<Id, Id>.class
    );

    User_Unit__c unitModuleResponse = new User_Unit__c(
      Status__c = 'Draft',
      Unit__c = unitId,
      User__c = currentUserId
    );

    // ToDo: check if the user did make an attempt to answer this unit
    //       if true -> asign the User_Module Id to the unitModuleResponse
    //       if false -> create a new User_Module for currentUser with Status inProgress
    //                   and asign the new User_Module  Id to the unitModuleResponse
    User_Module__c currentModule;

    Unit__c unit = [SELECT Id, Module__c FROM Unit__c WHERE Id = :unitId];

    List<User_Module__c> moduleList = [
      SELECT Id
      FROM User_Module__c
      WHERE Module__c = :unit.Module__c AND User__c = :currentUserId
    ];

    if (moduleList.size() > 0) {
      currentModule = moduleList.get(0);
    } else {
      currentModule = new User_Module__c(
        Module__c = unit.Module__c,
        User__c = currentUserId,
        Status__c = 'In Progress'
      );
      insert currentModule;
    }

    unitModuleResponse.User_Module__c = currentModule.Id;

    insert unitModuleResponse;

    // create the option(Unit_Question_Answer__c sObjects) for the
    // curent attempt to complete the Unit
    List<Unit_Question_Answer__c> questionAnswerList = new List<Unit_Question_Answer__c>();
    for (String questionId : questionAnswerMap.keySet()) {
      String answerId = questionAnswerMap.get(questionId);
      Unit_Question_Answer__c option = new Unit_Question_Answer__c(
        User_Unit__c = unitModuleResponse.Id,
        Question__c = questionId,
        Answer__c = answerId
      );
      questionAnswerList.add(option);
    }

    insert questionAnswerList;

    unitModuleResponse.Status__c = 'Answered';
    update unitModuleResponse;
  }
}
