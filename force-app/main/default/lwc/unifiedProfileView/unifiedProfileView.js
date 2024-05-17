import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getUnifiedProfile from '@salesforce/apex/UnifiedProfileController.getUnifiedProfile';

const FIELDS = [
    'Member__c.Name',
    'Member__c.patient_id__c',
    'Member__c.first_name__c',
    'Member__c.last_name__c'
]
    

export default class UnifiedProfileView extends LightningElement {

    @api recordId;
    @track record;
    @track error;
    title = 'Unified Profile View'
    iconName = 'standard:user';
    today = new Date();
    @track patientId;
    @track records;
    @track unifiedRecordId;
    @track dataSourceObjectId;
    @track dataSourceId;
    @track sourceRecordId;
    isLoading = false;


    @wire( getRecord, { recordId: '$recordId', fields: FIELDS } )
    wiredRecord({ error, data }) {
        if (data) {
            this.record = data;
            console.log('record', JSON.stringify(this.record, null, 2));
            this.patientId = this.record.fields.patient_id__c.value;
            console.log('patientId', this.patientId);
        } else if (error) {
            this.error = error;
            console.error('error', JSON.stringify(this.error, null, 2));
        }
    }

    get patientId() {
        return this.record.fields.patient_id__c.value;
    }

    getUnifiedProfileLinkData() {
        console.log('getUnifiedProfileLinkData', 'Start');
        console.log('patientId', this.patientId);
        this.isLoading = true;
        getUnifiedProfile({ recordId: this.patientId })
            .then(result => {
                console.log('result', JSON.stringify(
                    result, null, 2
                ));
                this.records = JSON.parse(result).data;
                //this.parseJson(result);
            })
            .catch(error => {
                console.error('error', JSON.stringify(
                    error, null, 2
                ));
            })
            .finally(() => {
                // console output the data variable to see each element of the data
                console.log(this.records[0].UnifiedRecordId);
                this.unifiedRecordId = this.records[0].UnifiedRecordId;
                this.dataSourceObjectId = this.records[0].cdp_DataSourceObjectId;
                this.dataSourceId = this.records[0].cdp_DataSourceId;
                this.sourceRecordId = this.records[0].SourceRecordId;
                console.log('unifiedRecordId', this.unifiedRecordId);
                console.log('dataSourceObjectId', this.dataSourceObjectId);
                console.log('dataSourceId', this.dataSourceId);
                this.isLoading = false;
                console.log('finally', 'End');
            });
    }




    connectedCallback() {
        this.loadRecord();
    }

    loadRecord() {
        console.log('loadRecord', 'Start');
        console.log('recordId', this.recordId);
        console.log('loadRecord', 'End');
    }
    parseJson(jsonString) {
        const parsedData = JSON.parse(jsonString);
        if (parsedData && parsedData.data && parsedData.data.length > 0) {
            this.unifiedRecordId = parsedData.data[0].UnifiedRecordId;
            this.dataSourceObjectId = parsedData.data[0].cdp_DataSourceObjectId;
            this.dataSourceId = parsedData.data[0].cdp_DataSourceId;
            this.sourceRecordId = parsedData.data[0].SourceRecordId;
        }
    }

}