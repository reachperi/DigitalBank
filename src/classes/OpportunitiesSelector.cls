/**
 * See https://github.com/financialforcedev/fflib-apex-common for more info
 *
 * Install library via
 *   https://githubsfdeploy.herokuapp.com/app/githubdeploy/financialforcedev/fflib-apex-common
 */

/**
 * Class encapsulates query logic for Opportunity
 *
 * https://developer.salesforce.com/page/Apex_Enterprise_Patterns_-_Selector_Layer
 **/
 public class OpportunitiesSelector extends fflib_SObjectSelector
{

    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return new List<Schema.SObjectField> {
            Opportunity.Id,
            Opportunity.Name,
            Opportunity.Amount,
            Opportunity.StageName,
            Opportunity.CloseDate
        };
    }
    /**
     * Gets the s object field list.
     * @return     The s object field list.
     */
    public List<String> getFieldListString()
    {
        List<String> fieldList = new List<String>{
            'Financial_Account_Role__r.FinServ__FinancialAccount__r.Name'
        };
        for(Schema.SObjectField field : getSObjectFieldList()){
            fieldList.add(field.getDescribe().getName());
        }
        return fieldList;
    }

    /**
     * Gets currently represented sobject type name
     * @return     The s object type.
     */
    public Schema.SObjectType getSObjectType()
    {
        return Opportunity.sObjectType;
    }

    /**
     * Default selection of items by id
     * @param      idSet  The identifier set
     * @return     List of financial accounts
     */
    public List<Opportunity> selectById(Set<ID> idSet)
    {
        if (idSet == null || idSet.isEmpty()) return new Opportunity[]{};
        return (List<Opportunity>) selectSObjectsById(idSet);
    }

    public Opportunity[] selectByAccount(Set<Id> accountIds)
    {
        return selectByAccount(accountIds, 'retail');
    }

    /**
     * Select all financial accounts primarily related to a list of accounts
     * @param      accountIds  The account identifiers
     * @return     List of financial accounts
     */
    public Opportunity[] selectByAccount(Set<Id> accountIds, String category)
    {
        assertIsAccessible();
        String query = 'select {0} ' +
            'from {1} ' +
            'where AccountId IN: accountIds ';
        if(!String.isBlank(category)) {
            query += 'AND Category__c =: category';
        }
        query = String.format(
            query,
            new List<String> {
                String.join(getFieldListString(), ', '),
                getSObjectName()
            }
            );
        System.debug('query: ' + query);
        return (List<Opportunity>) Database.query(query);
    }

}