import { LightningElement, api } from "lwc";

export default class UnitTile extends LightningElement {
  @api id;
  @api name;
  @api duration;
  @api points;
  @api passedUnitIds;

  handleClick() {
    const unitId = this.id.slice(0, -4);
    const navigateEvent = new CustomEvent("navigate", {
      detail: { unitId }
    });
    this.dispatchEvent(navigateEvent);
  }
}
