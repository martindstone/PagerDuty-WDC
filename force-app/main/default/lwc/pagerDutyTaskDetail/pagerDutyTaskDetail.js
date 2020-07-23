import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import setStatus from '@salesforce/apex/PagerDutyWDCTask.setStatus';

export default class PagerDutyTaskDetail extends LightningElement {
    @api task;

    @track
    taskStatus;

    @api
    get assigneesStr() {
        if ( this.task.pagerDutyIncident.assignments ) {
            return this.task.pagerDutyIncident.assignments.map(ass => ass.summary).join(', ');
        } else {
            return null;
        }
    }

    connectedCallback() {
        this.taskStatus = this.task.task.Status;
    }

    updateStatus(event) {
        const id = this.task.task.Id;
        const status = event.detail.value;
        setStatus({
            id: id,
            status: status
        }).then(() => {
            this.taskStatus = status;
            refreshApex(this.taskStatus);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Task updated',
                    variant: 'success'
                })
            );
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating task',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        })
    }
}