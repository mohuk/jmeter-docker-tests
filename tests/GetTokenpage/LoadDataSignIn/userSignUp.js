    AWSCognito.config.region = 'us-east-1'; //This is required to derive the endpoint
        
    var poolData = { UserPoolId : 'us-east-1_fYtPREjCL',
        ClientId : '53vaq19fi44qi0jc2ep9n575e'
    };
    var userPool = new AWSCognito.CognitoIdentityServiceProvider.CognitoUserPool(poolData);

    var attributeList = [];
    
    var dataEmail = {
        Name : 'email',
        Value : 'aut_user1@yopmail.com'
    };
    var dataPhoneNumber = {
        Name : 'phone_number',
        Value : '+15555555555'
    };
    var attributeEmail = new AWSCognito.CognitoIdentityServiceProvider.CognitoUserAttribute(dataEmail);
    var attributePhoneNumber = new AWSCognito.CognitoIdentityServiceProvider.CognitoUserAttribute(dataPhoneNumber);

    attributeList.push(attributeEmail);
    attributeList.push(attributePhoneNumber);

    userPool.signUp('username', 'password', attributeList, null, function(err, result){
        if (err) {
            alert(err);
            return;
        }
        cognitoUser = result.user;
        console.log('user name is ' + cognitoUser.getUsername());
    });