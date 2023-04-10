trigger UserUnitResponse on User_Unit__c(before update) {
  UserUnitResponseHelper.evaluateResponse(
    Trigger.isBefore,
    Trigger.new,
    Trigger.oldMap
  );
}
