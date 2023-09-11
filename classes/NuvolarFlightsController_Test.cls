@isTest
private with sharing class NuvolarFlightsController_Test {
    @TestSetup
    private static void makeData(){
        List<nv_obj_Airport__c> airportList = new List<nv_obj_Airport__c>();
        nv_obj_Airport__c a1 = new nv_obj_Airport__c();
        a1.Name = 'Aeropuerto Internacional de la Región de Murcia';
        a1.nv_fld_iataCode__c = 'RMU';
        a1.nv_fld_latitude__c = 37.803;
        a1.nv_fld_longitude__c = -1.125;
        airportList.add(a1);

        nv_obj_Airport__c a2 = new nv_obj_Airport__c();
        a2.Name = 'Aeropuerto de Alicante-Elche';
        a2.nv_fld_iataCode__c = 'ALC';
        a2.nv_fld_latitude__c = 38.2822;
        a2.nv_fld_longitude__c = -0.558156;
        airportList.add(a2);

        insert airportList;

        List<nv_obj_flight__c> flightsList = new List<nv_obj_flight__c>();
        nv_obj_flight__c flight = new nv_obj_flight__c();
        flight.nv_fld_arrivalAirport__c = a1.Id;
        flight.nv_fld_departureAirport__c = a2.Id;
        flight.nv_fld_flightDistance__c = 72.82;
        flightsList.add(flight);

        insert flightsList;
    }

    @isTest
    private static void testGetAirportWithoutFilter(){
        Test.startTest();
        List<nv_obj_Airport__c> airportList = NuvolarFlightsController.getFilteredAirports(null);
        Test.stopTest();
        System.assertEquals(2, airportList.size(), 'Airport list have an incorrect size');
    }

    @isTest
    private static void testGetAirportWithFilter(){
        Test.startTest();
        List<nv_obj_Airport__c> airportList = NuvolarFlightsController.getFilteredAirports('RMU');
        Test.stopTest();
        System.assertEquals('RMU', airportList[0].nv_fld_iataCode__c, 'RMU airport not found');
    }

    @isTest
    private static void testGetAllFlights(){
        Test.startTest();
        List<nv_obj_flight__c> flightsList = NuvolarFlightsController.getAllFlights();
        Test.stopTest();
        System.assertEquals('RMU', flightsList[0].nv_fld_arrivalAirport__r.nv_fld_iataCode__c, 'Wrong arrival airport IATA Code');
        System.assertEquals('ALC', flightsList[0].nv_fld_departureAirport__r.nv_fld_iataCode__c, 'Wrong departure airport IATA Code');
    }

    @isTest
    private static void testSaveFlight(){
        Map<String, Object> arrAirport = new Map<String, Object>();
        Map<String, Object> deparAirport = new Map<String, Object>();
        Id arrAirportId = null;
        Id deparAirportId = null;
        
        Test.startTest();
        List<nv_obj_Airport__c> airportList = [SELECT Id, nv_fld_latitude__c, nv_fld_longitude__c,nv_fld_iataCode__c 
                                                FROM nv_obj_Airport__c
                                                WHERE nv_fld_iataCode__c IN ('RMU','ALC')];
        for (nv_obj_Airport__c airport : airportList){
            if (airport.nv_fld_iataCode__c == 'RMU'){
                arrAirport.put('id', airport.Id);
                arrAirportId = airport.Id;
                arrAirport.put('latitude', airport.nv_fld_latitude__c);
                arrAirport.put('longitude', airport.nv_fld_longitude__c);
            } else if (airport.nv_fld_iataCode__c == 'ALC'){
                deparAirport.put('id', airport.Id);
                deparAirportId = airport.Id;
                deparAirport.put('latitude', airport.nv_fld_latitude__c);
                deparAirport.put('longitude', airport.nv_fld_longitude__c);
            }
        }
        NuvolarFlightsController.saveFlight(arrAirport, deparAirport);

        nv_obj_flight__c newFlight = [SELECT Id,Name,nv_fld_flightDistance__c,nv_fld_departureAirport__c,nv_fld_arrivalAirport__c 
                                        FROM nv_obj_flight__c 
                                        WHERE nv_fld_arrivalAirport__c = :arrAirportId AND nv_fld_departureAirport__c = :deparAirportId
                                        LIMIT 1];
        Test.stopTest();
        System.assertEquals(72.82, newFlight.nv_fld_flightDistance__c, 'Distance incorrectly calculated');
    }
}