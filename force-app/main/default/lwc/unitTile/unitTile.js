import { LightningElement, api } from "lwc";

export default class UnitTile extends LightningElement {
  @api id;
  @api name;
  @api duration;
  @api points;
  @api passedUnitIds;

  handleClick() {
    const unitId = this.id.split("-")[0];
    const navigateEvent = new CustomEvent("navigate", {
      detail: { unitId }
    });
    this.dispatchEvent(navigateEvent);
  }
}
