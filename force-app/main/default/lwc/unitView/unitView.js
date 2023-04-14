import getUnitWrapper from "@salesforce/apex/UnitService.getUnitWrapper";
import unitResponseProcess from "@salesforce/apex/UnitService.unitResponseProcess";
import { LightningElement, api, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

const ERROR = "Wrong answer";
const SUCCES_VARIANT = "success";
const ERROR_VARIANT = "error";

export default class UnitView extends LightningElement {
  unitId;

  isLoading = true;
  failedAttempts = 0;

  name;
  points;
  duration;
  description;
  content;

  questions;

  userResponse = {};

  setAnswer(questionId, answerId) {
    this.userResponse[questionId] = answerId;
  }

  handleAnswerSelected(event) {
    const { questionId, answerId } = event.detail;
    this.setAnswer(questionId, answerId);
  }

  handleClick() {
    this.checkQuiz();
  }

  handleQuizResult(result) {
    const toShow = { title: result };
    if (result !== ERROR) {
      toShow.variant = SUCCES_VARIANT;
    } else {
      toShow.variant = ERROR_VARIANT;
      this.countFailAttempt();
    }
    this.showQuizResult(toShow);
  }
  handleQuizError(error) {
    console.log("unitView", error);
  }

  @wire(getUnitWrapper, { unitId: "$unitId" })
  wireUnitWrapper({ data, error }) {
    if (data) {
      this.parseWrapper(data);
    } else if (error) {
      console.log("unitView", error);
    }
  }

  checkQuiz() {
    this.setLoading(true);
    const questionAnswer = JSON.stringify(this.userResponse);
    unitResponseProcess({ unitId: this.unitId, questionAnswer })
      .then((result) => this.handleQuizResult(result))
      .catch((error) => this.handleQuizError(error))
      .finally(() => this.setLoading(false));
  }

  parseWrapper(stringFormatData) {
    const unitWrapper = JSON.parse(stringFormatData);
    this.setBasicInfo(unitWrapper);
    this.setQuestionWithAnswers(unitWrapper);
    this.setLoading(false);
  }

  setBasicInfo({ unit }) {
    this.name = unit.Name;
    this.points = unit.Points__c;
    this.duration = unit.Duration__c;
    this.description = unit.Description__c;
    this.content = unit.Content__c;
  }

  setQuestionWithAnswers({ questions }) {
    this.questions = questions.map((question) => ({
      id: question.Id,
      content: question.Content__c,
      answers: this.getAnswers(question)
    }));
  }

  getAnswers({ Answers__r }) {
    const answers = Answers__r.records;
    return answers.map((answer) => ({
      content: answer.Content_Answers__c,
      id: answer.Id,
      isCorrect: answer.Is_Correct__c,
      questionId: answer.Question__c
    }));
  }

  showQuizResult(config) {
    this.dispatchEvent(new ShowToastEvent(config));
  }

  setLoading(value) {
    this.isLoading = value;
  }

  @api get recordId() {
    return this.unitId;
  }
  set recordId(value) {
    this.unitId = value;
  }

  get checkQuizText() {
    return `Check the Quiz to Earn ${this.pointsToEarn} Point`;
  }

  countFailAttempt() {
    this.failedAttempts += 1;
  }
  get pointsToEarn() {
    let points;
    if (this.failedAttempts === 0) {
      points = this.points;
    } else if (this.failedAttempts === 1) {
      points = this.points * 0.5;
    } else {
      points = this.points * 0.25;
    }

    return points;
  }
}
