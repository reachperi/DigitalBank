public with sharing class DetailComponentController {

	private final sObject mysObject;

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public DetailComponentController(ApexPages.StandardController stdController) {
        this.mysObject = (sObject)stdController.getRecord();
    }

    public String getRecordName() {
        return 'Hello ' + (String)mysObject.get('name') + ' (' + (Id)mysObject.get('Id') + ')';
    }
}