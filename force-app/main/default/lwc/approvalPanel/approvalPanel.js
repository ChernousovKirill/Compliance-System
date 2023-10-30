import { LightningElement, track, wire, api } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import getInfoFromCustomer from '@salesforce/apex/ApprovalPanelController.getInfoFromCustomer';
import checkIfUserIsSystemAdministrator from '@salesforce/apex/ApprovalPanelController.checkIfUserIsSystemAdministrator';
import checkIfUserHadPermissionForNewCustomer from '@salesforce/apex/ApprovalPanelController.checkIfUserHadPermissionForNewCustomer';
import getApproverComment from '@salesforce/apex/ApprovalPanelController.getApproverComment';
import saveLWCLog from '@salesforce/apex/LogService.saveLWCLog';
import userId from '@salesforce/user/Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import labelOfErrorShowToast from '@salesforce/label/c.Something_went_wrong';
import terminateButton from '@salesforce/label/c.Terminate_Button';
import disconnectButton from '@salesforce/label/c.Disconnect_Button';
import terminateRecordButton from '@salesforce/label/c.Terminate_Record';
import sentToApproveButton from '@salesforce/label/c.Sent_to_Approve';
import labelOfOnboardingStarted from '@salesforce/label/c.Onboarding_started';
import labelOfRecordApproved from '@salesforce/label/c.Record_approved';
import labelOfRejectModal from '@salesforce/label/c.Reject_Record'
import labelOfStatusChangedToOnHold from '@salesforce/label/c.Status_changed_to_On_Hold';
import labelOfStatusChangedToSuspended from '@salesforce/label/c.Status_changed_to_Suspended';
import labelOfDisconnectionHasBeenStarted from '@salesforce/label/c.Disconnection_has_been_started';
import labelOfStatusChangedToActive from '@salesforce/label/c.Status_changed_to_Active';
import labelOfRecordWasTerminated from '@salesforce/label/c.Record_was_terminated';
import labelOfStartOnboardingButton from '@salesforce/label/c.Start_Onboarding_Button';
import labelOfAssignOfficerButton from '@salesforce/label/c.Assign_AML_Officer';
import labelOfShowAMLFormButton from '@salesforce/label/c.Show_AML_Form_Button';
import labelOfSentToApproveButton from '@salesforce/label/c.Sent_To_Approve_Button';
import labelOfOnHoldButton from '@salesforce/label/c.On_Hold_Button';
import labelOfSuspendButton from '@salesforce/label/c.Suspend_Button';
import labelOfDisconnectButton from '@salesforce/label/c.Disconnect_Button';
import labelOfGeneratePDFButton from '@salesforce/label/c.Generate_PDF_Button';
import labelOfActivateButton from '@salesforce/label/c.Activate_Button';
import labelOfApproveButton from '@salesforce/label/c.Approve_Button';
import labelOfRejectButton from '@salesforce/label/c.Reject_Button';
import labelOfDeleteButton from '@salesforce/label/c.Delete_Button';
import labelOfUnansweredComment from '@salesforce/label/c.Unanswered_comment_from_approver';
import labelOfSendBackWithCommentButton from '@salesforce/label/c.Send_back_with_comment';
import labelOfAnswerToCommentButton from '@salesforce/label/c.Answer_to_comment'; 

export default class ApporvalPanel extends LightningElement {

    @api recordId;
    @api objectApiName;
    @api isComplete = false;
    @api officerHasUnansweredComments = false;
    @api nameOfApprover;
    @api textOfCommentMessage;
    @api numberOfUnansweredComments;
    @api nameOfCustomer;

    @track isCustomerApiName = false;
    @track isWebsiteApiName = false;

    @track statusOfCustomer;
    @track newCustomer = false;
    @track displayStartOnboardingButton = false;
    @track isHadProfileOfHeadCompliance = false;
    @track onboardingCustomer = false;
    @track sentToApprove = false;
    @track activeCustomer = false;

    @track activateButtonIsAvailable = false;
    @track terminateOrDisconnectButtonIsAvailable = false;
    
    @track systemAdmin = true;

    @track showTerminateModal = false;
    @track showRejectionModal = false;
    @track showSentToApproveModal = false;
    @track showRejectionModal = false;
    @track showSendBackWithCommentModal = false;
    @track showAnswerToCommentModal = false;
    @track showModalWindow = false;
    @track showAMLForm = false;
    @track showCopyWebsiteDatatModal = false;
    @track showAssignOfficerModal = false;

    @track nameoffield = '';

    @track approver;
    @track onboardingOfficerOfCustomer = false;

    @track onboardingOfficerId;
    @track userId = userId;

