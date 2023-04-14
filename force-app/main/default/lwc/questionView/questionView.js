import { LightningElement, api } from "lwc";

export default class QuestionView extends LightningElement {
  @api id;
  @api content;

  options = [];
  value = "";

  handleChange(event) {
    const questionId = this.id.split("-")[0];
    const answerId = event.detail.value;

    const answerSelected = new CustomEvent("answerselected", {
      detail: { questionId, answerId }
    });

    this.dispatchEvent(answerSelected);
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
