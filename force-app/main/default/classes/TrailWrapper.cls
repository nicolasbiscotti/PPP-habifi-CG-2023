public with sharing class TrailWrapper {
  private Id userId;
  private Id trailId;
  //Registro de Trail solicitado
  public Trail__c trail;
  //Porcentaje de progreso del Alumno en el Trail
  public Integer progressTrail;

  private Trail__c trailWithModules;

  //Módulos con Unidades relacionadas
  private List<Module__c> modules = new List<Module__c>();

  private Set<Id> moduleIds = new Set<Id>();

  //Ids de módulos relacionados al Trail actual en los que el Alumno ya aprobó
  private Set<Id> passedModuleIds = new Set<Id>();
  //Ids de Unidades relacionadas a módulos del Trail actual que el Alumno ya aprobó
  private Set<Id> passedUnitIds = new Set<Id>();

  public TrailWrapper(Id trailId, Id userId) {
    this.userId = userId;
    this.trailId = trailId;
    initializeProperties(trailId);
  }

  private void initializeProperties(Id trailId) {
    this.trailWithModules = [
      SELECT
        Name,
        Description__c,
        Total_Points__c,
        Duration__c,
        (
          SELECT
            Module__c,
            Module__r.Name,
            Module__r.Description__c,
            Module__r.Role__c,
            Module__r.Skills__c,
            Module__r.Total_Points__c,
            Module__r.Unit_Count__c
          FROM Trail_Modules__r
        )
      FROM Trail__c
      WHERE Id = :trailId
    ];

    this.trail = this.parseTrail(this.trailWithModules);
    this.fillModules(this.trailWithModules.Trail_Modules__r);

    this.fillPassedModules();
  }

  private void fillPassedModules() {
    List<User_Module__c> userModulesWithUserUnits = [
      SELECT Id, Module__c, Status__c
      FROM User_Module__c
      WHERE User__c = :this.userId AND Module__c IN :moduleIds
    ];

    for (User_Module__c userModule : userModulesWithUserUnits) {
      if (userModule.Status__c == 'Completed') {
        this.passedModuleIds.add(userModule.Module__c);
      }
    }
  }

  private void fillTrails() {
  }

  private void fillModules(List<Trail_Module__c> trailModules) {
    for (Trail_Module__c trailModule : trailModules) {
      this.modules.add(this.parseModule(trailModule));
      this.moduleIds.add(trailModule.Module__c);
    }
  }

  private Module__c parseModule(Trail_Module__c toParse) {
    return new Module__c(
      Id = toParse.Module__c,
      Name = toParse.Module__r.Name,
      Description__c = toParse.Module__r.Description__c,
      Role__c = toParse.Module__r.Role__c,
      Skills__c = toParse.Module__r.Skills__c
    );
  }

  private Trail__c parseTrail(Trail__c toParse) {
    return new Trail__c(
      Id = toParse.Id,
      Name = toParse.Name,
      Description__c = toParse.Description__c,
      Total_Points__c = toParse.Total_Points__c,
      Duration__c = toParse.Duration__c
    );
  }

  public List<Module__c> getModules() {
    return this.modules;
  }
  public Set<Id> getPassedModuleIds() {
    return this.passedModuleIds;
  }
  public Set<Id> getPassedUnitIds() {
    return this.passedUnitIds;
  }
}
