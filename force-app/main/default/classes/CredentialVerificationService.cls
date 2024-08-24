global class CredentialVerificationService {

    // Expondo o método como um serviço web SOAP
    webService static String verifyCredential(String lastName, String certificationName) {
        
        // Debug para rastreamento de execução
        System.debug('Entrou no metodo verifyCredential()');
        System.debug('Parâmetros recebidos: lastName=' + lastName + ', certificationName=' + certificationName);
        
        // Verifica se os parâmetros de entrada são válidos
        if (String.isBlank(lastName) || String.isBlank(certificationName)) {
            System.debug('Input validation failed: lastName or certificationName is blank.');
            return 'No record found';
        }
        
        // Consulta para encontrar o contato com o sobrenome fornecido
        List<Contact> contacts = [SELECT Id FROM Contact WHERE LastName = :lastName LIMIT 1];
        
        if (contacts.isEmpty()) {
            System.debug('No contact found for lastName: ' + lastName);
            return 'No record found';
        }
        
        Contact contact = contacts[0];
        System.debug('Found contact with Id: ' + contact.Id);
        
        
        // Consulta para encontrar a certificação do contato através do relacionamento com Certification__c
        List<Contact_Certification__c> certifications = [
            SELECT Id, isActive__c, Name
            FROM Contact_Certification__c 
            WHERE Contact__c = :contact.Id AND Name = :certificationName LIMIT 1
        ];
        
        if (certifications.isEmpty()) {
            System.debug('No certification found for contact Id: ' + contact.Id + ' with certificationName: ' + certificationName);
            return 'No record found';
        }
        
        Contact_Certification__c certification = certifications[0];
        System.debug('Found certification with Id: ' + certification.Id + ', isActive__c: ' + certification.isActive__c);
        
        // Retorna o status da certificação com base no campo isActive__c
        if (certification.isActive__c) {
            System.debug('Certification is active.');
            return 'Valid';
        } else {
            System.debug('Certification needs renewal.');
            return 'Needs Renewal';
        }
    }
}
