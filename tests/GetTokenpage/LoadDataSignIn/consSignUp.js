function getParameterByName(name, url) {
    if (!url) url = window.location.href;
    name = name.replace(/[\[\]]/g, "\\$&");
    var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
        results = regex.exec(url);
    if (!results) return null;
    if (!results[2]) return '';
    return decodeURIComponent(results[2].replace(/\+/g, " "));
}    
	
	
	AWSCognito.config.region = 'us-east-1'; //This is required to derive the endpoint
	
	var email1 = getParameterByName('email');
	var password1 = getParameterByName('password');
	
	       
    var poolData = { UserPoolId : userData.UserPoolId,
        ClientId : userData.ClientId
    };
    var userPool = new AWSCognito.CognitoIdentityServiceProvider.CognitoUserPool(poolData);

    var attributeList = [{"Name":"given_name","Value":"Test"},{"Name":"family_name","Value":"User"},{"Name":"email","Value":email1},{"Name":"custom:AccountType","Value":"consultant"},{"Name":"custom:BrowserVersion","Value":"dummy"},{"Name":"custom:TermOfUseVersion","Value":"1.01"}];
	
    
    var dataEmail = {
        Name : "email",
        Value : email1
    };
    var dataPhoneNumber = {
        Name : 'phone_number',
        Value : '+15555555555'
    };
    var attributeEmail = new AWSCognito.CognitoIdentityServiceProvider.CognitoUserAttribute(dataEmail);
    var attributePhoneNumber = new AWSCognito.CognitoIdentityServiceProvider.CognitoUserAttribute(dataPhoneNumber);

    attributeList.push(attributeEmail);
    attributeList.push(attributePhoneNumber);

    userPool.signUp(email1, password1, attributeList, null, function(err, result){
        if (err) {
            alert(err);
            return;
        }
        cognitoUser = result.user;
        console.log('user name is ' + cognitoUser.getUsername());
		document.getElementById("successAndErrorMessages").innerHTML=cognitoUser.getUsername();
    });
	