    @api labelofmodalwindow = '';
    @api labelOfTerminateButton = terminateButton;
    @api labelOfDisconnectButton = disconnectButton;
    @api labelOfTerminateOrDisconnectButton;
    @api labelOfStartOnboarding = labelOfStartOnboardingButton;
    @api labelOfAssignOfficer = labelOfAssignOfficerButton;
    @api labelOfShowAMLForm = labelOfShowAMLFormButton;
    @api labelOfSentToApprove = labelOfSentToApproveButton;
    @api labelOfOnHold = labelOfOnHoldButton;
    @api labelOfSuspend = labelOfSuspendButton;
    @api labelOfDisconnect = labelOfDisconnectButton;
    @api labelOfTerminate = terminateButton;
    @api labelOfGeneratePDF = labelOfGeneratePDFButton;
    @api labelOfActivate = labelOfActivateButton;
    @api labelOfApprove = labelOfApproveButton;
    @api labelOfReject = labelOfRejectButton;
    @api labelOfDelete = labelOfDeleteButton;
    @api labelOfSendBackWithComment = labelOfSendBackWithCommentButton;
    @api labelOfAnswerToComment = labelOfAnswerToCommentButton;


    connectedCallback() {
        this.getInfo();
      }

    getInfo() {
        getInfoFromCustomer({
            recordId: this.recordId
        }).then((result) => {
            if(result){
                this.statusOfCustomer = result.Status__c;
                this.isComplete = result.Is_Complete__c;
                this.approver = result.Approver_Name__c;
                this.onboardingOfficerId = result.Onboarding_Officer__c;
                this.nameOfCustomer = result.Name;
                if(result.Unanswered_Comments__c > 0 && result.Onboarding_Officer__c == this.userId) {
                  this.showToast('', labelOfUnansweredComment, 'Warning');
                  this.officerHasUnansweredComments = true;
                }
            }
            this.error = undefined;
        }).catch((error) => {
            this.error = error;
            console.log(error);
        });
    }

