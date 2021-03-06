/**
 * See https://github.com/financialforcedev/fflib-apex-common for more info
 *
 * Install library via
 *   https://githubsfdeploy.herokuapp.com/app/githubdeploy/financialforcedev/fflib-apex-common
 */

/**
 * Encapsulates all behaviour logic relating to the FinServ__FinancialAccount__c object
 *
 * For more guidelines and details see
 *   https://developer.salesforce.com/page/Apex_Enterprise_Patterns_-_Domain_Layer
 *
 **/
public class FinancialAccounts extends fflib_SObjectDomain
{


    private Map<Id, Account> accountsMap = new Map<Id, Account>();

    public FinancialAccounts(List<FinServ__FinancialAccount__c> records)
    {
        super(records);
    }

    public override void onValidate(){}

    public override void onValidate(Map<Id,SObject> existingRecords){}

    public override void onAfterInsert()
    {
        accountsMap = this.getAccountsMap();
        rollUp((FinServ__FinancialAccount__c[]) Records, false);
        update accountsMap.values();
    }

    public override void onAfterUpdate(Map<Id,SObject> existingRecords)
    {
        accountsMap = this.getAccountsMap(existingRecords.values());
        rollUp((FinServ__FinancialAccount__c[]) existingRecords.values(), true);
        rollUp((FinServ__FinancialAccount__c[]) Records, false);
        update accountsMap.values();
    }

    public override void onAfterDelete()
    {
        // fflib doesn't execute validation while deleting, accountmap needs to be manually invoked
        accountsMap = this.getAccountsMap();
        rollUp((FinServ__FinancialAccount__c[]) Records, true);
        update accountsMap.values();
    }

    private Map<Id, Account> getAccountsMap()
    {
        return this.getAccountsMap(null);
    }

    private Map<Id, Account> getAccountsMap(FinServ__FinancialAccount__c[] loopRecords)
    {
        Set<Id> accounts = new Set<Id>();
        if (loopRecords == null || loopRecords.isEmpty()) {
            loopRecords = Records;
        } else {
            loopRecords.addAll((FinServ__FinancialAccount__c[]) Records);
        }
        for(FinServ__FinancialAccount__c fa: loopRecords) {
            accounts.add(fa.FinServ__PrimaryOwner__c);
        }
        Map<Id, Account> accountsMap = new Map<Id, Account>(
            [SELECT RetailBalance__c, WealthBalance__c, CommercialBalance__c,
                    RetailLoan__c, CommercialLoan__c
                FROM Account
                WHERE Id IN: accounts FOR UPDATE]
        );
        return accountsMap;
    }

    private void rollUp(FinServ__FinancialAccount__c[] faccounts, Boolean subtract)
    {
        for(FinServ__FinancialAccount__c fa: faccounts) {
            Account accToUpdate = accountsMap.get(fa.FinServ__PrimaryOwner__c);
            if (String.isBlank(fa.Category__c)) continue;
            String suffix = fa.IsLoan__c && fa.Category__c != 'Wealth' ? 'Loan__c' : 'Balance__c';
            Decimal sum = (Decimal) accToUpdate.get(fa.Category__c + suffix);
            if (sum == null) sum = 0;
            if (!subtract) sum += fa.FinServ__Balance__c != null ? fa.FinServ__Balance__c : 0.0;
            else           sum -= fa.FinServ__Balance__c != null ? fa.FinServ__Balance__c : 0.0;
            accToUpdate.put(fa.Category__c + suffix, sum);
        }
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable2
    {
        public fflib_SObjectDomain construct(List<SObject> sObjectList)
        {
            return new FinancialAccounts(sObjectList);
        }

        public fflib_SObjectDomain construct(List<SObject> sObjectList, SObjectType sObjectType)
        {
            return new FinancialAccounts(sObjectList);
        }
    }
}