@IsTest
private class CredentialVerificationServiceTest {

    @IsTest
    static void testValidCertification() {

        String nameCertification ='';
        // Configuração
        Contact contact = new Contact(LastName = 'Doe');
        insert contact;
        
        Certification__c certification = new Certification__c(Name = 'Certifica1');
        insert certification;
        
        Contact_Certification__c contactCertification = new Contact_Certification__c(
            Contact__c = contact.Id, 
            Certification__c = certification.Id,             
            isActive__c = true,  // Certificação ativa
            Issue_Date__c = Date.today()  // Preenchendo campo obrigatório
        );
        insert contactCertification;

         // Verificações
         System.debug('Contact Id: ' + contact.Id);
         System.debug('Certification Id: ' + certification.Id);
         System.debug('Contact Certification Id: ' + contactCertification.Id);
         System.debug('Contact Certification Name: ' + contactCertification.Name);
         System.debug('Certification Name: ' + Certification.Name);
         //System.debug('Name Objeto pelo SOQL: ' + [SELECT Name FROM Claim__c WHERE Id = :newClaim.Id].Name );
         System.debug('Name Objeto pelo SOQL: ' + [SELECT Name FROM Contact_Certification__c WHERE Contact__c = :contact.Id AND Certification__c = :certification.Id].Name);
         
         nameCertification = [SELECT Name FROM Contact_Certification__c WHERE Contact__c = :contact.Id AND Certification__c = :certification.Id].Name;
       
        
        // Teste - Certificação válida
        String result = CredentialVerificationService.verifyCredential('Doe', nameCertification);
        System.debug('Result: ' + result);
        System.assertEquals('Valid', result);  // Esperado 'Valid'
    }
    
    @IsTest
    static void testNeedsRenewal() {
        
        String nameCertification ='';

        Contact contact = new Contact(LastName = 'Smith');
        insert contact;
        
        Certification__c certification = new Certification__c(Name = 'Drone Operator');
        insert certification;
        
        Contact_Certification__c contactCertification = new Contact_Certification__c(
            Contact__c = contact.Id, 
            Certification__c = certification.Id, 
            isActive__c = false,  // Certificação não está ativa
            Issue_Date__c = Date.today()  // Preenchendo campo obrigatório
        );
        insert contactCertification;

        nameCertification = [SELECT Name FROM Contact_Certification__c WHERE Contact__c = :contact.Id AND Certification__c = :certification.Id].Name;
        
        // Teste - Certificação precisa de renovação
        String result = CredentialVerificationService.verifyCredential('Smith', nameCertification);
        System.assertEquals('Needs Renewal', result);  // Esperado 'Needs Renewal'
    }

    @IsTest
    static void testNoRecordFound() {
        // Teste - Contato ou certificação não existe
        String result = CredentialVerificationService.verifyCredential('NonExistent', 'NonExistent');
        System.assertEquals('No record found', result);
        
        // Teste - Certificação não existe para um contato válido
        Contact contact = new Contact(LastName = 'Johnson');
        insert contact;
        
        result = CredentialVerificationService.verifyCredential('Johnson', 'NonExistent');
        System.assertEquals('No record found', result);
        
        // Teste - Sobrenome não existe, mas a certificação existe
        Certification__c certification = new Certification__c(Name = 'Valid Cert');
        insert certification;
        
        result = CredentialVerificationService.verifyCredential('NonExistentLastName', 'Valid Cert');
        System.assertEquals('No record found', result);
    }
    
    @IsTest
    static void testInvalidInput() {
        // Teste - Entrada inválida (parâmetros em branco)
        String result = CredentialVerificationService.verifyCredential('', 'SomeCertification');
        System.assertEquals('No record found', result);
        
        result = CredentialVerificationService.verifyCredential('Doe', '');
        System.assertEquals('No record found', result);
        
        // Teste - Entrada nula
        result = CredentialVerificationService.verifyCredential(null, 'SomeCertification');
        System.assertEquals('No record found', result);
        
        result = CredentialVerificationService.verifyCredential('Doe', null);
        System.assertEquals('No record found', result);
    }
}