    confirmApprove() {
        const fields = {};
        let timeOfApprove = new Date();

        fields.Id = this.recordId;
        fields['Status__c'] = 'Active'; 
        fields['Approved_Rejected_Date__c'] = timeOfApprove.toISOString();
    
        const recordInput = { fields };
    
        updateRecord(recordInput)
          .then(() => {
            this.showToast('', labelOfRecordApproved, 'Success');
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

    changeToOnHold() {
        const fields = {};

        fields.Id = this.recordId;
        fields['Status__c'] = 'On Hold'; 
    
        const recordInput = { fields };
    
        updateRecord(recordInput)
          .then(() => {
            this.showToast('', labelOfStatusChangedToOnHold, 'Success');
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

    changeToSuspend() {
        const fields = {};

        fields.Id = this.recordId;
        fields['Status__c'] = 'Suspended'; 
    
        const recordInput = { fields };
    
        updateRecord(recordInput)
          .then(() => {
            this.showToast('', labelOfStatusChangedToSuspended, 'Success');
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

    changeToDisconnect() {
        const fields = {};

        fields.Id = this.recordId;
        fields['Status__c'] = 'Disconnection in Process'; 
    
        const recordInput = { fields };
    
        updateRecord(recordInput)
          .then(() => {
            this.showToast('', labelOfDisconnectionHasBeenStarted, 'Success');
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

    changeToActive() {
        const fields = {};

        fields.Id = this.recordId;
        fields['Status__c'] = 'Active'; 
    
        const recordInput = { fields };
    
        updateRecord(recordInput)
          .then(() => {
            this.showToast('', labelOfStatusChangedToActive, 'Success');
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

    handleStartOnboarding() {
      console.log('test');
      const fields = {};
      fields.Id = this.recordId;
      fields['Status__c'] = 'Onboarding'; 
      fields['Onboarding_Officer__c'] = this.userId;
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

    changeToTerminationOrDisconnect() {
        const fields = {};

        fields.Id = this.recordId;
        if(this.statusOfCustomer == 'Termination in Process') {
            fields['Status__c'] = 'Terminated';
        } else if (this.statusOfCustomer == 'Disconnection in Process') {
            fields['Status__c'] = 'Disconnected';
        } 
    
        const recordInput = { fields };
    
        updateRecord(recordInput)
          .then(() => {
            this.showToast('', labelOfRecordWasTerminated, 'Success');
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

    openTerminateModal() {
        this.showModalWindow = true;
        this.showTerminateModal = true;
        this.labelofmodalwindow = terminateRecordButton;
        this.nameoffield = 'Termination_Reason__c';
    }

    openRejectionModal() {
      this.showModalWindow = true;
      this.showRejectionModal = true;
      this.labelofmodalwindow = labelOfRejectModal;
      this.nameoffield = 'Rejection_Reason__c';
  }

    openSentToApproveModal() {
      this.showModalWindow = true;
      this.showSentToApproveModal = true;
      this.labelofmodalwindow = sentToApproveButton;
    }

    openSendBackWithCommentsModal() {
      this.showModalWindow = true;
      this.showSendBackWithCommentModal = true;
      this.labelofmodalwindow = sendBackWithComment;
    }

    openCopyWebsiteDataModal() {
      this.showModalWindow = true;
      this.showCopyWebsiteDatatModal = true;
      this.labelofmodalwindow = 'Copy Data';
    }

    openAssignOfficerModal() {
      this.showModalWindow = true;
      this.showAssignOfficerModal = true;
      this.labelofmodalwindow = this.labelOfAssignOfficer;
    }

    openAnswerToCommentModal() {
      getApproverComment({
        recordId: this.recordId
      }).then((result) => {
        if(result){
          this.textOfCommentMessage = result.comments;
          this.nameOfApprover = result.nameOfApprover;

          this.showModalWindow = true;
          this.showAnswerToCommentModal = true;
          this.labelofmodalwindow = labelOfAnswerToCommentButton;
        }
        this.error = undefined;
      }).catch((error) => {
        this.error = error;
        console.log(error);
      });
    }

    openAmlRiskScoreTool() {
      this.showAMLForm = true;
    }

    handleClose(event) {
        const showModalWindow = event.detail;
        this.showTerminateModal = showModalWindow;
        this.showSentToApproveModal = showModalWindow;
        this.showRejectionModal = showModalWindow;
        this.showModalWindow = showModalWindow;
        this.showAMLForm = showModalWindow;
      }

    get isActiveCustomer() {
        return this.activeCustomer = this.statusOfCustomer == 'Active' ? true : false;
    }

    get isOnboardingCustomer() {
        return this.onboardingCustomer = this.statusOfCustomer == 'Onboarding' ? true : false;
    }

    get isSentToApprove() {
        if(this.statusOfCustomer == 'Sent to Approve' && this.approver == userId) {
            this.sentToApprove = true;
        } else {
            this.sentToApprove = false;
        }
        return this.sentToApprove;
    }
    
    get labelTerminationOrDisconnectInProcess() {
        if(this.statusOfCustomer == 'Termination in Process') {
            this.labelOfTerminateOrDisconnectButton = this.labelOfTerminateButton;
        } else if (this.statusOfCustomer == 'Disconnection in Process'){
            this.labelOfTerminateOrDisconnectButton = this.labelOfDisconnectButton;
        }
        return this.labelOfTerminateOrDisconnectButton;
    }

    get isTerminationOrDisconnectInProcess() {
        return this.terminateOrDisconnectButtonIsAvailable = this.statusOfCustomer == 'Termination in Process' || this.statusOfCustomer == 'Disconnection in Process'  ? true : false;
    }

    get isCanBeActivated() {
        return this.activateButtonIsAvailable = this.statusOfCustomer == 'On Hold' || this.statusOfCustomer == 'Suspended'  ? true : false;
    }

    get isOnboardingOfficer() {
        return this.onboardingOfficerOfCustomer = this.onboardingOfficerId == this.userId ? true : false;
    }

    get isCustomerObject() {
      return this.isCustomerApiName = this.objectApiName == 'Customer__c'? true : false;
    }

    get isWebsiteObject() {
      return this.isWebsiteApiName = this.objectApiName == 'Website__c' ? true : false;
    }

    get isStartOnboardingVisible() {
      return this.displayStartOnboardingButton = this.statusOfCustomer == 'New' || this.statusOfCustomer == 'Uploading Documents' || this.statusOfCustomer == 'Ready for Onboarding'  ? true : false;
    }

    get isSystemAdmin() {
        checkIfUserIsSystemAdministrator({
        }).then((result) => {
            this.systemAdmin = result;
            console.log('this.systemAdmin ' + this.systemAdmin);
        }).catch((error) => {
            this.error = error;
            console.log(error);
        });
        return this.systemAdmin;
    }

    get isHeadOfCompliance() {
      checkIfUserHadPermissionForNewCustomer({
      }).then((result) => {
        this.newCustomer = this.statusOfCustomer == 'New' ? true : false;
        if(this.newCustomer && result){
          this.isHadProfileOfHeadCompliance = true;
        } else {
          this.isHadProfileOfHeadCompliance = false;
        }
      }).catch((error) => {
          this.error = error;
          console.log(error);
      });
      return this.isHadProfileOfHeadCompliance;
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