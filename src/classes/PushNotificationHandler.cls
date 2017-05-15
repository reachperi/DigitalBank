public class PushNotificationHandler implements Queueable, Database.AllowsCallouts {
    private Opportunity opp;
    private Contact socialContact;
    private String suffix = '';
    private String jobId;

    public PushNotificationHandler(Opportunity opp, Contact socialContact) {
        this.opp = opp;
        this.socialContact = socialContact;
    }
    public PushNotificationHandler(Opportunity opp, Contact socialContact, String suffix, String jobid) {
        this.opp = opp;
        this.socialContact = socialContact;
        this.suffix = suffix;
        this.jobId = jobid;
    }

	public void execute(QueueableContext context) {
        if (opp == null || socialContact == null) {
            return;
        }
        String deviceId = String.isNotBlank(socialContact.Device_Id__c) ? 
            socialContact.Device_Id__c : 
            'testId' + String.valueOf((Integer)(Math.random() * 1000)); 
        String payload = '[{"notification_Id": "' + opp.Id + suffix + '", "device_Id": "' + deviceId + '", "notification_text": "' + opp.Name + '"}]';
        HttpRequest req = new HttpRequest();
            req.setEndpoint('http://devesb.digitalbank.us:8101/notification-api/pushNotifications');
            req.setMethod('POST');
            req.setBody(payload);
            req.setHeader('api-cache-key', 'c672b8d1ef56ed28ab87c3622c5114069bdd3ad7b8f9737498d0c01ecef0967a');
            req.setHeader('api-country', 'us');
            req.setHeader('api-lang', 'en');
            req.setHeader('api-message-id', 'f47ac10b-58cc-4372-a567-0e02b2c3d479');
            req.setHeader('api-message-timestamp', String.valueOf(System.now()));
            req.setHeader('api-organisation', 'ddb');
            req.setHeader('api-related-id', 'f47ac10b-58cc-4372-a567-0e02b2c3d479');
            req.setHeader('api-transaction-id', 'f47ac10b-58cc-4372-a567-0e02b2c3d479');
            req.setHeader('api-transaction-timestamp', String.valueOf(System.now()));
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Cache-Control', 'no-cache');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug('PUSH NOTIFICATION SENT WITH PAYLOAD: ' + payload);
        System.debug('REQUEST: ' + req);
        System.debug('RESPONSE: ' + res.getBody());
        if (res.getStatusCode() == 200) {
            opp.PushNotificationSent__c = true;
            update opp;
        }
        deleteCronJob();
	}

    private void deleteCronJob() {
        if (String.isNotBlank(jobId)) {
            System.abortJob(jobId);
        }
    }
}