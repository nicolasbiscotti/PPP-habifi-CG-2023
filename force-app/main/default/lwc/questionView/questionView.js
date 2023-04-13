import { LightningElement, api } from "lwc";

export default class QuestionView extends LightningElement {
  @api id;
  @api content;

  options = [];
  value = "";

  handleChange(event) {
    console.log("unitView question", this.id);
    console.log("unitView answer", event.detail.value);
  }

  @api
  get answers() {
    return this.options;
  }
  set answers(answerList) {
    for (const answer of answerList) {
      this.options.push({ label: answer.content, value: answer.id });
    }
  }
}
