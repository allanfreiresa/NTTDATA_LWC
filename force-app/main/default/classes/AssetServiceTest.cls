@IsTest
private class AssetServiceTest {

    @IsTest
    static void testInvalidAssetIdentifier() {
        String result = AssetService.reportLostDevice(null);
        System.assertEquals('No device found.', result);
    }

    @IsTest
    static void testNoDeviceFound() {
        String result = AssetService.reportLostDevice('INVALID_IDENTIFIER');
        System.assertEquals('No device found.', result);
    }

    @IsTest
    static void testClaimAlreadyFiled() {
        // Setup
        Asset asset = new Asset(Name = 'Test Asset', Asset_Identifier__c = 'ASSET001', Status = 'Installed', AccountId = '001bm00000LbwlqAAB', ContactId= '003bm000003Ffm2AAC');
        insert asset;

        Insurance__c insurance = new Insurance__c(Asset__c = asset.Id, Active__c = true, Coverage__c = 'Comprehensive');
        insert insurance;

        Claim__c claim = new Claim__c(Asset__c = asset.Id, Insurance__c = insurance.Id, Status__c = 'New', Type__c = 'Loss');
        insert claim;

        // Test
        String result = AssetService.reportLostDevice('ASSET001');
        System.debug('resultado antes ' + result);
        System.debug('resultado insercao claim ' + claim) ;
        System.assertEquals(claim.Name + ' already filed.', result);
        
    }

    @IsTest
    static void testClaimNumberReturned() {
        // Setup
        //Asset asset = new Asset(Name = 'Test Asset', Asset_Identifier__c = 'ASSET002', Status = 'Installed');
        Asset asset = new Asset(Name = 'Test Asset', Asset_Identifier__c = 'ASSET002', Status = 'Installed', AccountId = '001bm00000LbwlqAAB', ContactId= '003bm000003Ffm2AAC');
        insert asset;

        Insurance__c insurance = new Insurance__c(Asset__c = asset.Id, Active__c = true, Coverage__c = 'Comprehensive');
        insert insurance;

        // Test
        String result = AssetService.reportLostDevice('ASSET002');
        System.assert(result.startsWith('CLM'), 'Expected a claim number to be returned');
    }

    @IsTest
    static void testNoCoverage() {
        // Setup
        //Asset asset = new Asset(Name = 'Test Asset', Asset_Identifier__c = 'ASSET003', Status = 'Installed');
        Asset asset = new Asset(Name = 'Test Asset', Asset_Identifier__c = 'ASSET003', Status = 'Installed', AccountId = '001bm00000LbwlqAAB', ContactId= '003bm000003Ffm2AAC');
        insert asset;

        Insurance__c insurance = new Insurance__c(Asset__c = asset.Id, Active__c = false, Coverage__c = 'Equipment');
        insert insurance;

        // Test
        String result = AssetService.reportLostDevice('ASSET003');
        System.assertEquals('No coverage. Asset status adjusted to Lost.', result);
    }
}
