    var authenticationData = {
        Username : userData.emp_email,
        Password : userData.emp_pw,
    };
    var authenticationDetails = new AWSCognito.CognitoIdentityServiceProvider.AuthenticationDetails(authenticationData);	
    var poolData = {
        UserPoolId : userData.UserPoolId, 
        ClientId : userData.ClientId 
    };
    var userPool = new AWSCognito.CognitoIdentityServiceProvider.CognitoUserPool(poolData);
    var userData = {
        Username : userData.emp_email,
        Pool : userPool
    };
    var cognitoUser = new AWSCognito.CognitoIdentityServiceProvider.CognitoUser(userData);
	cognitoUser.authenticateUser(authenticationDetails, {
        onSuccess: function (result) {
            // console.log('access token + ' + result.getAccessToken().getJwtToken());
			document.getElementById("successAndErrorMessages").innerHTML=result.getAccessToken().getJwtToken(); 
        },
 
        onFailure: function(err) {
            alert(err);
        },
 
    });