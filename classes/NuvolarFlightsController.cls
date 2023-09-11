public with sharing class NuvolarFlightsController {

    static final String CONST_LATITUDE = 'latitude';
    static final String CONST_LONGITUDE = 'longitude';
    static final String CONST_ID = 'id';

    @AuraEnabled(cacheable=true)
    public static List<nv_obj_Airport__c> getFilteredAirports(String iataCode){
        List<nv_obj_Airport__c> airportList = new List<nv_obj_Airport__c>();
        try{
            if (!String.isBlank(iataCode)){
                String iataCodeUpperCase = '%'+iataCode+'%';
                airportList = [SELECT Id,Name,nv_fld_iataCode__c,nv_fld_latitude__c,nv_fld_longitude__c 
                                FROM nv_obj_Airport__c 
                                WHERE nv_fld_iataCode__c 
                                LIKE :iataCodeUpperCase 
                                WITH SECURITY_ENFORCED
                                ORDER BY nv_fld_iataCode__c ASC];
            } else {
                airportList = [SELECT Id,Name,nv_fld_iataCode__c,nv_fld_latitude__c,nv_fld_longitude__c 
                                FROM nv_obj_Airport__c 
                                WITH SECURITY_ENFORCED
                                ORDER BY nv_fld_iataCode__c ASC];
            }
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }        
        return airportList;
    }

    @AuraEnabled
    public static List<nv_obj_flight__c> getAllFlights(){
        List<nv_obj_flight__c> flightsList = new List<nv_obj_flight__c>();
        try{
            flightsList = [SELECT Id,Name,nv_fld_arrivalAirport__r.nv_fld_iataCode__c,nv_fld_departureAirport__r.nv_fld_iataCode__c,nv_fld_flightDistance__c
                            FROM nv_obj_flight__c
                            WITH SECURITY_ENFORCED
                            ORDER BY Name ASC];
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return flightsList;
    }

    @AuraEnabled
    public static void saveFlight(Map<String,Object> arrivalAirport, Map<String,Object> departureAirport){
        Decimal arrLatitude = (Decimal) arrivalAirport.get(CONST_LATITUDE);
        Decimal arrLongitude = (Decimal) arrivalAirport.get(CONST_LONGITUDE);
        Decimal deparLatitude = (Decimal) departureAirport.get(CONST_LATITUDE);
        Decimal deparLongitude = (Decimal) departureAirport.get(CONST_LONGITUDE);

        Id arrId = (Id) arrivalAirport.get(CONST_ID);
        Id deparId = (Id) departureAirport.get(CONST_ID);

        Decimal distance = calculateDistance(arrLatitude, arrLongitude, deparLatitude, deparLongitude);

        nv_obj_flight__c newFlight = new nv_obj_flight__c();
        newFlight.nv_fld_arrivalAirport__c = arrId;
        newFlight.nv_fld_departureAirport__c = deparId;
        newFlight.nv_fld_flightDistance__c = distance;

        try{
            insert newFlight;
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static Decimal calculateDistance(Decimal latitude1, Decimal longitude1, Decimal latitude2, Decimal longitude2) {
        Integer earthRadius = 6371; // in kilometers

        // Transform coordinates from degrees to radians
        Decimal latitudeRadians1 = latitude1 * Math.PI/180;
        Decimal latitudeRadians2 = latitude2 * Math.PI/180;       
        // Latitude and longitude differences in radians
        Decimal latitudeDelta = (latitude2 - latitude1) * Math.PI/180;
        Decimal longitudeDelta = (longitude2 - longitude1) * Math.PI/180;

        Decimal a = Math.sin(latitudeDelta/2) * Math.sin(latitudeDelta/2) +
                    Math.cos(latitudeRadians1) * Math.cos(latitudeRadians2) *
                    Math.sin(longitudeDelta/2) * Math.sin(longitudeDelta/2);

        Decimal arc = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
        Decimal distance = earthRadius * arc; // in kilometers
        return distance.setScale(2); // return rounded to 2 decimal places
    }
}