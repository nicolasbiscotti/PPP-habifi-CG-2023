public with sharing class UnitWrapper {
  //Registro de Unidad solicitada
  public Unit__c unit;
  //Listado de Preguntas con Opciones relacionadas
  public List<Question__c> questions;

  public UnitWrapper(Id unitId) {
    queryAndSetUnit(unitId);
    queryAndSetQuetionsWithAnswers(unitId);
  }

  private void queryAndSetUnit(Id unitId) {
    unit = [
      SELECT Id, Name, Points__c, Duration__c, Description__c, Content__c
      FROM Unit__c
      WHERE Id = :unitId
    ];
  }

  private void queryAndSetQuetionsWithAnswers(Id unitId) {
    questions = [
      SELECT
        Content__c,
        (SELECT Content_Answers__c, Is_Correct__c FROM Answers__r)
      FROM Question__c
      WHERE Unit__c = :unitId
    ];
  }
}
