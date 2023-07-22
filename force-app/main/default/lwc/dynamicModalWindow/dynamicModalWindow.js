import { LightningElement,api, track, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import userId from '@salesforce/user/Id';
import getApprovers from '@salesforce/apex/DynamicModalWindowController.getApprovers';
import createCommentFromApprover from '@salesforce/apex/DynamicModalWindowController.createCommentFromApprover';
import updateApproverCommentWithAnswer from '@salesforce/apex/DynamicModalWindowController.updateApproverCommentWithAnswer';
import getAMLOfficersForOnboarding from '@salesforce/apex/DynamicModalWindowController.getAMLOfficersForOnboarding';
import saveLWCLog from '@salesforce/apex/LogService.saveLWCLog';
import labelOfOnboardingStarted from '@salesforce/label/c.Onboarding_started';
import labelOfTerminationReasonPlaceholder from '@salesforce/label/c.Select_termination_reason';
import labelOfRequiredFieldsValidation from '@salesforce/label/c.Complete_required_fields';
import labelOfErrorShowToast from '@salesforce/label/c.Something_went_wrong';
import labelOfTerminationStartedSuccessfuly from '@salesforce/label/c.Termination_started_successfully';
import labelOfRecordRejected from '@salesforce/label/c.Record_rejected';
import labelOfRejectButton from '@salesforce/label/c.Reject_Button';
import labelOfSubmittedForApproval from '@salesforce/label/c.Record_submitted_for_approval';
import cancelButton from '@salesforce/label/c.cancelButton';
import terminateRecordButton from '@salesforce/label/c.Terminate_Record';
import sentToApproveButton from '@salesforce/label/c.Sent_to_Approve';
import otherRejectionReason from '@salesforce/label/c.Other_Rejection_Reason';
import otherTerminationReason from '@salesforce/label/c.Other_Termination_Reason';
import selectAMLOfficer from '@salesforce/label/c.Select_AML_Officer';
import assignAMLOfficer from '@salesforce/label/c.Assign_AML_Officer';
import labelOfCommentSuccessfulySent from '@salesforce/label/c.Comment_has_been_successfully_sent';
import labelOfAnswerSuccessfulySent from '@salesforce/label/c.Your_answer_has_been_successfully_sent';
import sendButton from '@salesforce/label/c.Send_Button';
import commentsLabel from '@salesforce/label/c.Comments';
import answerLabel from '@salesforce/label/c.Answer_Label';

export default class DynamicModalWindow extends LightningElement {

    @api isterminatemodal;
    @api issenttoapprovemodal;
    @api issenttoonboardingmodal;
    @api isrejectionmodal;
    @api issentbackmodal;
    @api isanswercommentmodal;
    @api isadditionaldocumentmodal;
    @api textofmessage;
    @api approvername;

    @api nameOfObject = 'Customer__c';
    @api nameoffield;
    
    @api placeholder = labelOfTerminationReasonPlaceholder;
    @api fillRequiredFields = labelOfRequiredFieldsValidation;
    @api labelofmodalwindow;
    @api labelOfCancelButton = cancelButton;
    @api labelOfTerminateRecordButton = terminateRecordButton;
    @api labelOfSentToApproveButton = sentToApproveButton;
    @api labelOfOtherRejectionReason = otherRejectionReason;
    @api labelOfOtherTerminationReason = otherTerminationReason;
    @api labelOfRecordRejectedButton = labelOfRejectButton;
    @api labelOfSelectAMLOfficer = selectAMLOfficer;
    @api labelOfAssignAMLOfficer = assignAMLOfficer;
    @api labelOfComments = commentsLabel;
    @api labelOfSendButton = sendButton;
    @api labelOfAnswer = answerLabel

    @api idOfRecordType;
    @api recordid;
    @api approver;
    @api amlOfficer;
    @api idOfUser = userId;

    @api selectedReasonOfTerminate;
    @api selectedReasonOfReject;
    @api showCommentBox;
    @api otherTerminationReason;
    @api otherRejectionReason;
    @api comments;
    @api answer;

    @track confirmButtonDisabled = true;
    @track terminateReasonLabel;
    @track terminateRejectLabel;

    @track terminateReasonOptions;
    @track rejectReasonOptions;
    @track approverOptions;
    @track amlOfficerOptions;

    apiNameOfField;

    connectedCallback() {
        this.getOptions();
        this.getAMLOfficerOptions();
    }

    @wire(getObjectInfo, { objectApiName: '$nameOfObject' })
    getObjectData({ error, data }) {
        if (data) {
            if (this.idOfRecordType == null) {
                this.idOfRecordType = data.defaultRecordTypeId;
                this.apiNameOfField = this.nameOfObject + '.' + this.nameoffield;
                if(this.nameoffield == 'Rejection_Reason__c') {
                    this.terminateRejectLabel = data.fields[this.nameoffield].label;
                } else if(this.nameoffield == 'Termination_Reason__c') {
                    this.terminateReasonLabel = data.fields[this.nameoffield].label;
                }
            }
        } else if (error) {
            saveLWCLog({ id : this.recordid,
                description: JSON.stringify(error)})
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$idOfRecordType', fieldApiName: '$apiNameOfField' })
    getPicklistValues({ error, data }) {
        if (data) {
            if(this.nameoffield == 'Rejection_Reason__c') {
                this.rejectReasonOptions = data.values.map(rejectReasonValue => {
                    return {
                        label: rejectReasonValue.label,
                        value: rejectReasonValue.value
                    };
                }); 
            } else if(this.nameoffield == 'Termination_Reason__c') {
                this.terminateReasonOptions = data.values.map(terminateReasonValue => {
                    return {
                        label: terminateReasonValue.label,
                        value: terminateReasonValue.value
                    };
                }); 
            }
        } else if (error) {
            saveLWCLog({ id : this.recordid,
                description: JSON.stringify(error)})
        }
    }
    
      getOptions() {
        getApprovers({recordId: this.recordid})
          .then((result) => {
             let approverOptions = [];
            if (result) {
              result.forEach(data => {
                approverOptions.push({
                  label: data.Name,
                  value: data.Id,
                });
              });
            }
            this.approverOptions = approverOptions;
          })
          .catch((error) => {
            saveLWCLog({ id : this.recordid,
                description: JSON.stringify(error)})
        });
      }

      getAMLOfficerOptions() {
        getAMLOfficersForOnboarding({recordId: this.recordid})
          .then((result) => {
             let amlOfficerOptions = [];
            if (result) {
              result.forEach(data => {
                amlOfficerOptions.push({
                  label: data.Name,
                  value: data.Id,
                });
              });
            }
            this.amlOfficerOptions = amlOfficerOptions;
          })
          .catch((error) => {
            saveLWCLog({ id : this.recordid,
                description: JSON.stringify(error)})
        });
      }

    handleChangeOfTerminationReason(event) {

        this.selectedReasonOfTerminate = event.detail.value;
        this.showCommentBox = this.selectedReasonOfTerminate == 'Other' ? true : false;
        if(this.selectedReasonOfTerminate == null || this.selectedReasonOfTerminate == undefined || this.selectedReasonOfTerminate == 'undefined') {
            this.confirmButtonDisabled = true;
        } else {
            this.confirmButtonDisabled = false;
        }
    }

    handleChangeOfRejectReason(event) {

        this.selectedReasonOfReject = event.detail.value;
        this.showCommentBox = this.selectedReasonOfReject == 'Other' ? true : false;
        if(this.selectedReasonOfReject == null || this.selectedReasonOfReject == undefined || this.selectedReasonOfReject == 'undefined') {
            this.confirmButtonDisabled = true;
        } else {
            this.confirmButtonDisabled = false;
        }
    }

    handleClose(){
        const showModalWindow = false;
        this.dispatchEvent(new CustomEvent('close', {
          detail: showModalWindow
        }));
    }

    handleOtherTerminationReason(event) {
        this.otherTerminationReason = event.detail.value;
        if(this.otherTerminationReason == null || this.otherTerminationReason == '') {
            this.confirmButtonDisabled = true;
        } else {
                this.confirmButtonDisabled = false;
        }
    }

    handleChangeComments(event) {
        this.comments = event.detail.value;
        if(this.comments == null || this.comments == '') {
            this.confirmButtonDisabled = true;
        } else {
                this.confirmButtonDisabled = false;
        }
    }

    handleChangeAnswer(event) {
        this.answer = event.detail.value;
        if(this.answer == null || this.answer == '') {
            this.confirmButtonDisabled = true;
        } else {
                this.confirmButtonDisabled = false;
        }
    }

    handleOtherRejectionReason(event) {
        this.otherRejectionReason = event.detail.value;
        if(this.otherRejectionReason == null || this.otherRejectionReason == '') {
            this.confirmButtonDisabled = true;
        } else {
            this.confirmButtonDisabled = false;
        }
    }

    handleChangeApprover(event) {
        this.approver = event.detail.value;
        this.confirmButtonDisabled = this.approver == null ? true : false;
    }

    handleChangeAMLOfficer(event) {
        this.amlOfficer = event.detail.value;
        this.confirmButtonDisabled = this.amlOfficer == null ? true : false;
    }

    confirmTerminateRecord(event){
        const fields = {};
        fields.Id = this.recordid;
        fields['Status__c'] = 'Termination in Process';
        fields['Rejected_Termination_Reason__c'] = this.selectedReasonOfTerminate;
        if(this.otherTerminationReason != null) {
            fields['Comment_Box__c'] = this.otherTerminationReason;
        }
    
        const recordInput = { fields };
        if(this.selectedReasonOfTerminate != 'Other' || (this.selectedReasonOfTerminate == 'Other' && this.otherTerminationReason != null)) {
            updateRecord(recordInput)
            .then(() => {
                this.showToast('', labelOfTerminationStartedSuccessfuly, 'Success');
                setTimeout(() => {
                    location.reload();
                }, 1500);
                })
            .catch(error => {
                this.showToast('Error', labelOfErrorShowToast, 'Error');
                saveLWCLog({ id : this.recordid,
                    description: JSON.stringify(error)})
            });
        } else {
            this.showToast('Error', this.fillRequiredFields, 'error');
        }
    }

    confirmRejectRecord(event){
        const fields = {};
        let timeOfApprove = new Date(); 
        fields.Id = this.recordid;
        fields['Status__c'] = 'Rejected';
        fields['Approved_Rejected_Date__c'] = timeOfApprove.toISOString();
        fields['Rejected_Termination_Reason__c'] = this.selectedReasonOfReject;
        if(this.otherRejectionReason != null) {
            fields['Comment_Box__c'] = this.otherRejectionReason;
        }
    
        const recordInput = { fields };
        if(this.selectedReasonOfReject != 'Other' || (this.selectedReasonOfReject == 'Other' && this.otherRejectionReason != null)) {
            updateRecord(recordInput)
            .then(() => {
                this.showToast('', labelOfRecordRejected, 'Success');
                setTimeout(() => {
                    location.reload();
                }, 1500);
                })
            .catch(error => {
                this.showToast('Error', labelOfErrorShowToast, 'Error');
                saveLWCLog({ id : this.recordid,
                    description: JSON.stringify(error)})
            });
        } else {
            this.showToast('Error', this.fillRequiredFields, 'error');
        }
    }

    confirmSentToApprove() {
        const fields = {};
        fields.Id = this.recordid;
        fields['Status__c'] = 'Sent To Approve';
        fields['Approver_Name__c'] = this.approver;

        const recordInput = { fields };
            updateRecord(recordInput)
            .then(() => {
                this.showToast('', labelOfSubmittedForApproval, 'Success');
                setTimeout(() => {
                    location.reload();
                }, 1500);
            })
            .catch(error => {
                this.showToast('Error', labelOfErrorShowToast, 'Error');
                saveLWCLog({ id : this.recordid,
                            description: JSON.stringify(error)})
            });
    }

    confirmAMLOfficerForOnboarding() {
        const fields = {};
        fields.Id = this.recordid;
        fields['Status__c'] = 'Onboarding'; 
        fields['Onboarding_Officer__c'] = this.amlOfficer;
        const recordInput = { fields };
    
        updateRecord(recordInput)
          .then(() => {
            this.showToast('', labelOfOnboardingStarted, 'Success');
            setTimeout(() => {
              location.reload();
            }, 1500);
          })
          .catch(error => {
            this.showToast('Error', labelOfErrorShowToast, 'Error');
            saveLWCLog({ id : this.recordid,
              description: JSON.stringify(error)})
          });
    }

    sendCommentToCompliance() {
        createCommentFromApprover({
            recordId: this.recordid,
            userId: this.idOfUser,
            message: this.comments
        }).then((result) => {
            if(result){
                this.showToast('', labelOfCommentSuccessfulySent, 'Success');
                setTimeout(() => {
                    location.reload();
                }, 1500);
            }
            this.error = undefined;
        }).catch((error) => {
            this.showToast('Error', labelOfErrorShowToast, 'Error');
            saveLWCLog({ id : this.recordid,
              description: JSON.stringify(error)})
        });
    }

    sendAnswerToComment() {
        updateApproverCommentWithAnswer({
            recordId: this.recordid,
            answer: this.answer
        }).then((result) => {
            if(result){
                this.showToast('', labelOfAnswerSuccessfulySent, 'Success');
                setTimeout(() => {
                    location.reload();
                }, 1500);
            }
            this.error = undefined;
        }).catch((error) => {
            this.showToast('Error', labelOfErrorShowToast, 'Error');
            saveLWCLog({ id : this.recordid,
              description: JSON.stringify(error)})
        });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}