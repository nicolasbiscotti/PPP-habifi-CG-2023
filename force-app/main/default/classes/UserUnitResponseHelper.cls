public with sharing class UserUnitResponseHelper {
  public static void evaluateResponse(
    Boolean isBeforeUpdate,
    List<User_Unit__c> userUnits,
    Map<Id, User_Unit__c> oldUserUnitMap
  ) {
    if (isBeforeUpdate) {
      List<User_Unit__c> draftToAnswered = new List<User_Unit__c>();
      for (User_Unit__c userUnit : userUnits) {
        if (isDraftToAnswered(userUnit, oldUserUnitMap)) {
          draftToAnswered.add(userUnit);
        }
      }

      if (draftToAnswered.size() > 0) {
        List<Unit_Question_Answer__c> answersResult = [
          SELECT Answer__r.Is_Correct__c, User_Unit__c
          FROM Unit_Question_Answer__c
          WHERE User_Unit__c IN :draftToAnswered
        ];

        for (User_Unit__c toUpdate : draftToAnswered) {
          if (isSuccess(toUpdate, answersResult)) {
            toUpdate.Status__c = 'Success';
          } else {
            toUpdate.Status__c = 'Fail';
          }
        }

      }

    }
  }

  public static Boolean isDraftToAnswered(User_Unit__c userUnit, Map<Id, User_Unit__c> oldMap) {
    return userUnit.Status__c == 'Answered' && oldMap.get(userUnit.Id).Status__c == 'Draft';
  }

  public static Boolean isSuccess(User_Unit__c userUnit, List<Unit_Question_Answer__c> answersResult) {
    for (Unit_Question_Answer__c result : answersResult) {
      if (result.User_Unit__c == userUnit.Id && result.Answer__r.Is_Correct__c == 'No') {
        return false;
      }
    }

    return true;
  }

  public static Map<Id, Boolean> isSuccessMap(List<Unit_Question_Answer__c> answersResult) {
    Map<Id, Boolean> successMap = new Map<Id, Boolean>();

    for (Unit_Question_Answer__c result : answersResult) {
      if (successMap.get(result.User_Unit__c) == null || successMap.get(result.User_Unit__c)) {
        Boolean isCorrect = result.Answer__r.Is_Correct__c == 'Yes';
        successMap.put(result.User_Unit__c, isCorrect);
      }
    }

    return successMap;
  }
}
