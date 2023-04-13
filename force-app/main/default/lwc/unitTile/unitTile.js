import { LightningElement, api } from "lwc";

export default class UnitTile extends LightningElement {
  @api id;
  @api name;
  @api duration;
  @api points;
  @api passedUnitIds;

  handleClick() {
    this.dispatchEvent(new CustomEvent("navigate"), {
      detail: { unitId: this.id }
    });
  }
}
