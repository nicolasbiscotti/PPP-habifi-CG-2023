public with sharing class UnitService {
  @AuraEnabled(cacheable=true)
  public static String getTrailWrapper(Id trailId) {
    Id currentUserId = UserInfo.getUserId();
    TrailWrapper wapper = new TrailWrapper(trailId, currentUserId);
    return JSON.serialize(wapper);
  }

  @AuraEnabled(cacheable=true)
  public static String getUnitWrapper(Id unitId) {
    UnitWrapper wrapper = new UnitWrapper(unitId);
    return JSON.serialize(wrapper);
  }

  @AuraEnabled(cacheable=false)
  public static String unitResponseProcess(Id unitId, String questionAnswer) {
    // grab the logged userId
    Id currentUserId = UserInfo.getUserId();

    Map<Id, Id> questionAnswerMap = (Map<Id, Id>) JSON.deserializeStrict(
      questionAnswer,
      Map<Id, Id>.class
    );

    User_Unit__c userUnitResponse = new User_Unit__c(
      Status__c = 'Draft',
      Unit__c = unitId,
      User__c = currentUserId
    );

    // ToDo: check if the user did make an attempt to answer this unit
    //       if true -> asign the User_Module Id to the userUnitResponse
    //       if false -> create a new User_Module for currentUser with Status inProgress
    //                   and asign the new User_Module  Id to the userUnitResponse
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

    userUnitResponse.User_Module__c = currentModule.Id;

    insert userUnitResponse;

    // create the option(Unit_Question_Answer__c sObjects) for the
    // curent attempt to complete the Unit
    List<Unit_Question_Answer__c> questionAnswerList = new List<Unit_Question_Answer__c>();
    for (String questionId : questionAnswerMap.keySet()) {
      String answerId = questionAnswerMap.get(questionId);
      Unit_Question_Answer__c option = new Unit_Question_Answer__c(
        User_Unit__c = userUnitResponse.Id,
        Question__c = questionId,
        Answer__c = answerId
      );
      questionAnswerList.add(option);
    }

    insert questionAnswerList;

    userUnitResponse.Status__c = 'Answered';
    update userUnitResponse;

    User_Unit__c userUnitResult = [
      SELECT Status__c, Earned_Points__c
      FROM User_Unit__c
      WHERE Id = :userUnitResponse.Id
    ];

    if (userUnitResult.Status__c == 'Success') {
      String message =
        'Congratulations you earned ' +
        userUnitResult.Earned_Points__c +
        ' points';
      return message;
    } else {
      return 'Wrong answer';
    }
  }
}
