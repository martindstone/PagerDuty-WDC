import { LightningElement, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';

// Location bar support
import { subscribe, MessageContext, unsubscribe, APPLICATION_SCOPE } from 'lightning/messageService';
import COMMAND_CENTER_MSG_CHANNEL from '@salesforce/messageChannel/lightning__CommandCenterMessageChannel';

import getTasks from '@salesforce/apex/PagerDutyWDCController.getTasks';

export default class PagerDuty extends LightningElement {
    options = [
        {value: 'open', label: 'Open Tasks'},
        {value: 'closed', label: 'Closed Tasks'},
        {value: 'all', label: 'All Tasks'},
        {value: 'Not Started', label: 'Not Started'},
        {value: 'In Progress', label: 'In Progress'},
        {value: 'Completed', label: 'Completed'},
        {value: 'Waiting on someone else', label: 'Waiting on someone else'},
        {value: 'Deferred', label: 'Deferred'},
    ];


    @wire(MessageContext)
    messageContext;
    
    @track globalLocationName;
    @track globalLocationId;
    
    subscription;

    connectedCallback() {
        this.subscribeToChannel();
    }


    @track
    value = 'open';

    @track
    label = 'Open Tasks';

    @wire(getTasks, { taskSet: '$value', locationId: '$globalLocationId' })
    tasks;

    /**
     * Subscribe to Command Center Message Channel to listen to global filter changes
     */
    subscribeToChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(this.messageContext, COMMAND_CENTER_MSG_CHANNEL, message => this.handleEvent(message), {
                scope: APPLICATION_SCOPE
            });
        }
    }

    /**
     * Any time global filter changes are captured get updated values
     * @param  {} message
     */
    handleEvent(message) {
        switch (message.EventType) {
            case 'CC_LOCATION_CHANGE': {
                /* This event returns two attributes within it's EventPayload (locationName & locationId) */
                this.globalLocationName = message.EventPayload.locationName;
                this.globalLocationId = message.EventPayload.locationId;
          
                break;
            }

            default: {
                break;
            }
        }
    }
    
    /**
     * If disconnected unsubscribe from Message Channel
     */
    disconnectedCallback() {
        if (this.subscription) {
            unsubscribe(this.subscription);
        }
    }

    handleChange(event) {
        this.label = this.options.find(x => x.value == event.detail.value).label;
        this.value = event.detail.value;
        refreshApex(this.tasks);
    }
}
