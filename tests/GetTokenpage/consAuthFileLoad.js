function getParameterByName(name, url) {
    if (!url) url = window.location.href;
    name = name.replace(/[\[\]]/g, "\\$&");
    var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
        results = regex.exec(url);
    if (!results) return null;
    if (!results[2]) return '';
    return decodeURIComponent(results[2].replace(/\+/g, " "));
}  

	var email1 = getParameterByName('email');
	var password1 = getParameterByName('password'); 



 var authenticationData = {
        Username : email1,
        Password : password1,
    };
    var authenticationDetails = new AWSCognito.CognitoIdentityServiceProvider.AuthenticationDetails(authenticationData);	
    var poolData = {
        UserPoolId : userData.UserPoolId, 
        ClientId : userData.ClientId 
    };
    var userPool = new AWSCognito.CognitoIdentityServiceProvider.CognitoUserPool(poolData);
    var userData = {
        Username : email1,
        Pool : userPool
    };
    var cognitoUser = new AWSCognito.CognitoIdentityServiceProvider.CognitoUser(userData);
	cognitoUser.authenticateUser(authenticationDetails, {
        onSuccess: function (result) {
            console.log('access token + ' + result.getAccessToken().getJwtToken());
			document.getElementById("successAndErrorMessages").innerHTML=result.getAccessToken().getJwtToken(); 
        },
 
        onFailure: function(err) {
            alert(err);
        },
 
    });