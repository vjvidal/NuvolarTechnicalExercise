import { LightningElement, track } from 'lwc';
import getAllFlights from '@salesforce/apex/NuvolarFlightsController.getAllFlights';
import getFilteredAirports from '@salesforce/apex/NuvolarFlightsController.getFilteredAirports';
import saveFlight from '@salesforce/apex/NuvolarFlightsController.saveFlight';

export default class Comboboxexam extends LightningElement {

    arrivalAirport = '';
    departureAirport = '';
    @track airportFilter = '';
    @track airportOptions = [];
    airportCompleteData = {};

    selectedArrivalAirport = undefined;
    selectedDepartureAirport = undefined;
    @track selectedArrivalName = '';
    @track selectedDepartureName = '';

    flightsColumns = [
        { label: 'Flight Id', fieldName: 'flightName' },
        { label: 'Arrival Airport', fieldName: 'arrAirport' },
        { label: 'Departure Airport', fieldName: 'deparAirport' },
        { label: 'Distance (km)', fieldName: 'distance', type: 'number' }
    ];

    flightsData = [];

    get airportOptions() {
        return this.airportOptions;
    }

    // First call to retrieve all Airports
    connectedCallback(){
        getFilteredAirports({iataCode: this.airportFilter})
        .then(result =>{
            let airportsAux = [];
            for(var i=0; i<result.length; i++){
                let airportName = result[i].Name+' ('+result[i].nv_fld_iataCode__c+')';
                airportsAux.push({label : airportName, value : result[i].Id});
                this.airportCompleteData[result[i].Id] = {id: result[i].Id, name : airportName, latitude : result[i].nv_fld_latitude__c, longitude : result[i].nv_fld_longitude__c};
            }
            this.airportOptions = airportsAux;
        });
        
        this.refreshFlights();
    }

    handleArrivalChange(event){
        this.arrivalAirport = event.detail.value;
        this.selectedArrivalAirport = this.airportCompleteData[this.arrivalAirport];
        this.selectedArrivalName = this.selectedArrivalAirport.name;
    }

    handleDepartureChange(event){
        this.departureAirport = event.detail.value;
        this.selectedDepartureAirport = this.airportCompleteData[this.departureAirport];
        this.selectedDepartureName = this.selectedDepartureAirport.name;
    }

    updateFilter(event){
        this.airportFilter = event.detail.value;
        // When the filter is updated, refresh airports with new values filtering by Query (This can result in many DML operations being performed)
        getFilteredAirports({iataCode: this.airportFilter})
        .then(result =>{
            let airportsAux = [];
            for(var i=0; i<result.length ; i++){
                let airportName = result[i].Name+' ('+result[i].nv_fld_iataCode__c+')';
                airportsAux.push({label : airportName, value : result[i].Id});
            }
            this.airportOptions = airportsAux;
        })
    }

    handleSaveFlight(event){
        if (this.selectedArrivalAirport != undefined && this.selectedDepartureAirport != undefined && this.selectedArrivalAirport != this.selectedDepartureAirport){
            saveFlight({arrivalAirport: this.selectedArrivalAirport, departureAirport: this.selectedDepartureAirport});
        }
    }

    handleClear(){
        this.selectedArrivalName = '';
        this.selectedDepartureName = '';
        this.selectedArrivalAirport = undefined;
        this.selectedDepartureAirport = undefined;
    }

    refreshFlights(){
        getAllFlights().then(result =>{
            let flightsAux = [];
            for (var j=0; j<result.length; j++){
                flightsAux.push({
                    flightName: result[j].Name,
                    arrAirport: result[j].nv_fld_arrivalAirport__r.nv_fld_iataCode__c,
                    deparAirport: result[j].nv_fld_departureAirport__r.nv_fld_iataCode__c,
                    distance: result[j].nv_fld_flightDistance__c
                });
            }
            this.flightsData = flightsAux;
        });
    }
}