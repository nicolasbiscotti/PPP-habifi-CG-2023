public with sharing class UserUnitResponseHelper {
  public static void evaluateResponse(
    Boolean isBeforeUpdate,
    List<User_Unit__c> userUnits,
    Map<Id, User_Unit__c> oldUserUnitMap
  ) {
    if (isBeforeUpdate) {
      Set<Id> usersTryingToAnswer = new Set<Id>();
      Set<Id> unitsToCorrect = new Set<Id>();

      List<User_Unit__c> draftToAnswered = new List<User_Unit__c>();

      for (User_Unit__c userUnit : userUnits) {
        if (isDraftToAnswered(userUnit, oldUserUnitMap)) {
          draftToAnswered.add(userUnit);
          usersTryingToAnswer.add(userUnit.User__c);
          unitsToCorrect.add(userUnit.Unit__c);
        }
      }

      List<User_Module__c> userModuleWithAttempts = [
        SELECT
          Id,
          (
            SELECT Status__c, Unit__r.Points__c
            FROM User_Units__r
            WHERE
              User__c IN :usersTryingToAnswer
              AND Unit__c IN :unitsToCorrect
              AND Status__c = 'Fail'
          )
        FROM User_Module__c
      ];

      Map<Id, Decimal> pointsByUnit = new Map<Id, Decimal>();
      Map<Id, Map<Id, Integer>> failedAttemptsByUser = new Map<Id, Map<Id, Integer>>();

      fillPointsAndAttempts(pointsByUnit, failedAttemptsByUser, userModuleWithAttempts);

      List<Unit_Question_Answer__c> answerResult = [
        SELECT Answer__r.Is_Correct__c, User_Unit__c
        FROM Unit_Question_Answer__c
        WHERE User_Unit__c IN :draftToAnswered
      ];

      Map<Id, Boolean> isSuccessByUserUnit = createSuccessMap(answerResult);

      for (User_Unit__c toUpdate : draftToAnswered) {
        if (isSuccessByUserUnit.get(toUpdate.Id)) {
          Integer failedAttempts = 0;
          Decimal unitPoints = pointsByUnit.get(toUpdate.Unit__c);
          if (failedAttemptsByUser.get(toUpdate.User__c) != null) {
            failedAttempts = failedAttemptsByUser.get(toUpdate.User__c).get(toUpdate.Unit__c);
          }
          toUpdate.Earned_Points__c = earnedPoints(failedAttempts, unitPoints);
          toUpdate.Status__c = 'Success';
        } else {
          toUpdate.Status__c = 'Fail';
        }
      }
    }
  }

  public static Decimal earnedPoints(Integer failedAttempts, Decimal unitPoints) {
    Decimal points;

    if (failedAttempts == 0) {
      points = unitPoints;
    } else if (failedAttempts == 1) {
      points = unitPoints * 0.5;
    } else {
      points = unitPoints * 0.25;
    }

    return points;
  }

  public static void fillPointsAndAttempts(
    Map<Id, Decimal> pointsByUnit,
    Map<Id, Map<Id, Integer>> failedUnitsByUser,
    List<User_Module__c> userModuleWithAttempts
  ) {
    for (User_Module__c userModule : userModuleWithAttempts) {
      for (User_Unit__c failedAttemp : userModule.User_Units__r) {
        Id userId = failedAttemp.User__c;
        Id unitId = failedAttemp.Unit__c;
        Decimal points = failedAttemp.Unit__r.Points__c;

        fillPointsByUnit(pointsByUnit, unitId, points);
        fillFailedUnitsByUser(failedUnitsByUser, userId, unitId);
      }
    }
  }

  public static void fillPointsByUnit(Map<Id, Decimal> pointsByUnit, Id unitId, Decimal points) {
    if (pointsByUnit.get(unitId) == null) {
      pointsByUnit.put(unitId, points);
    }
  }

  public static void fillFailedUnitsByUser(Map<Id, Map<Id, Integer>> failedUnitsByUser, Id userId, Id unitId) {

    if (failedUnitsByUser.get(userId) == null) {
      failedUnitsByUser.put(userId, new Map<Id, Integer>{ unitId => 1 });
    } else {
      if (failedUnitsByUser.get(userId).get(unitId) == null) {
        failedUnitsByUser.get(userId).put(unitId, 1);
      } else {
        Integer failures = failedUnitsByUser.get(userId).get(unitId);
        failedUnitsByUser.get(userId).put(unitId, failures + 1);
      }
    }

  }

  public static Boolean isDraftToAnswered(User_Unit__c userUnit, Map<Id, User_Unit__c> oldMap) {
    Boolean isAnswered = userUnit.Status__c == 'Answered';
    Boolean wasDraft = oldMap.get(userUnit.Id).Status__c == 'Draft';

    return isAnswered && wasDraft;
  }

  public static Map<Id, Boolean> createSuccessMap(List<Unit_Question_Answer__c> answerResult) {
    Map<Id, Boolean> successMap = new Map<Id, Boolean>();

    for (Unit_Question_Answer__c result : answerResult) {
      Id userUnitId = result.User_Unit__c;

      Boolean noAnswerYet = successMap.get(userUnitId) == null;
      Boolean correctAnswer = successMap.get(userUnitId);

      if (noAnswerYet || correctAnswer) {
        Boolean isCorrect = result.Answer__r.Is_Correct__c == 'Yes';
        successMap.put(userUnitId, isCorrect);
      }
    }

    return successMap;
  }
}
