import getTrailWrapper from "@salesforce/apex/UnitService.getTrailWrapper";
import { LightningElement, api, track, wire } from "lwc";

export default class TrailView extends LightningElement {
  @api recordId;

  trailName;
  trailPoints;
  trailDuration;
  trailDescription;

  @track modules;

  passedModuleIds;
  passedUnitIds;

  @wire(getTrailWrapper, { trailId: "$recordId" })
  wireTrailWrapper({ data, error }) {
    if (data) {
      this.setWrapper(data);
    } else {
      console.log("trailView error: ", error);
    }
  }

  setWrapper(stringFormatData) {
    const trailWrapper = JSON.parse(stringFormatData);
    this.setTrail(trailWrapper);
    this.setModules(trailWrapper);
    console.log("modules trailView", trailWrapper.modules);
    console.log("passesModuleIds trailView", trailWrapper.passedModuleIds);
  }

  setTrail(trailWrapper) {
    this.trailName = trailWrapper.trail.Name;
    this.trailPoints = trailWrapper.trail.Total_Points__c;
    this.trailDuration = trailWrapper.trail.Duration__c;
    this.trailDescription = trailWrapper.trail.Description__c;
  }
  setModules(trailWrapper) {
    this.modules = trailWrapper.modules;
  }
}
