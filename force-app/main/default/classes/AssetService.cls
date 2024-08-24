@RestResource(urlMapping='/lost/*')
global with sharing class AssetService {
    
    @HttpPost
    global static String reportLostDevice(String assetIdentifier) {
        System.debug('Starting reportLostDevice method');
        
        if (String.isBlank(assetIdentifier)) {
            System.debug('Asset identifier is blank');
            return 'No device found.';
        }
        
        // Busca o ativo com base no identificador
        Asset asset;
        try {
            asset = [SELECT Id, Status, (SELECT Id, Active__c, Coverage__c FROM Insurances__r LIMIT 1)
                     FROM Asset
                     WHERE Asset_Identifier__c = :assetIdentifier LIMIT 1];
        } catch (Exception e) {
            System.debug('Exception while querying Asset: ' + e.getMessage());
            return 'No device found.';
        }        
       
        
        System.debug('Asset found: ' + asset);
        System.debug('Asset status: ' + asset.Status);
        
         // Verifica se o ativo já está marcado como perdido
        /*if (asset.Status == 'Lost') {
            //AssetService.reportLostDevice('2345678');
            System.debug('Status jé está como Lost bye bye ');
            return 'Device already marked as Lost.';
        }*/
        
        // Verifica se há uma cobertura ativa de seguro
        Insurance__c activeInsurance;
        //if (!asset.Insurances__r.isEmpty()) {
        if (asset.Insurances__r.size() > 0 ) {
            System.debug('Insurance não está em branco');
            activeInsurance = asset.Insurances__r[0];
        }
        
        if (activeInsurance != null && activeInsurance.Active__c && activeInsurance.Coverage__c == 'Comprehensive') {
        //if (activeInsurance.Active__c && activeInsurance.Coverage__c == 'Comprehensive') {
            System.debug('Active comprehensive insurance found');

            
            List<Claim__c> existingClaims = [SELECT Id, Name FROM Claim__c WHERE Asset__c = :asset.Id AND Type__c = 'Loss' LIMIT 1];
            if (!existingClaims.isEmpty()) {
                System.debug('Existing claim found: ' +existingClaims[0].Name);
                return existingClaims[0].Name + ' already filed.';
            }            
           
            
            // Atualiza o status do ativo para 'Lost' e cria uma nova reivindicação
            asset.Status = 'Lost';
            update asset;
            System.debug('Asset status updated to Lost');
            
            Claim__c newClaim = new  Claim__c(Asset__c = asset.Id, 
                                              Insurance__c = activeInsurance.Id, 
                                              Status__c = 'New',
                                              Description__c = 'Deu certo',
                                              Type__c = 'Loss');
            insert newClaim;
            
            System.debug('OBJETOS: ' + newClaim);
            System.debug('New claim created: ' + newClaim.Name);
            System.debug('Name Objeto pelo SOQL: ' + [SELECT Name FROM Claim__c WHERE Id = :newClaim.Id].Name );
            // Captura e retorna o número da reivindicação (Name)
            return [SELECT Name FROM Claim__c WHERE Id = :newClaim.Id].Name;
            //return newClaim.Name;
        } else {
            asset.Status = 'Lost';
            update asset;
            return 'No coverage. Asset status adjusted to Lost.';
        }
    }
}
